const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");

const getLearningPaths = async (req, res) => {
  try {
    const { pathKey, onlyActive } = req.query;

    const result = await sequelize.query(
      `EXEC USP_GET_LEARNING_PATHS
        @PATHKEY = :pathKey,
        @ONLYACTIVE = :onlyActive`,
      {
        replacements: {
          pathKey: pathKey || null,
          onlyActive: onlyActive !== "false" ? 1 : 0,
        },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      return res.status(500).json({
        success: false,
        error: {
          code: rows[0].ErrorType,
          message: rows[0].ErrorMessage,
        },
      });
    }

    const paths = rows.map((r) => ({
      pathId: r.PATHID,
      pathKey: r.PATHKEY,
      pathName: r.PATHNAME,
      description: r.DESCRIPTION,
      emoji: r.PATHEMOJI,
      displayOrder: r.DISPLAYORDER,
      isActive: Boolean(r.ISACTIVE),
    }));

    return res.json({ success: true, data: { paths } });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch learning paths",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getTopicsByPath = async (req, res) => {
  try {
    const { pathKey } = req.params;
    const { difficultyTier, onlyActive } = req.query;

    if (!pathKey) {
      return res.status(400).json({
        success: false,
        error: { code: "MISSING_PATH_KEY", message: "pathKey is required" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_GET_TOPICS_BY_PATH
        @PATHKEY = :pathKey,
        @DIFFICULTYTIER = :difficultyTier,
        @ONLYACTIVE = :onlyActive`,
      {
        replacements: {
          pathKey,
          difficultyTier: difficultyTier || null,
          onlyActive: onlyActive !== "false" ? 1 : 0,
        },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      const err = rows[0];
      const status = err.ErrorCode === 1 ? 404 : 500;
      return res.status(status).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    const pathRow = rows.find((r) => r.PATHID !== undefined && r.TOPICID === undefined);
    const topicRows = rows.filter((r) => r.TOPICID !== undefined);

    const path = pathRow
      ? {
          pathId: pathRow.PATHID,
          pathKey: pathRow.PATHKEY,
          pathName: pathRow.PATHNAME,
          emoji: pathRow.PATHEMOJI,
        }
      : null;

    const topics = topicRows.map((r) => ({
      topicId: r.TOPICID,
      topicKey: r.TOPICKEY,
      topicName: r.TOPICNAME,
      description: r.DESCRIPTION,
      difficultyTier: r.DIFFICULTYTIER,
      estimatedMinutes: r.ESTIMATEDMINUTES,
      displayOrder: r.DISPLAYORDER,
      prerequisiteTopicId: r.PREREQUISITETOPICID,
      hasTheory: Boolean(r.HASTHEORY),
      contentCount: r.CONTENTCOUNT,
      questionCount: r.QUESTIONCOUNT,
    }));

    return res.json({ success: true, data: { path, topics } });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch topics",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getContentByTopic = async (req, res) => {
  try {
    const topicId = parseInt(req.params.topicId, 10);
    const { contentType, onlyActive } = req.query;

    if (!topicId || isNaN(topicId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_TOPIC_ID", message: "Valid topicId is required" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_GET_CONTENT_BY_TOPIC
        @TOPICID = :topicId,
        @CONTENTTYPE = :contentType,
        @ONLYACTIVE = :onlyActive`,
      {
        replacements: {
          topicId,
          contentType: contentType || null,
          onlyActive: onlyActive !== "false" ? 1 : 0,
        },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      const err = rows[0];
      const status = err.ErrorCode === 1 ? 404 : 500;
      return res.status(status).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    const topicRow = rows.find((r) => r.TOPICID !== undefined && r.CONTENTID === undefined);
    const contentRows = rows.filter((r) => r.CONTENTID !== undefined);

    const topic = topicRow
      ? {
          topicId: topicRow.TOPICID,
          topicName: topicRow.TOPICNAME,
          theoryMarkdown: topicRow.THEORYMARKDOWN,
        }
      : null;

    const content = contentRows.map((r) => ({
      contentId: r.CONTENTID,
      contentType: r.CONTENTTYPE,
      title: r.TITLE,
      summary: r.SUMMARY,
      externalUrl: r.EXTERNALURL,
      platformCode: r.PLATFORMCODE,
      difficulty: r.DIFFICULTY,
      estimatedMinutes: r.ESTIMATEDMINUTES,
      displayOrder: r.DISPLAYORDER,
    }));

    return res.json({ success: true, data: { topic, content } });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch content",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

module.exports = { getLearningPaths, getTopicsByPath, getContentByTopic };
