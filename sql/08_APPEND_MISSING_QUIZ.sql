USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_APPEND_MISSING_QUIZ_PLAN_ROW
-- If today's plan has theory/practice/review but no QUIZ row and
-- the topic has enough questions, inserts a QUIZ plan row.
-- Fixes plans generated under older logic that skipped quiz when
-- minute budget was already used (e.g. 30 min after theory+practice).
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_APPEND_MISSING_QUIZ_PLAN_ROW]
(
    @USERID INT,
    @PLANDATE DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.DAILY_LEARNING_PLAN
        WHERE USERID = @USERID AND PLANDATE = @PLANDATE
    )
        RETURN;

    IF EXISTS (
        SELECT 1 FROM dbo.DAILY_LEARNING_PLAN
        WHERE USERID = @USERID AND PLANDATE = @PLANDATE AND PLANSLOT = N'QUIZ'
    )
        RETURN;

    DECLARE @TOPICID INT;

    SELECT TOP 1 @TOPICID = TOPICID
    FROM dbo.DAILY_LEARNING_PLAN
    WHERE USERID = @USERID AND PLANDATE = @PLANDATE
    ORDER BY
        CASE PLANSLOT
            WHEN N'REVIEW' THEN 1
            WHEN N'THEORY' THEN 2
            WHEN N'PRACTICE' THEN 3
            WHEN N'QUIZ' THEN 4
            ELSE 5
        END,
        PLANID;

    IF @TOPICID IS NULL
        RETURN;

    IF (SELECT COUNT(*) FROM dbo.QUIZ_QUESTION_MASTER WHERE TOPICID = @TOPICID AND ISACTIVE = 1) < 2
        RETURN;

    DECLARE @DAYID INT;
    SELECT TOP 1 @DAYID = DAYID
    FROM dbo.DAILY_LEARNING_PLAN
    WHERE USERID = @USERID AND PLANDATE = @PLANDATE AND DAYID IS NOT NULL
    ORDER BY PLANID;

    INSERT INTO dbo.DAILY_LEARNING_PLAN
    (USERID, PLANDATE, PLANTYPE, PLANSLOT, TOPICID, CONTENTID, QUIZREQUIRED, DAYID)
    VALUES
    (@USERID, @PLANDATE, N'NEW', N'QUIZ', @TOPICID, NULL, 1, @DAYID);
END
GO
