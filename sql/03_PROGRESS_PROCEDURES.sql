USE [LEARNING_SERVICE]
GO

-- ============================================================
-- USP_GET_USER_TOPIC_PROGRESS
-- Returns progress rows + optional summary and recent attempts.
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GET_USER_TOPIC_PROGRESS]
(
    @USERID INT,
    @PATHID INT = NULL,
    @TOPICID INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: summary (only when not filtering by single topic)
    IF @TOPICID IS NULL
    BEGIN
        SELECT
            COUNT(*) AS TotalTopics,
            SUM(CASE WHEN UTP.MASTERYLEVEL != 'NOT_STARTED' THEN 1 ELSE 0 END) AS StartedTopics,
            SUM(CASE WHEN UTP.MASTERYLEVEL = 'MASTERED' THEN 1 ELSE 0 END) AS MasteredTopics,
            CASE
                WHEN SUM(CASE WHEN UTP.ATTEMPTCOUNT > 0 THEN 1 ELSE 0 END) > 0
                THEN AVG(CASE WHEN UTP.LASTQUIZSCORE IS NOT NULL THEN UTP.LASTQUIZSCORE ELSE NULL END)
                ELSE 0
            END AS AverageScore,
            SUM(UTP.ATTEMPTCOUNT) AS TotalAttempts
        FROM USER_TOPIC_PROGRESS UTP
        INNER JOIN TOPIC_MASTER TM ON UTP.TOPICID = TM.TOPICID
        WHERE UTP.USERID = @USERID
          AND (@PATHID IS NULL OR TM.PATHID = @PATHID);
    END

    -- Result set 2: progress rows
    SELECT
        UTP.PROGRESSID,
        UTP.TOPICID,
        TM.TOPICNAME,
        TM.TOPICKEY,
        LP.PATHNAME,
        LP.PATHEMOJI,
        UTP.LEITNERBOX,
        UTP.LASTQUIZSCORE,
        UTP.ATTEMPTCOUNT,
        UTP.CONTENTINDEX,
        UTP.MASTERYLEVEL,
        UTP.NEXTREVIEWDATE,
        UTP.LASTATTEMPTEDAT
    FROM USER_TOPIC_PROGRESS UTP
    INNER JOIN TOPIC_MASTER TM ON UTP.TOPICID = TM.TOPICID
    INNER JOIN LEARNING_PATH_MASTER LP ON TM.PATHID = LP.PATHID
    WHERE UTP.USERID = @USERID
      AND (@PATHID IS NULL OR TM.PATHID = @PATHID)
      AND (@TOPICID IS NULL OR UTP.TOPICID = @TOPICID)
    ORDER BY LP.DISPLAYORDER, TM.DISPLAYORDER;

    -- Result set 3: recent quiz attempts (only when filtering single topic)
    IF @TOPICID IS NOT NULL
    BEGIN
        SELECT TOP 20
            LQA.ATTEMPTID,
            LQA.PLANID,
            LQA.QUESTIONID,
            LQA.SELECTEDOPTION,
            LQA.ISCORRECT,
            LQA.ATTEMPTEDAT
        FROM LEARNING_QUIZ_ATTEMPT LQA
        INNER JOIN DAILY_LEARNING_PLAN DLP ON LQA.PLANID = DLP.PLANID
        WHERE LQA.USERID = @USERID
          AND DLP.TOPICID = @TOPICID
        ORDER BY LQA.ATTEMPTEDAT DESC;
    END
END
GO
