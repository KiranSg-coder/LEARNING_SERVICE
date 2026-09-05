USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_GENERATE_DAILY_LEARNING_PLAN
-- Core algorithm: pick reviews due + new content for user's
-- enrolled paths, respecting daily minutes budget, Leitner box
-- schedule, topic prerequisites, and difficulty tier.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GENERATE_DAILY_LEARNING_PLAN]
(
    @USERID INT,
    @PLANDATE DATE,
    @DAYID INT = NULL,
    @MAXNONMASTEREDTOPICS INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @DAILYMINUTES INT;
        DECLARE @SKILLLEVEL NVARCHAR(20);
        DECLARE @MINUTESUSED INT = 0;
        DECLARE @PLANID INT;
        DECLARE @EFFECTIVEDAYID INT;

        --================================================
        -- 1. Validate user has guided learning enabled
        --================================================
        SELECT
            @DAILYMINUTES = DAILYMINUTES,
            @SKILLLEVEL = SKILLLEVEL
        FROM USER_LEARNING_PROFILE
        WHERE USERID = @USERID AND GUIDEDENABLED = 1;

        IF @DAILYMINUTES IS NULL
        BEGIN
            SELECT
                1 AS ErrorCode,
                'NOT_ENROLLED' AS ErrorType,
                'User does not have guided learning enabled' AS ErrorMessage;
            RETURN;
        END

        --================================================
        -- 2. Check if plan already exists for this date
        --================================================
        IF EXISTS (
            SELECT 1 FROM DAILY_LEARNING_PLAN
            WHERE USERID = @USERID AND PLANDATE = @PLANDATE
        )
        BEGIN
            SELECT
                2 AS ErrorCode,
                'PLAN_EXISTS' AS ErrorType,
                'Plan already exists for this date' AS ErrorMessage;
            RETURN;
        END

        --================================================
        -- 3. Check user has enrollments
        --================================================
        IF NOT EXISTS (
            SELECT 1 FROM USER_PATH_ENROLLMENT
            WHERE USERID = @USERID AND ISACTIVE = 1
        )
        BEGIN
            SELECT
                3 AS ErrorCode,
                'NO_ENROLLMENTS' AS ErrorType,
                'User has no active path enrollments' AS ErrorMessage;
            RETURN;
        END

        --================================================
        -- 3b. Require daily non-negotiable checklist (USERDAY + DAYCHECKLISTITEM)
        --================================================
        IF NOT EXISTS (
            SELECT 1
            FROM [DAILY_EXECUTION].[dbo].[USERDAY] ud
            INNER JOIN [DAILY_EXECUTION].[dbo].[DAYCHECKLISTITEM] dci ON dci.DAYID = ud.DAYID
            WHERE ud.USERID = @USERID
              AND CAST(ud.DAYDATE AS DATE) = CAST(@PLANDATE AS DATE)
        )
        BEGIN
            SELECT
                4 AS ErrorCode,
                'NO_NON_NEGOTIABLES' AS ErrorType,
                'No daily non-negotiable checklist for this date' AS ErrorMessage;
            RETURN;
        END

        SET @EFFECTIVEDAYID = @DAYID;
        IF @EFFECTIVEDAYID IS NULL
        BEGIN
            BEGIN TRY
                SELECT @EFFECTIVEDAYID = ud.DAYID
                FROM [DAILY_EXECUTION].[dbo].[USERDAY] ud
                WHERE ud.USERID = @USERID AND ud.DAYDATE = @PLANDATE;
            END TRY
            BEGIN CATCH
                SET @EFFECTIVEDAYID = NULL;
            END CATCH
        END

        BEGIN TRANSACTION;

        --================================================
        -- 4. REVIEW SLOT: topics where NEXTREVIEWDATE <= today
        --================================================
        DECLARE @REVIEWTOPICID INT;
        DECLARE @REVIEWCONTENTID INT;

        SELECT TOP 1
            @REVIEWTOPICID = UTP.TOPICID
        FROM USER_TOPIC_PROGRESS UTP
        INNER JOIN TOPIC_MASTER TM ON UTP.TOPICID = TM.TOPICID
        INNER JOIN USER_PATH_ENROLLMENT UPE ON TM.PATHID = UPE.PATHID
            AND UPE.USERID = @USERID AND UPE.ISACTIVE = 1
        WHERE UTP.USERID = @USERID
          AND UTP.NEXTREVIEWDATE IS NOT NULL
          AND UTP.NEXTREVIEWDATE <= @PLANDATE
          AND UTP.MASTERYLEVEL != 'MASTERED'
        ORDER BY UTP.NEXTREVIEWDATE ASC, UPE.PRIORITYORDER ASC;

        -- Phase 4: retention moved to REVIEW_SERVICE. Skip embedding REVIEW in daily progression.
        DECLARE @SKIPGUIDEDREVIEWSLOTS BIT = 1;
        IF @SKIPGUIDEDREVIEWSLOTS = 0 AND @REVIEWTOPICID IS NOT NULL AND @MINUTESUSED < @DAILYMINUTES
        BEGIN
            -- Pick review content (previous content the user already saw)
            SELECT TOP 1 @REVIEWCONTENTID = CI.CONTENTID
            FROM CONTENT_ITEM CI
            INNER JOIN USER_TOPIC_PROGRESS UTP ON UTP.TOPICID = CI.TOPICID AND UTP.USERID = @USERID
            WHERE CI.TOPICID = @REVIEWTOPICID
              AND CI.ISACTIVE = 1
              AND CI.DISPLAYORDER <= UTP.CONTENTINDEX
            ORDER BY CI.DISPLAYORDER DESC;

            INSERT INTO DAILY_LEARNING_PLAN
            (USERID, PLANDATE, PLANTYPE, PLANSLOT, TOPICID, CONTENTID, QUIZREQUIRED, DAYID)
            VALUES
            (@USERID, @PLANDATE, 'REVIEW', 'REVIEW', @REVIEWTOPICID, @REVIEWCONTENTID, 0, @EFFECTIVEDAYID);

            SET @MINUTESUSED = @MINUTESUSED + 5;
        END

        --================================================
        -- 5. NEW CONTENT: pick next topic + content from path order
        --================================================
        DECLARE @NEWTOPICID INT;
        DECLARE @NEWCONTENTID INT;
        DECLARE @NEWCONTENTMINUTES INT;

        IF @MINUTESUSED < @DAILYMINUTES
        BEGIN
            -- Find next topic the user hasn't started or needs to continue
            SELECT TOP 1
                @NEWTOPICID = TM.TOPICID
            FROM TOPIC_MASTER TM
            INNER JOIN USER_PATH_ENROLLMENT UPE ON TM.PATHID = UPE.PATHID
                AND UPE.USERID = @USERID AND UPE.ISACTIVE = 1
            LEFT JOIN USER_TOPIC_PROGRESS UTP ON UTP.TOPICID = TM.TOPICID AND UTP.USERID = @USERID
            WHERE TM.ISACTIVE = 1
              AND (
                  -- Not started at all
                  UTP.PROGRESSID IS NULL
                  -- Or started but not mastered (has more content to do)
                  OR (
                      UTP.MASTERYLEVEL NOT IN ('PROFICIENT', 'MASTERED')
                      AND UTP.CONTENTINDEX < (SELECT COUNT(*) FROM CONTENT_ITEM WHERE TOPICID = TM.TOPICID AND ISACTIVE = 1)
                  )
              )
              -- Check prerequisites met
              AND (
                  TM.PREREQUISITETOPICID IS NULL
                  OR EXISTS (
                      SELECT 1 FROM USER_TOPIC_PROGRESS PRE
                      WHERE PRE.USERID = @USERID
                        AND PRE.TOPICID = TM.PREREQUISITETOPICID
                        AND PRE.MASTERYLEVEL IN ('FAMILIAR', 'PROFICIENT', 'MASTERED')
                  )
              )
            ORDER BY UPE.PRIORITYORDER ASC, TM.DISPLAYORDER ASC;

            IF @NEWTOPICID IS NOT NULL
            BEGIN
                -- Subscription: cap concurrent non-mastered topics (new progress row = new topic track)
                IF NOT EXISTS (
                    SELECT 1 FROM USER_TOPIC_PROGRESS
                    WHERE USERID = @USERID AND TOPICID = @NEWTOPICID
                )
                   AND @MAXNONMASTEREDTOPICS IS NOT NULL
                BEGIN
                    DECLARE @NONMASTEREDTOPICCOUNT INT;
                    SELECT @NONMASTEREDTOPICCOUNT = COUNT(*)
                    FROM USER_TOPIC_PROGRESS
                    WHERE USERID = @USERID
                      AND MASTERYLEVEL <> N'MASTERED';

                    IF @NONMASTEREDTOPICCOUNT >= @MAXNONMASTEREDTOPICS
                    BEGIN
                        ROLLBACK TRANSACTION;

                        SELECT
                            5 AS ErrorCode,
                            'TOPIC_LIMIT_REACHED' AS ErrorType,
                            N'Topic limit reached for your plan. Master a topic or upgrade to start another.' AS ErrorMessage,
                            @MAXNONMASTEREDTOPICS AS MaxTopics,
                            @NONMASTEREDTOPICCOUNT AS CurrentNonMasteredTopics;
                        RETURN;
                    END
                END

                -- Ensure progress row exists
                IF NOT EXISTS (
                    SELECT 1 FROM USER_TOPIC_PROGRESS
                    WHERE USERID = @USERID AND TOPICID = @NEWTOPICID
                )
                BEGIN
                    INSERT INTO USER_TOPIC_PROGRESS (USERID, TOPICID)
                    VALUES (@USERID, @NEWTOPICID);
                END

                DECLARE @CURRENTCONTENTINDEX INT;
                SELECT @CURRENTCONTENTINDEX = ISNULL(CONTENTINDEX, 0)
                FROM USER_TOPIC_PROGRESS
                WHERE USERID = @USERID AND TOPICID = @NEWTOPICID;

                -- THEORY SLOT (if topic has markdown theory)
                DECLARE @HASTHEORY BIT = 0;
                SELECT @HASTHEORY = CASE WHEN THEORYMARKDOWN IS NOT NULL AND LEN(THEORYMARKDOWN) > 0 THEN 1 ELSE 0 END
                FROM TOPIC_MASTER WHERE TOPICID = @NEWTOPICID;

                IF @HASTHEORY = 1 AND @MINUTESUSED < @DAILYMINUTES
                BEGIN
                    INSERT INTO DAILY_LEARNING_PLAN
                    (USERID, PLANDATE, PLANTYPE, PLANSLOT, TOPICID, CONTENTID, QUIZREQUIRED, DAYID)
                    VALUES
                    (@USERID, @PLANDATE, 'NEW', 'THEORY', @NEWTOPICID, NULL, 0, @EFFECTIVEDAYID);

                    SET @MINUTESUSED = @MINUTESUSED + 10;
                END

                -- PRACTICE SLOT: next content item
                IF @MINUTESUSED < @DAILYMINUTES
                BEGIN
                    SELECT TOP 1
                        @NEWCONTENTID = CONTENTID,
                        @NEWCONTENTMINUTES = ESTIMATEDMINUTES
                    FROM CONTENT_ITEM
                    WHERE TOPICID = @NEWTOPICID
                      AND ISACTIVE = 1
                      AND DISPLAYORDER > @CURRENTCONTENTINDEX
                    ORDER BY DISPLAYORDER ASC;

                    IF @NEWCONTENTID IS NOT NULL
                    BEGIN
                        INSERT INTO DAILY_LEARNING_PLAN
                        (USERID, PLANDATE, PLANTYPE, PLANSLOT, TOPICID, CONTENTID, QUIZREQUIRED, DAYID)
                        VALUES
                        (@USERID, @PLANDATE, 'NEW', 'PRACTICE', @NEWTOPICID, @NEWCONTENTID, 0, @EFFECTIVEDAYID);

                        SET @MINUTESUSED = @MINUTESUSED + ISNULL(@NEWCONTENTMINUTES, 15);
                    END
                END

                -- QUIZ SLOT — do NOT gate on minute budget: Theory + Practice often exceed
                -- a 30 min budget before quiz; quiz is required for SRS and must still appear.
                BEGIN
                    DECLARE @QCOUNT INT;
                    SELECT @QCOUNT = COUNT(*)
                    FROM QUIZ_QUESTION_MASTER
                    WHERE TOPICID = @NEWTOPICID AND ISACTIVE = 1;

                    IF @QCOUNT >= 2
                    BEGIN
                        INSERT INTO DAILY_LEARNING_PLAN
                        (USERID, PLANDATE, PLANTYPE, PLANSLOT, TOPICID, CONTENTID, QUIZREQUIRED, DAYID)
                        VALUES
                        (@USERID, @PLANDATE, 'NEW', 'QUIZ', @NEWTOPICID, NULL, 1, @EFFECTIVEDAYID);

                        SET @MINUTESUSED = @MINUTESUSED + 5;
                    END
                END
            END
        END

        COMMIT TRANSACTION;

        --================================================
        -- 6. Return generated plan
        --================================================
        SELECT
            0 AS ErrorCode,
            'SUCCESS' AS Status,
            'GENERATED' AS Action;

        SELECT
            DLP.PLANID,
            DLP.PLANDATE,
            DLP.PLANTYPE,
            DLP.PLANSLOT,
            DLP.STATUS,
            DLP.TOPICID,
            TM.TOPICNAME,
            TM.TOPICKEY,
            LP.PATHNAME,
            LP.PATHEMOJI,
            DLP.CONTENTID,
            CI.TITLE AS CONTENTTITLE,
            CI.CONTENTTYPE,
            CI.EXTERNALURL,
            CI.PLATFORMCODE,
            CI.DIFFICULTY,
            COALESCE(CI.ESTIMATEDMINUTES, 10) AS ESTIMATEDMINUTES,
            CASE WHEN DLP.PLANSLOT = 'THEORY' THEN TM.THEORYMARKDOWN ELSE NULL END AS THEORYMARKDOWN,
            DLP.QUIZREQUIRED,
            DLP.QUIZPASSED,
            DLP.QUIZSCOREPERCENT,
            DLP.COMPLETEDAT,
            DLP.DAYID
        FROM DAILY_LEARNING_PLAN DLP
        INNER JOIN TOPIC_MASTER TM ON DLP.TOPICID = TM.TOPICID
        INNER JOIN LEARNING_PATH_MASTER LP ON TM.PATHID = LP.PATHID
        LEFT JOIN CONTENT_ITEM CI ON DLP.CONTENTID = CI.CONTENTID
        WHERE DLP.USERID = @USERID
          AND DLP.PLANDATE = @PLANDATE
        ORDER BY
            CASE DLP.PLANSLOT
                WHEN 'REVIEW' THEN 1
                WHEN 'RECAP' THEN 2
                WHEN 'THEORY' THEN 3
                WHEN 'PRACTICE' THEN 4
                WHEN 'QUIZ' THEN 5
                ELSE 6
            END;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            99 AS ErrorCode,
            'INTERNAL_ERROR' AS ErrorType,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_NUMBER() AS SqlErrorNumber,
            ERROR_LINE() AS SqlErrorLine;
    END CATCH
END
GO

-- ============================================================
-- USP_GET_OR_CREATE_DAILY_LEARNING_PLAN
-- Idempotent wrapper: returns existing plan or generates new one.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_OR_CREATE_DAILY_LEARNING_PLAN]
(
    @USERID INT,
    @PLANDATE DATE = NULL,
    @DAYID INT = NULL,
    @MAXNONMASTEREDTOPICS INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @PLANDATE IS NULL
        SET @PLANDATE = CAST(GETUTCDATE() AS DATE);

    -- Check if guided learning is enabled
    IF NOT EXISTS (
        SELECT 1 FROM USER_LEARNING_PROFILE
        WHERE USERID = @USERID AND GUIDEDENABLED = 1
    )
    BEGIN
        SELECT
            2 AS ErrorCode,
            'GUIDED_DISABLED' AS ErrorType,
            'Guided learning is not enabled for this user' AS ErrorMessage;
        RETURN;
    END

    -- Non-negotiable checklist must exist before we return or create a study plan
    IF NOT EXISTS (
        SELECT 1
        FROM [DAILY_EXECUTION].[dbo].[USERDAY] ud
        INNER JOIN [DAILY_EXECUTION].[dbo].[DAYCHECKLISTITEM] dci ON dci.DAYID = ud.DAYID
        WHERE ud.USERID = @USERID
          AND CAST(ud.DAYDATE AS DATE) = CAST(@PLANDATE AS DATE)
    )
    BEGIN
        SELECT
            4 AS ErrorCode,
            'NO_NON_NEGOTIABLES' AS ErrorType,
            'No daily non-negotiable checklist for this date' AS ErrorMessage;
        RETURN;
    END

    -- If plan exists, return it
    IF EXISTS (
        SELECT 1 FROM DAILY_LEARNING_PLAN
        WHERE USERID = @USERID AND PLANDATE = @PLANDATE
    )
    BEGIN
        SELECT
            0 AS ErrorCode,
            'SUCCESS' AS Status,
            'EXISTING' AS Action;

        SELECT
            DLP.PLANID,
            DLP.PLANDATE,
            DLP.PLANTYPE,
            DLP.PLANSLOT,
            DLP.STATUS,
            DLP.TOPICID,
            TM.TOPICNAME,
            TM.TOPICKEY,
            LP.PATHNAME,
            LP.PATHEMOJI,
            DLP.CONTENTID,
            CI.TITLE AS CONTENTTITLE,
            CI.CONTENTTYPE,
            CI.EXTERNALURL,
            CI.PLATFORMCODE,
            CI.DIFFICULTY,
            COALESCE(CI.ESTIMATEDMINUTES, 10) AS ESTIMATEDMINUTES,
            CASE WHEN DLP.PLANSLOT = 'THEORY' THEN TM.THEORYMARKDOWN ELSE NULL END AS THEORYMARKDOWN,
            DLP.QUIZREQUIRED,
            DLP.QUIZPASSED,
            DLP.QUIZSCOREPERCENT,
            DLP.COMPLETEDAT,
            DLP.DAYID
        FROM DAILY_LEARNING_PLAN DLP
        INNER JOIN TOPIC_MASTER TM ON DLP.TOPICID = TM.TOPICID
        INNER JOIN LEARNING_PATH_MASTER LP ON TM.PATHID = LP.PATHID
        LEFT JOIN CONTENT_ITEM CI ON DLP.CONTENTID = CI.CONTENTID
        WHERE DLP.USERID = @USERID
          AND DLP.PLANDATE = @PLANDATE
        ORDER BY
            CASE DLP.PLANSLOT
                WHEN 'REVIEW' THEN 1
                WHEN 'RECAP' THEN 2
                WHEN 'THEORY' THEN 3
                WHEN 'PRACTICE' THEN 4
                WHEN 'QUIZ' THEN 5
                ELSE 6
            END;

        RETURN;
    END

    -- Plan doesn't exist — generate
    EXEC USP_GENERATE_DAILY_LEARNING_PLAN
        @USERID = @USERID,
        @PLANDATE = @PLANDATE,
        @DAYID = @DAYID,
        @MAXNONMASTEREDTOPICS = @MAXNONMASTEREDTOPICS;
END
GO

-- ============================================================
-- USP_GET_DAILY_PLAN_FOR_DATE
-- Reads plan rows with joined details + spaced-repetition progress.
-- Supports optional @PLANID for single-row fetch.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_DAILY_PLAN_FOR_DATE]
(
    @USERID INT,
    @PLANDATE DATE = NULL,
    @PLANID INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @PLANID IS NULL AND @PLANDATE IS NULL
    BEGIN
        SELECT
            1 AS ErrorCode,
            'MISSING_PARAMS' AS ErrorType,
            'Either planDate or planId is required' AS ErrorMessage;
        RETURN;
    END

    SELECT
        DLP.PLANID,
        DLP.PLANDATE,
        DLP.PLANTYPE,
        DLP.PLANSLOT,
        DLP.STATUS,
        DLP.TOPICID,
        TM.TOPICNAME,
        TM.TOPICKEY,
        LP.PATHNAME,
        LP.PATHEMOJI,
        DLP.CONTENTID,
        CI.TITLE AS CONTENTTITLE,
        CI.CONTENTTYPE,
        CI.EXTERNALURL,
        CI.PLATFORMCODE,
        CI.DIFFICULTY,
        COALESCE(CI.ESTIMATEDMINUTES, 10) AS ESTIMATEDMINUTES,
        CASE
            WHEN DLP.PLANSLOT IN (N'THEORY', N'REVIEW', N'RECAP') THEN TM.THEORYMARKDOWN
            ELSE NULL
        END AS THEORYMARKDOWN,
        DLP.QUIZREQUIRED,
        DLP.QUIZPASSED,
        DLP.QUIZSCOREPERCENT,
        DLP.COMPLETEDAT,
        DLP.DAYID,
        UTP.PROGRESSID,
        UTP.LEITNERBOX,
        UTP.MASTERYLEVEL,
        UTP.NEXTREVIEWDATE,
        UTP.ATTEMPTCOUNT,
        UTP.LASTQUIZSCORE,
        UTP.CONTENTINDEX,
        UTP.LASTATTEMPTEDAT,
        CASE UTP.LEITNERBOX
            WHEN 1 THEN 1
            WHEN 2 THEN 3
            WHEN 3 THEN 7
            WHEN 4 THEN 14
            ELSE 1
        END AS REVIEWINTERVALDAYS
    FROM DAILY_LEARNING_PLAN DLP
    INNER JOIN TOPIC_MASTER TM ON DLP.TOPICID = TM.TOPICID
    INNER JOIN LEARNING_PATH_MASTER LP ON TM.PATHID = LP.PATHID
    LEFT JOIN CONTENT_ITEM CI ON DLP.CONTENTID = CI.CONTENTID
    LEFT JOIN USER_TOPIC_PROGRESS UTP
        ON UTP.USERID = DLP.USERID
       AND UTP.TOPICID = DLP.TOPICID
    WHERE DLP.USERID = @USERID
      AND (@PLANID IS NULL OR DLP.PLANID = @PLANID)
      AND (@PLANDATE IS NULL OR DLP.PLANDATE = @PLANDATE)
    ORDER BY
        CASE DLP.PLANSLOT
            WHEN 'REVIEW' THEN 1
            WHEN 'RECAP' THEN 2
            WHEN 'THEORY' THEN 3
            WHEN 'PRACTICE' THEN 4
            WHEN 'QUIZ' THEN 5
            ELSE 6
        END;
END
GO

-- ============================================================
-- USP_UPDATE_DAILY_PLAN_STATUS
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_UPDATE_DAILY_PLAN_STATUS]
(
    @USERID INT,
    @PLANID INT,
    @NEWSTATUS NVARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CURRENTSTATUS NVARCHAR(20);
    DECLARE @PLANOWNERID INT;
    DECLARE @PLANSLOT NVARCHAR(20);
    DECLARE @PLANTYPE NVARCHAR(20);
    DECLARE @TOPICID INT;
    DECLARE @PLANDATE DATE;

    SELECT
        @PLANOWNERID = USERID,
        @CURRENTSTATUS = STATUS,
        @PLANSLOT = PLANSLOT,
        @PLANTYPE = PLANTYPE,
        @TOPICID = TOPICID,
        @PLANDATE = PLANDATE
    FROM DAILY_LEARNING_PLAN
    WHERE PLANID = @PLANID;

    IF @PLANOWNERID IS NULL
    BEGIN
        SELECT
            1 AS ErrorCode,
            'PLAN_NOT_FOUND' AS ErrorType,
            'Plan item not found' AS ErrorMessage;
        RETURN;
    END

    IF @PLANOWNERID != @USERID
    BEGIN
        SELECT
            2 AS ErrorCode,
            'UNAUTHORIZED' AS ErrorType,
            'This plan does not belong to the user' AS ErrorMessage;
        RETURN;
    END

    IF @CURRENTSTATUS = 'COMPLETED'
    BEGIN
        SELECT
            3 AS ErrorCode,
            'ALREADY_COMPLETED' AS ErrorType,
            'This plan item is already completed' AS ErrorMessage;
        RETURN;
    END

    -- Validate transition
    IF @CURRENTSTATUS = 'PENDING' AND @NEWSTATUS NOT IN ('IN_PROGRESS', 'SKIPPED')
    BEGIN
        SELECT
            4 AS ErrorCode,
            'INVALID_TRANSITION' AS ErrorType,
            'From PENDING, status can only move to IN_PROGRESS or SKIPPED' AS ErrorMessage;
        RETURN;
    END

    IF @CURRENTSTATUS = 'IN_PROGRESS' AND @NEWSTATUS NOT IN ('COMPLETED', 'SKIPPED')
    BEGIN
        SELECT
            4 AS ErrorCode,
            'INVALID_TRANSITION' AS ErrorType,
            'From IN_PROGRESS, status can only move to COMPLETED or SKIPPED' AS ErrorMessage;
        RETURN;
    END

    UPDATE DAILY_LEARNING_PLAN
    SET STATUS = @NEWSTATUS,
        COMPLETEDAT = CASE WHEN @NEWSTATUS = 'COMPLETED' THEN SYSUTCDATETIME() ELSE NULL END,
        SKIPPEDAT = CASE WHEN @NEWSTATUS = 'SKIPPED' THEN SYSUTCDATETIME() ELSE NULL END,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PLANID = @PLANID;

    DECLARE @NEWBOX INT = NULL;
    DECLARE @NEWMASTERY NVARCHAR(20) = NULL;
    DECLARE @NEWREVIEWDATE DATE = NULL;

    IF @NEWSTATUS = 'COMPLETED'
       AND (@PLANSLOT = N'REVIEW' OR @PLANTYPE = N'REVIEW')
       AND @TOPICID IS NOT NULL
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM USER_TOPIC_PROGRESS
            WHERE USERID = @USERID AND TOPICID = @TOPICID
        )
        BEGIN
            INSERT INTO USER_TOPIC_PROGRESS (USERID, TOPICID)
            VALUES (@USERID, @TOPICID);
        END

        DECLARE @CURRENTBOX INT;
        DECLARE @CURRENTMASTERY NVARCHAR(20);

        SELECT
            @CURRENTBOX = LEITNERBOX,
            @CURRENTMASTERY = MASTERYLEVEL
        FROM USER_TOPIC_PROGRESS
        WHERE USERID = @USERID AND TOPICID = @TOPICID;

        SET @NEWBOX = ISNULL(@CURRENTBOX, 1);
        SET @NEWMASTERY = ISNULL(@CURRENTMASTERY, N'BEGINNER');

        SET @NEWREVIEWDATE = DATEADD(
            DAY,
            CASE @NEWBOX
                WHEN 1 THEN 1
                WHEN 2 THEN 3
                WHEN 3 THEN 7
                WHEN 4 THEN 14
                ELSE 1
            END,
            ISNULL(@PLANDATE, CAST(SYSUTCDATETIME() AS DATE))
        );

        UPDATE USER_TOPIC_PROGRESS
        SET NEXTREVIEWDATE = @NEWREVIEWDATE,
            LASTATTEMPTEDAT = SYSUTCDATETIME(),
            UPDATEDDATE = SYSUTCDATETIME()
        WHERE USERID = @USERID AND TOPICID = @TOPICID;
    END

    IF @NEWSTATUS = 'SKIPPED'
       AND (@PLANSLOT = N'REVIEW' OR @PLANTYPE = N'REVIEW')
       AND @TOPICID IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1 FROM USER_TOPIC_PROGRESS
            WHERE USERID = @USERID AND TOPICID = @TOPICID
        )
        BEGIN
            UPDATE USER_TOPIC_PROGRESS
            SET NEXTREVIEWDATE = DATEADD(DAY, 1, ISNULL(@PLANDATE, CAST(SYSUTCDATETIME() AS DATE))),
                UPDATEDDATE = SYSUTCDATETIME()
            WHERE USERID = @USERID AND TOPICID = @TOPICID;

            SELECT
                @NEWBOX = LEITNERBOX,
                @NEWMASTERY = MASTERYLEVEL,
                @NEWREVIEWDATE = NEXTREVIEWDATE
            FROM USER_TOPIC_PROGRESS
            WHERE USERID = @USERID AND TOPICID = @TOPICID;
        END
    END

    SELECT
        0 AS ErrorCode,
        'SUCCESS' AS Status,
        @NEWBOX AS NewLeitnerBox,
        @NEWMASTERY AS NewMasteryLevel,
        @NEWREVIEWDATE AS NextReviewDate;
END
GO
