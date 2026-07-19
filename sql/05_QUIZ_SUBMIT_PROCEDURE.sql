USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_SUBMIT_LEARNING_QUIZ
-- Validates answers, records attempts, computes score,
-- updates Leitner box + mastery + nextReviewDate.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_SUBMIT_LEARNING_QUIZ]
(
    @USERID INT,
    @PLANID INT,
    @ANSWERSJSON NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @TOPICID INT;
        DECLARE @PLANOWNERID INT;
        DECLARE @PLANSTATUS NVARCHAR(20);
        DECLARE @PLANQUIZREQUIRED BIT;
        DECLARE @PLANDATE DATE;

        --================================================
        -- 1. Validate plan
        --================================================
        SELECT
            @PLANOWNERID = USERID,
            @TOPICID = TOPICID,
            @PLANSTATUS = STATUS,
            @PLANQUIZREQUIRED = QUIZREQUIRED,
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

        IF @PLANSTATUS = 'COMPLETED'
        BEGIN
            SELECT
                3 AS ErrorCode,
                'ALREADY_COMPLETED' AS ErrorType,
                'Quiz already submitted for this plan item' AS ErrorMessage;
            RETURN;
        END

        --================================================
        -- 2. Parse answers and validate
        --================================================
        DECLARE @ANSWERS TABLE (
            QUESTIONID INT,
            SELECTEDOPTION NVARCHAR(2)
        );

        INSERT INTO @ANSWERS (QUESTIONID, SELECTEDOPTION)
        SELECT
            CAST(JSON_VALUE(value, '$.questionId') AS INT),
            JSON_VALUE(value, '$.selectedOption')
        FROM OPENJSON(@ANSWERSJSON);

        IF NOT EXISTS (SELECT 1 FROM @ANSWERS)
        BEGIN
            SELECT
                4 AS ErrorCode,
                'NO_ANSWERS' AS ErrorType,
                'No valid answers provided' AS ErrorMessage;
            RETURN;
        END

        -- Validate all questions belong to this topic
        IF EXISTS (
            SELECT 1 FROM @ANSWERS A
            LEFT JOIN QUIZ_QUESTION_MASTER QQ ON A.QUESTIONID = QQ.QUESTIONID
            WHERE QQ.QUESTIONID IS NULL OR QQ.TOPICID != @TOPICID
        )
        BEGIN
            SELECT
                5 AS ErrorCode,
                'INVALID_QUESTIONS' AS ErrorType,
                'One or more questions do not belong to this topic' AS ErrorMessage;
            RETURN;
        END

        BEGIN TRANSACTION;

        --================================================
        -- 3. Insert quiz attempts and compute correctness
        --================================================
        DECLARE @RESULTS TABLE (
            QUESTIONID INT,
            SELECTEDOPTION NVARCHAR(2),
            CORRECTOPTION NVARCHAR(2),
            ISCORRECT BIT,
            EXPLANATION NVARCHAR(MAX)
        );

        INSERT INTO @RESULTS (QUESTIONID, SELECTEDOPTION, CORRECTOPTION, ISCORRECT, EXPLANATION)
        SELECT
            A.QUESTIONID,
            A.SELECTEDOPTION,
            QQ.CORRECTOPTION,
            CASE WHEN A.SELECTEDOPTION = QQ.CORRECTOPTION THEN 1 ELSE 0 END,
            QQ.EXPLANATION
        FROM @ANSWERS A
        INNER JOIN QUIZ_QUESTION_MASTER QQ ON A.QUESTIONID = QQ.QUESTIONID;

        INSERT INTO LEARNING_QUIZ_ATTEMPT
        (USERID, PLANID, QUESTIONID, SELECTEDOPTION, ISCORRECT)
        SELECT
            @USERID,
            @PLANID,
            R.QUESTIONID,
            R.SELECTEDOPTION,
            R.ISCORRECT
        FROM @RESULTS R;

        --================================================
        -- 4. Compute score
        --================================================
        DECLARE @TOTAL INT = (SELECT COUNT(*) FROM @RESULTS);
        DECLARE @CORRECT INT = (SELECT SUM(CAST(ISCORRECT AS INT)) FROM @RESULTS);
        DECLARE @SCOREPERCENT DECIMAL(5,2) = CASE WHEN @TOTAL > 0 THEN (@CORRECT * 100.0) / @TOTAL ELSE 0 END;
        DECLARE @PASSED BIT = CASE WHEN @SCOREPERCENT >= 70 THEN 1 ELSE 0 END;

        --================================================
        -- 5. Update plan item
        --================================================
        UPDATE DAILY_LEARNING_PLAN
        SET STATUS = 'COMPLETED',
            QUIZPASSED = @PASSED,
            QUIZSCOREPERCENT = @SCOREPERCENT,
            COMPLETEDAT = SYSUTCDATETIME(),
            UPDATEDDATE = SYSUTCDATETIME()
        WHERE PLANID = @PLANID;

        --================================================
        -- 6. Update topic progress (Leitner box logic)
        --================================================
        DECLARE @CURRENTBOX INT;
        DECLARE @CURRENTMASTERY NVARCHAR(20);
        DECLARE @CURRENTCONTENTINDEX INT;
        DECLARE @NEWBOX INT;
        DECLARE @NEWMASTERY NVARCHAR(20);
        DECLARE @NEWREVIEWDATE DATE;

        -- Ensure progress row exists
        IF NOT EXISTS (
            SELECT 1 FROM USER_TOPIC_PROGRESS
            WHERE USERID = @USERID AND TOPICID = @TOPICID
        )
        BEGIN
            INSERT INTO USER_TOPIC_PROGRESS (USERID, TOPICID)
            VALUES (@USERID, @TOPICID);
        END

        SELECT
            @CURRENTBOX = LEITNERBOX,
            @CURRENTMASTERY = MASTERYLEVEL,
            @CURRENTCONTENTINDEX = CONTENTINDEX
        FROM USER_TOPIC_PROGRESS
        WHERE USERID = @USERID AND TOPICID = @TOPICID;

        -- Leitner box transitions:
        --   >= 80%: box up (max 4 = mastered)
        --   50-79%: stay in same box
        --   < 50% : box down (min 1)
        IF @SCOREPERCENT >= 80
            SET @NEWBOX = CASE WHEN @CURRENTBOX < 4 THEN @CURRENTBOX + 1 ELSE 4 END;
        ELSE IF @SCOREPERCENT >= 50
            SET @NEWBOX = @CURRENTBOX;
        ELSE
            SET @NEWBOX = CASE WHEN @CURRENTBOX > 1 THEN @CURRENTBOX - 1 ELSE 1 END;

        -- Mastery from box
        SET @NEWMASTERY = CASE @NEWBOX
            WHEN 1 THEN 'BEGINNER'
            WHEN 2 THEN 'FAMILIAR'
            WHEN 3 THEN 'PROFICIENT'
            WHEN 4 THEN 'MASTERED'
            ELSE 'BEGINNER'
        END;

        -- Review interval from box (Leitner spacing)
        --   Box 1: next day, Box 2: 3 days, Box 3: 7 days, Box 4: 14 days
        SET @NEWREVIEWDATE = DATEADD(DAY,
            CASE @NEWBOX
                WHEN 1 THEN 1
                WHEN 2 THEN 3
                WHEN 3 THEN 7
                WHEN 4 THEN 14
                ELSE 1
            END,
            @PLANDATE
        );

        -- Advance content index if passed quiz and was on a new content item
        DECLARE @NEWCONTENTINDEX INT = @CURRENTCONTENTINDEX;
        IF @PASSED = 1
        BEGIN
            DECLARE @PLANCONTENTORDER INT;
            SELECT @PLANCONTENTORDER = CI.DISPLAYORDER
            FROM DAILY_LEARNING_PLAN DLP
            INNER JOIN CONTENT_ITEM CI ON DLP.CONTENTID = CI.CONTENTID
            WHERE DLP.USERID = @USERID
              AND DLP.PLANDATE = (SELECT PLANDATE FROM DAILY_LEARNING_PLAN WHERE PLANID = @PLANID)
              AND DLP.TOPICID = @TOPICID
              AND DLP.PLANSLOT = 'PRACTICE';

            IF @PLANCONTENTORDER IS NOT NULL AND @PLANCONTENTORDER > @CURRENTCONTENTINDEX
                SET @NEWCONTENTINDEX = @PLANCONTENTORDER;
        END

        UPDATE USER_TOPIC_PROGRESS
        SET LEITNERBOX = @NEWBOX,
            LASTQUIZSCORE = @SCOREPERCENT,
            ATTEMPTCOUNT = ATTEMPTCOUNT + 1,
            CONTENTINDEX = @NEWCONTENTINDEX,
            MASTERYLEVEL = @NEWMASTERY,
            NEXTREVIEWDATE = @NEWREVIEWDATE,
            LASTATTEMPTEDAT = SYSUTCDATETIME(),
            UPDATEDDATE = SYSUTCDATETIME()
        WHERE USERID = @USERID AND TOPICID = @TOPICID;

        COMMIT TRANSACTION;

        --================================================
        -- 7. Return results
        --================================================

        -- Score summary
        SELECT
            @SCOREPERCENT AS ScorePercent,
            @TOTAL AS TotalQuestions,
            @CORRECT AS CorrectCount,
            @PASSED AS Passed;

        -- Per-question results (with correct answers + explanations)
        SELECT
            R.QUESTIONID,
            R.SELECTEDOPTION,
            R.CORRECTOPTION,
            R.ISCORRECT,
            R.EXPLANATION
        FROM @RESULTS R
        ORDER BY R.QUESTIONID;

        -- Topic progress update
        SELECT
            @NEWBOX AS NewLeitnerBox,
            @NEWMASTERY AS NewMasteryLevel,
            @NEWREVIEWDATE AS NextReviewDate;

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
