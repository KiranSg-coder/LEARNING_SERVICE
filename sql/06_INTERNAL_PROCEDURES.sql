USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_GET_USERS_NEEDING_LEARNING_PLAN
-- Returns users with GUIDEDENABLED=1 and no plan for @PLANDATE.
-- Used by scheduler to know which users need a batch generate.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_USERS_NEEDING_LEARNING_PLAN]
(
    @PLANDATE DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ULP.USERID
    FROM USER_LEARNING_PROFILE ULP
    WHERE ULP.GUIDEDENABLED = 1
      AND NOT EXISTS (
          SELECT 1 FROM DAILY_LEARNING_PLAN DLP
          WHERE DLP.USERID = ULP.USERID
            AND DLP.PLANDATE = @PLANDATE
      )
      AND EXISTS (
          SELECT 1 FROM USER_PATH_ENROLLMENT UPE
          WHERE UPE.USERID = ULP.USERID AND UPE.ISACTIVE = 1
      );
END
GO

-- ============================================================
-- USP_INTERNAL_BATCH_GENERATE_PLANS
-- Generates daily plans for all (or specified) users.
-- Called by scheduler/cron after midnight.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_INTERNAL_BATCH_GENERATE_PLANS]
(
    @PLANDATE DATE,
    @USERIDSJSON NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @USERSTABLE TABLE (USERID INT);
        DECLARE @TOTALPROCESSED INT = 0;
        DECLARE @TOTALGENERATED INT = 0;
        DECLARE @TOTALSKIPPED INT = 0;

        -- Determine user list
        IF @USERIDSJSON IS NOT NULL
        BEGIN
            INSERT INTO @USERSTABLE (USERID)
            SELECT CAST(value AS INT)
            FROM OPENJSON(@USERIDSJSON);
        END
        ELSE
        BEGIN
            INSERT INTO @USERSTABLE (USERID)
            SELECT ULP.USERID
            FROM USER_LEARNING_PROFILE ULP
            WHERE ULP.GUIDEDENABLED = 1
              AND NOT EXISTS (
                  SELECT 1 FROM DAILY_LEARNING_PLAN DLP
                  WHERE DLP.USERID = ULP.USERID AND DLP.PLANDATE = @PLANDATE
              )
              AND EXISTS (
                  SELECT 1 FROM USER_PATH_ENROLLMENT UPE
                  WHERE UPE.USERID = ULP.USERID AND UPE.ISACTIVE = 1
              );
        END

        DECLARE @CUR_USERID INT;
        DECLARE userCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT USERID FROM @USERSTABLE;

        OPEN userCursor;
        FETCH NEXT FROM userCursor INTO @CUR_USERID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @TOTALPROCESSED = @TOTALPROCESSED + 1;

            -- Skip if plan already exists
            IF EXISTS (
                SELECT 1 FROM DAILY_LEARNING_PLAN
                WHERE USERID = @CUR_USERID AND PLANDATE = @PLANDATE
            )
            BEGIN
                SET @TOTALSKIPPED = @TOTALSKIPPED + 1;
            END
            ELSE
            BEGIN
                BEGIN TRY
                    EXEC USP_GENERATE_DAILY_LEARNING_PLAN
                        @USERID = @CUR_USERID,
                        @PLANDATE = @PLANDATE;

                    SET @TOTALGENERATED = @TOTALGENERATED + 1;
                END TRY
                BEGIN CATCH
                    SET @TOTALSKIPPED = @TOTALSKIPPED + 1;
                END CATCH
            END

            FETCH NEXT FROM userCursor INTO @CUR_USERID;
        END

        CLOSE userCursor;
        DEALLOCATE userCursor;

        SELECT
            0 AS ErrorCode,
            @TOTALPROCESSED AS TotalProcessed,
            @TOTALGENERATED AS TotalGenerated,
            @TOTALSKIPPED AS TotalSkipped;

    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'userCursor') >= 0
        BEGIN
            CLOSE userCursor;
            DEALLOCATE userCursor;
        END

        SELECT
            99 AS ErrorCode,
            'INTERNAL_ERROR' AS ErrorType,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO
