USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_ADMIN_UPSERT_CONTENT_JSON
-- Bulk insert/update catalog data from a JSON payload.
-- Expected JSON format:
-- {
--   "paths": [{ "pathKey": "DSA", "pathName": "...", "pathEmoji": "...", "displayOrder": 1, "description": "..." }],
--   "topics": [{ "pathKey": "DSA", "topicKey": "ARRAYS", "topicName": "...", "difficultyTier": "BEGINNER", ... }],
--   "content": [{ "topicKey": "ARRAYS", "contentType": "PROBLEM", "title": "...", "externalUrl": "...", ... }],
--   "questions": [{ "topicKey": "ARRAYS", "questionText": "...", "optionA": "...", ... }]
-- }
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_ADMIN_UPSERT_CONTENT_JSON]
(
    @CONTENTJSON NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PATHCOUNT INT = 0;
        DECLARE @TOPICCOUNT INT = 0;
        DECLARE @CONTENTCOUNT INT = 0;
        DECLARE @QUESTIONCOUNT INT = 0;

        --================================================
        -- 1. Upsert paths
        --================================================
        MERGE LEARNING_PATH_MASTER AS T
        USING (
            SELECT
                JSON_VALUE(value, '$.pathKey') AS PATHKEY,
                JSON_VALUE(value, '$.pathName') AS PATHNAME,
                JSON_VALUE(value, '$.pathEmoji') AS PATHEMOJI,
                CAST(JSON_VALUE(value, '$.displayOrder') AS INT) AS DISPLAYORDER,
                JSON_VALUE(value, '$.description') AS DESCRIPTION
            FROM OPENJSON(@CONTENTJSON, '$.paths')
        ) AS S
        ON T.PATHKEY = S.PATHKEY
        WHEN MATCHED THEN
            UPDATE SET
                PATHNAME = S.PATHNAME,
                PATHEMOJI = ISNULL(S.PATHEMOJI, T.PATHEMOJI),
                DISPLAYORDER = ISNULL(S.DISPLAYORDER, T.DISPLAYORDER),
                DESCRIPTION = ISNULL(S.DESCRIPTION, T.DESCRIPTION),
                UPDATEDDATE = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (PATHKEY, PATHNAME, PATHEMOJI, DISPLAYORDER, DESCRIPTION)
            VALUES (S.PATHKEY, S.PATHNAME, S.PATHEMOJI, S.DISPLAYORDER, S.DESCRIPTION);

        SET @PATHCOUNT = @@ROWCOUNT;

        --================================================
        -- 2. Upsert topics
        --================================================
        MERGE TOPIC_MASTER AS T
        USING (
            SELECT
                LP.PATHID,
                JSON_VALUE(value, '$.topicKey') AS TOPICKEY,
                JSON_VALUE(value, '$.topicName') AS TOPICNAME,
                JSON_VALUE(value, '$.description') AS DESCRIPTION,
                JSON_VALUE(value, '$.difficultyTier') AS DIFFICULTYTIER,
                CAST(JSON_VALUE(value, '$.estimatedMinutes') AS INT) AS ESTIMATEDMINUTES,
                CAST(JSON_VALUE(value, '$.displayOrder') AS INT) AS DISPLAYORDER,
                JSON_VALUE(value, '$.theoryMarkdown') AS THEORYMARKDOWN,
                (SELECT TM2.TOPICID FROM TOPIC_MASTER TM2 WHERE TM2.TOPICKEY = JSON_VALUE(value, '$.prerequisiteTopicKey')) AS PREREQUISITETOPICID
            FROM OPENJSON(@CONTENTJSON, '$.topics') J
            INNER JOIN LEARNING_PATH_MASTER LP ON LP.PATHKEY = JSON_VALUE(value, '$.pathKey')
        ) AS S
        ON T.TOPICKEY = S.TOPICKEY AND T.PATHID = S.PATHID
        WHEN MATCHED THEN
            UPDATE SET
                TOPICNAME = S.TOPICNAME,
                DESCRIPTION = ISNULL(S.DESCRIPTION, T.DESCRIPTION),
                DIFFICULTYTIER = ISNULL(S.DIFFICULTYTIER, T.DIFFICULTYTIER),
                ESTIMATEDMINUTES = ISNULL(S.ESTIMATEDMINUTES, T.ESTIMATEDMINUTES),
                DISPLAYORDER = ISNULL(S.DISPLAYORDER, T.DISPLAYORDER),
                THEORYMARKDOWN = ISNULL(S.THEORYMARKDOWN, T.THEORYMARKDOWN),
                PREREQUISITETOPICID = S.PREREQUISITETOPICID,
                UPDATEDDATE = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, ESTIMATEDMINUTES, DISPLAYORDER, THEORYMARKDOWN, PREREQUISITETOPICID)
            VALUES (S.PATHID, S.TOPICKEY, S.TOPICNAME, S.DESCRIPTION, S.DIFFICULTYTIER, S.ESTIMATEDMINUTES, S.DISPLAYORDER, S.THEORYMARKDOWN, S.PREREQUISITETOPICID);

        SET @TOPICCOUNT = @@ROWCOUNT;

        --================================================
        -- 3. Insert content items (append-only, no update)
        --================================================
        INSERT INTO CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, ESTIMATEDMINUTES, DISPLAYORDER)
        SELECT
            TM.TOPICID,
            JSON_VALUE(value, '$.contentType'),
            JSON_VALUE(value, '$.title'),
            JSON_VALUE(value, '$.summary'),
            JSON_VALUE(value, '$.externalUrl'),
            JSON_VALUE(value, '$.platformCode'),
            JSON_VALUE(value, '$.difficulty'),
            CAST(JSON_VALUE(value, '$.estimatedMinutes') AS INT),
            CAST(JSON_VALUE(value, '$.displayOrder') AS INT)
        FROM OPENJSON(@CONTENTJSON, '$.content') J
        INNER JOIN TOPIC_MASTER TM ON TM.TOPICKEY = JSON_VALUE(value, '$.topicKey')
        WHERE NOT EXISTS (
            SELECT 1 FROM CONTENT_ITEM CI
            WHERE CI.TOPICID = TM.TOPICID
              AND CI.EXTERNALURL = JSON_VALUE(value, '$.externalUrl')
        );

        SET @CONTENTCOUNT = @@ROWCOUNT;

        --================================================
        -- 4. Insert quiz questions (append-only)
        --================================================
        INSERT INTO QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND, CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER)
        SELECT
            TM.TOPICID,
            NULL,
            JSON_VALUE(value, '$.questionText'),
            JSON_VALUE(value, '$.optionA'),
            JSON_VALUE(value, '$.optionB'),
            JSON_VALUE(value, '$.optionC'),
            JSON_VALUE(value, '$.optionD'),
            JSON_VALUE(value, '$.correctOption'),
            JSON_VALUE(value, '$.explanation'),
            JSON_VALUE(value, '$.difficulty'),
            ISNULL(TRY_CAST(JSON_VALUE(value, '$.displayOrder') AS INT),
                ROW_NUMBER() OVER (PARTITION BY TM.TOPICID ORDER BY (SELECT NULL)))
        FROM OPENJSON(@CONTENTJSON, '$.questions') J
        INNER JOIN TOPIC_MASTER TM ON TM.TOPICKEY = JSON_VALUE(value, '$.topicKey')
        WHERE NOT EXISTS (
            SELECT 1 FROM QUIZ_QUESTION_MASTER QQ
            WHERE QQ.TOPICID = TM.TOPICID
              AND QQ.QUESTIONTEXT = JSON_VALUE(value, '$.questionText')
        );

        SET @QUESTIONCOUNT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT
            0 AS ErrorCode,
            'SUCCESS' AS Status,
            @PATHCOUNT AS PathsUpserted,
            @TOPICCOUNT AS TopicsUpserted,
            @CONTENTCOUNT AS ContentInserted,
            @QUESTIONCOUNT AS QuestionsInserted;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            99 AS ErrorCode,
            'INTERNAL_ERROR' AS ErrorType,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS SqlErrorLine;
    END CATCH
