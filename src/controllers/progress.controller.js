const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");

const getUserProgress = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const pathId = req.query.pathId ? parseInt(req.query.pathId, 10) : null;

    const result = await sequelize.query(
      `EXEC USP_GET_USER_TOPIC_PROGRESS
        @USERID = :userId,
        @PATHID = :pathId,
        @TOPICID = NULL`,
      {
        replacements: { userId, pathId },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      return res.status(500).json({
        success: false,
        error: { code: rows[0].ErrorType, message: rows[0].ErrorMessage },
      });
    }

    const summaryRow = rows.find((r) => r.TotalTopics !== undefined && r.PROGRESSID === undefined);
    const progressRows = rows.filter((r) => r.PROGRESSID !== undefined);

    const summary = summaryRow
      ? {
          totalTopics: summaryRow.TotalTopics,
          startedTopics: summaryRow.StartedTopics,
          masteredTopics: summaryRow.MasteredTopics,
          averageScore: summaryRow.AverageScore,
          totalAttempts: summaryRow.TotalAttempts,
        }
      : null;

    const topics = progressRows.map((r) => ({
      progressId: r.PROGRESSID,
      topicId: r.TOPICID,
      topicName: r.TOPICNAME,
      topicKey: r.TOPICKEY,
      pathName: r.PATHNAME,
      pathEmoji: r.PATHEMOJI,
      leitnerBox: r.LEITNERBOX,
      lastQuizScore: r.LASTQUIZSCORE,
      attemptCount: r.ATTEMPTCOUNT,
      contentIndex: r.CONTENTINDEX,
      masteryLevel: r.MASTERYLEVEL,
      nextReviewDate: r.NEXTREVIEWDATE,
      lastAttemptedAt: r.LASTATTEMPTEDAT,
    }));

    return res.json({
      success: true,
      data: { summary, topics },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch progress",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getTopicProgress = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const topicId = parseInt(req.params.topicId, 10);

    if (!topicId || isNaN(topicId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_TOPIC_ID", message: "Valid topicId is required" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_GET_USER_TOPIC_PROGRESS
        @USERID = :userId,
        @PATHID = NULL,
        @TOPICID = :topicId`,
      {
        replacements: { userId, topicId },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      const err = rows[0];
      return res.status(err.ErrorCode === 1 ? 404 : 500).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    const progressRow = rows.find((r) => r.PROGRESSID !== undefined);
    const attemptRows = rows.filter((r) => r.ATTEMPTID !== undefined);

    const progress = progressRow
      ? {
          progressId: progressRow.PROGRESSID,
          topicId: progressRow.TOPICID,
          topicName: progressRow.TOPICNAME,
          leitnerBox: progressRow.LEITNERBOX,
          lastQuizScore: progressRow.LASTQUIZSCORE,
          attemptCount: progressRow.ATTEMPTCOUNT,
          contentIndex: progressRow.CONTENTINDEX,
          masteryLevel: progressRow.MASTERYLEVEL,
          nextReviewDate: progressRow.NEXTREVIEWDATE,
          lastAttemptedAt: progressRow.LASTATTEMPTEDAT,
        }
      : null;

    const recentAttempts = attemptRows.map((r) => ({
      attemptId: r.ATTEMPTID,
      planId: r.PLANID,
      questionId: r.QUESTIONID,
      selectedOption: r.SELECTEDOPTION,
      isCorrect: Boolean(r.ISCORRECT),
      attemptedAt: r.ATTEMPTEDAT,
    }));

    return res.json({
      success: true,
      data: { progress, recentAttempts },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch topic progress",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

module.exports = { getUserProgress, getTopicProgress };
