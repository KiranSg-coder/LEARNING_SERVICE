USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_GET_LEARNING_PATHS
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_LEARNING_PATHS]
(
    @PATHKEY NVARCHAR(50) = NULL,
    @ONLYACTIVE BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PATHID,
        PATHKEY,
        PATHNAME,
        DESCRIPTION,
        PATHEMOJI,
        DISPLAYORDER,
        ISACTIVE,
        CREATEDDATE,
        UPDATEDDATE
    FROM dbo.LEARNING_PATH_MASTER
    WHERE
        (@ONLYACTIVE = 0 OR ISACTIVE = 1)
        AND (@PATHKEY IS NULL OR PATHKEY = @PATHKEY)
    ORDER BY DISPLAYORDER ASC;
END
GO

-- ============================================================
-- USP_GET_TOPICS_BY_PATH
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_TOPICS_BY_PATH]
(
    @PATHKEY NVARCHAR(50),
    @DIFFICULTYTIER NVARCHAR(20) = NULL,
    @ONLYACTIVE BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PATHID INT;

    SELECT @PATHID = PATHID
    FROM LEARNING_PATH_MASTER
    WHERE PATHKEY = @PATHKEY AND (@ONLYACTIVE = 0 OR ISACTIVE = 1);

    IF @PATHID IS NULL
    BEGIN
        SELECT
            1 AS ErrorCode,
            'PATH_NOT_FOUND' AS ErrorType,
            'Learning path not found: ' + @PATHKEY AS ErrorMessage;
        RETURN;
    END

    -- Result set 1: path info
    SELECT
        PATHID,
        PATHKEY,
        PATHNAME,
        PATHEMOJI
    FROM LEARNING_PATH_MASTER
    WHERE PATHID = @PATHID;

    -- Result set 2: topics
    SELECT
        T.TOPICID,
        T.TOPICKEY,
        T.TOPICNAME,
        T.DESCRIPTION,
        T.DIFFICULTYTIER,
        T.ESTIMATEDMINUTES,
        T.DISPLAYORDER,
        T.PREREQUISITETOPICID,
        CASE WHEN T.THEORYMARKDOWN IS NOT NULL AND LEN(T.THEORYMARKDOWN) > 0 THEN 1 ELSE 0 END AS HASTHEORY,
        (SELECT COUNT(*) FROM CONTENT_ITEM CI WHERE CI.TOPICID = T.TOPICID AND CI.ISACTIVE = 1) AS CONTENTCOUNT,
        (SELECT COUNT(*) FROM QUIZ_QUESTION_MASTER QQ WHERE QQ.TOPICID = T.TOPICID AND QQ.ISACTIVE = 1) AS QUESTIONCOUNT
    FROM TOPIC_MASTER T
    WHERE T.PATHID = @PATHID
      AND (@ONLYACTIVE = 0 OR T.ISACTIVE = 1)
      AND (@DIFFICULTYTIER IS NULL OR T.DIFFICULTYTIER = @DIFFICULTYTIER)
    ORDER BY T.DISPLAYORDER ASC;
END
GO

-- ============================================================
-- USP_GET_CONTENT_BY_TOPIC
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_CONTENT_BY_TOPIC]
(
    @TOPICID INT,
    @CONTENTTYPE NVARCHAR(20) = NULL,
    @ONLYACTIVE BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TOPIC_MASTER WHERE TOPICID = @TOPICID)
    BEGIN
        SELECT
            1 AS ErrorCode,
            'TOPIC_NOT_FOUND' AS ErrorType,
            'Topic not found' AS ErrorMessage;
        RETURN;
    END

    -- Result set 1: topic info with theory
    SELECT
        TOPICID,
        TOPICNAME,
        THEORYMARKDOWN
    FROM TOPIC_MASTER
    WHERE TOPICID = @TOPICID;

    -- Result set 2: content items
    SELECT
        CONTENTID,
        CONTENTTYPE,
        TITLE,
        SUMMARY,
        EXTERNALURL,
        PLATFORMCODE,
        DIFFICULTY,
        ESTIMATEDMINUTES,
        DISPLAYORDER
    FROM CONTENT_ITEM
    WHERE TOPICID = @TOPICID
      AND (@ONLYACTIVE = 0 OR ISACTIVE = 1)
      AND (@CONTENTTYPE IS NULL OR CONTENTTYPE = @CONTENTTYPE)
    ORDER BY DISPLAYORDER ASC;
END
GO

-- ============================================================
-- USP_GET_QUIZ_QUESTIONS_BY_TOPIC
-- Returns questions for a plan's topic (excludes correct answers
-- so frontend can't cheat; answers validated server-side on submit)
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_QUIZ_QUESTIONS_BY_TOPIC]
(
    @USERID INT,
    @PLANID INT,
    @LIMIT INT = 3
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TOPICID INT;

    -- Resolve topic from plan
    SELECT @TOPICID = DLP.TOPICID
    FROM DAILY_LEARNING_PLAN DLP
    WHERE DLP.PLANID = @PLANID
      AND DLP.USERID = @USERID;

    IF @TOPICID IS NULL
    BEGIN
        SELECT
            1 AS ErrorCode,
            'PLAN_NOT_FOUND' AS ErrorType,
            'Plan not found or does not belong to user' AS ErrorMessage;
        RETURN;
    END

    -- Return random N questions (no correct answer exposed)
    SELECT TOP (@LIMIT)
        QUESTIONID,
        QUESTIONTEXT,
        OPTIONA,
        OPTIONB,
        OPTIONC,
        OPTIOND,
        DIFFICULTY
    FROM QUIZ_QUESTION_MASTER
    WHERE TOPICID = @TOPICID
      AND ISACTIVE = 1
    ORDER BY NEWID();
END
GO