END
GO

-- ============================================================
-- USP_ADMIN_SET_CATALOG_ACTIVE
-- Toggle ISACTIVE on any catalog entity by type and ID.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_ADMIN_SET_CATALOG_ACTIVE]
(
    @ENTITYTYPE NVARCHAR(20),   -- PATH, TOPIC, CONTENT, QUESTION
    @ENTITYID INT,
    @ISACTIVE BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @ENTITYTYPE = 'PATH'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM LEARNING_PATH_MASTER WHERE PATHID = @ENTITYID)
        BEGIN
            SELECT 1 AS ErrorCode, 'NOT_FOUND' AS ErrorType, 'Path not found' AS ErrorMessage;
            RETURN;
        END
        UPDATE LEARNING_PATH_MASTER SET ISACTIVE = @ISACTIVE, UPDATEDDATE = SYSUTCDATETIME() WHERE PATHID = @ENTITYID;
    END
    ELSE IF @ENTITYTYPE = 'TOPIC'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM TOPIC_MASTER WHERE TOPICID = @ENTITYID)
        BEGIN
            SELECT 1 AS ErrorCode, 'NOT_FOUND' AS ErrorType, 'Topic not found' AS ErrorMessage;
            RETURN;
        END
        UPDATE TOPIC_MASTER SET ISACTIVE = @ISACTIVE, UPDATEDDATE = SYSUTCDATETIME() WHERE TOPICID = @ENTITYID;
    END
    ELSE IF @ENTITYTYPE = 'CONTENT'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM CONTENT_ITEM WHERE CONTENTID = @ENTITYID)
        BEGIN
            SELECT 1 AS ErrorCode, 'NOT_FOUND' AS ErrorType, 'Content not found' AS ErrorMessage;
            RETURN;
        END
        UPDATE CONTENT_ITEM SET ISACTIVE = @ISACTIVE, UPDATEDDATE = SYSUTCDATETIME() WHERE CONTENTID = @ENTITYID;
    END
    ELSE IF @ENTITYTYPE = 'QUESTION'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM QUIZ_QUESTION_MASTER WHERE QUESTIONID = @ENTITYID)
        BEGIN
            SELECT 1 AS ErrorCode, 'NOT_FOUND' AS ErrorType, 'Question not found' AS ErrorMessage;
            RETURN;
        END
        UPDATE QUIZ_QUESTION_MASTER SET ISACTIVE = @ISACTIVE, UPDATEDDATE = SYSUTCDATETIME() WHERE QUESTIONID = @ENTITYID;
    END
    ELSE
    BEGIN
        SELECT 2 AS ErrorCode, 'INVALID_ENTITY_TYPE' AS ErrorType,
               'entityType must be PATH, TOPIC, CONTENT, or QUESTION' AS ErrorMessage;
        RETURN;
    END

    SELECT 0 AS ErrorCode, 'SUCCESS' AS Status;
END
GO
