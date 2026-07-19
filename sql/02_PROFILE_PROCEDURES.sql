USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_UPSERT_USER_LEARNING_PROFILE
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_UPSERT_USER_LEARNING_PROFILE]
(
    @USERID INT,
    @GUIDEDENABLED BIT,
    @SKILLLEVEL NVARCHAR(20),
    @DAILYMINUTES INT,
    @LEARNINGGOAL NVARCHAR(30)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM USER_LEARNING_PROFILE WHERE USERID = @USERID)
        BEGIN
            UPDATE USER_LEARNING_PROFILE
            SET GUIDEDENABLED = @GUIDEDENABLED,
                SKILLLEVEL = @SKILLLEVEL,
                DAILYMINUTES = @DAILYMINUTES,
                LEARNINGGOAL = @LEARNINGGOAL,
                UPDATEDDATE = SYSUTCDATETIME()
            WHERE USERID = @USERID;

            SELECT
                0 AS ErrorCode,
                'UPDATED' AS Action,
                'Profile updated' AS Message;
        END
        ELSE
        BEGIN
            INSERT INTO USER_LEARNING_PROFILE
            (USERID, GUIDEDENABLED, SKILLLEVEL, DAILYMINUTES, LEARNINGGOAL)
            VALUES
            (@USERID, @GUIDEDENABLED, @SKILLLEVEL, @DAILYMINUTES, @LEARNINGGOAL);

            SELECT
                0 AS ErrorCode,
                'CREATED' AS Action,
                'Profile created' AS Message;
        END
    END TRY
    BEGIN CATCH
        SELECT
            99 AS ErrorCode,
            'INTERNAL_ERROR' AS ErrorType,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ============================================================
-- USP_GET_USER_LEARNING_PROFILE
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_USER_LEARNING_PROFILE]
(
    @USERID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM USER_LEARNING_PROFILE WHERE USERID = @USERID)
    BEGIN
        SELECT
            1 AS ErrorCode,
            'NO_PROFILE' AS ErrorType,
            'No learning profile found for user' AS ErrorMessage;
        RETURN;
    END

    SELECT
        PROFILEID,
        USERID,
        GUIDEDENABLED,
        SKILLLEVEL,
        DAILYMINUTES,
        LEARNINGGOAL,
        CREATEDDATE,
        UPDATEDDATE
    FROM USER_LEARNING_PROFILE
    WHERE USERID = @USERID;
END
GO

-- ============================================================
-- USP_SET_USER_PATH_ENROLLMENTS
-- Replaces all active enrollments for user with the provided JSON list.
-- @MAXACTIVEPATHS: max paths in payload; NULL = unlimited
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_SET_USER_PATH_ENROLLMENTS]
(
    @USERID INT,
    @ENROLLMENTSJSON NVARCHAR(MAX),
    @MAXACTIVEPATHS INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate paths exist
        IF EXISTS (
            SELECT 1
            FROM OPENJSON(@ENROLLMENTSJSON)
            WITH (pathId INT '$.pathId') J
            LEFT JOIN LEARNING_PATH_MASTER LP ON LP.PATHID = J.pathId AND LP.ISACTIVE = 1
            WHERE LP.PATHID IS NULL
        )
        BEGIN
            SELECT
                1 AS ErrorCode,
                'INVALID_PATH_ID' AS ErrorType,
                'One or more path IDs are invalid or inactive' AS ErrorMessage;
            ROLLBACK;
            RETURN;
        END

        DECLARE @COUNT INT = (SELECT COUNT(*) FROM OPENJSON(@ENROLLMENTSJSON));
        IF @MAXACTIVEPATHS IS NOT NULL AND @COUNT > @MAXACTIVEPATHS
        BEGIN
            SELECT
                2 AS ErrorCode,
                'PATH_LIMIT_REACHED' AS ErrorType,
                N'Path enrollment limit reached for your plan. Upgrade to enroll in more paths.' AS ErrorMessage,
                @MAXACTIVEPATHS AS MaxPaths,
                @COUNT AS RequestedPathCount;
            ROLLBACK;
            RETURN;
        END

        -- Deactivate existing
        UPDATE USER_PATH_ENROLLMENT
        SET ISACTIVE = 0, UPDATEDDATE = SYSUTCDATETIME()
        WHERE USERID = @USERID AND ISACTIVE = 1;

        -- Insert or reactivate
        MERGE USER_PATH_ENROLLMENT AS T
        USING (
            SELECT
                @USERID AS USERID,
                CAST(JSON_VALUE(value, '$.pathId') AS INT) AS PATHID,
                CAST(JSON_VALUE(value, '$.priorityOrder') AS INT) AS PRIORITYORDER
            FROM OPENJSON(@ENROLLMENTSJSON)
        ) AS S
        ON T.USERID = S.USERID AND T.PATHID = S.PATHID
        WHEN MATCHED THEN
            UPDATE SET
                ISACTIVE = 1,
                PRIORITYORDER = S.PRIORITYORDER,
                UPDATEDDATE = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (USERID, PATHID, PRIORITYORDER)
            VALUES (S.USERID, S.PATHID, S.PRIORITYORDER);

        COMMIT TRANSACTION;

        SELECT
            0 AS ErrorCode,
            'SUCCESS' AS Status,
            @COUNT AS EnrolledCount;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT
            99 AS ErrorCode,
            'INTERNAL_ERROR' AS ErrorType,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ============================================================
-- USP_GET_USER_PATH_ENROLLMENTS
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_USER_PATH_ENROLLMENTS]
(
    @USERID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UPE.ENROLLMENTID,
        UPE.PATHID,
        LP.PATHKEY,
        LP.PATHNAME,
        LP.PATHEMOJI,
        UPE.PRIORITYORDER,
        UPE.ISACTIVE,
        UPE.ENROLLEDDATE
    FROM USER_PATH_ENROLLMENT UPE
    INNER JOIN LEARNING_PATH_MASTER LP ON UPE.PATHID = LP.PATHID
    WHERE UPE.USERID = @USERID
      AND UPE.ISACTIVE = 1
    ORDER BY UPE.PRIORITYORDER ASC;
END
GO
