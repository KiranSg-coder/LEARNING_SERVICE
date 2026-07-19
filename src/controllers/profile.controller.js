const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");
const { getLearningLimits, httpStatusForLearningError } = require("../utils/learningEntitlements");

const getUserProfile = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const result = await sequelize.query(
      `EXEC USP_GET_USER_LEARNING_PROFILE @USERID = :userId`,
      { replacements: { userId }, type: QueryTypes.RAW }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      const err = rows[0];
      if (err.ErrorCode === 1) {
        return res.json({
          success: true,
          data: { profile: null, hasProfile: false },
        });
      }
      return res.status(500).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    if (!rows.length) {
      return res.json({
        success: true,
        data: { profile: null, hasProfile: false },
      });
    }

    const r = rows[0];
    return res.json({
      success: true,
      data: {
        hasProfile: true,
        profile: {
          profileId: r.PROFILEID,
          guidedEnabled: Boolean(r.GUIDEDENABLED),
          skillLevel: r.SKILLLEVEL,
          dailyMinutes: r.DAILYMINUTES,
          learningGoal: r.LEARNINGGOAL,
          createdDate: r.CREATEDDATE,
          updatedDate: r.UPDATEDDATE,
        },
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch learning profile",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const upsertUserProfile = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const { guidedEnabled, skillLevel, dailyMinutes, learningGoal } = req.body;

    if (guidedEnabled === undefined || !skillLevel || !dailyMinutes || !learningGoal) {
      return res.status(400).json({
        success: false,
        error: {
          code: "MISSING_REQUIRED_FIELDS",
          message: "guidedEnabled, skillLevel, dailyMinutes, and learningGoal are required",
        },
      });
    }

    if (!["BEGINNER", "INTERMEDIATE", "ADVANCED"].includes(skillLevel)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_SKILL_LEVEL", message: "skillLevel must be BEGINNER, INTERMEDIATE, or ADVANCED" },
      });
    }

    if (![15, 30, 60].includes(dailyMinutes)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_DAILY_MINUTES", message: "dailyMinutes must be 15, 30, or 60" },
      });
    }

    if (!["INTERVIEW", "SKILL", "CAREER_CHANGE", "GENERAL"].includes(learningGoal)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_LEARNING_GOAL", message: "learningGoal must be INTERVIEW, SKILL, CAREER_CHANGE, or GENERAL" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_UPSERT_USER_LEARNING_PROFILE
        @USERID = :userId,
        @GUIDEDENABLED = :guidedEnabled,
        @SKILLLEVEL = :skillLevel,
        @DAILYMINUTES = :dailyMinutes,
        @LEARNINGGOAL = :learningGoal`,
      {
        replacements: {
          userId,
          guidedEnabled: guidedEnabled ? 1 : 0,
          skillLevel,
          dailyMinutes,
          learningGoal,
        },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode && rows[0].ErrorCode !== 0) {
      return res.status(500).json({
        success: false,
        error: { code: rows[0].ErrorType, message: rows[0].ErrorMessage },
      });
    }

    const action = rows.length ? rows[0].Action : "UPSERTED";

    return res.json({
      success: true,
      data: { action, message: "Learning profile saved" },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to save learning profile",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getUserEnrollments = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const result = await sequelize.query(
      `EXEC USP_GET_USER_PATH_ENROLLMENTS @USERID = :userId`,
      { replacements: { userId }, type: QueryTypes.RAW }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      return res.status(500).json({
        success: false,
        error: { code: rows[0].ErrorType, message: rows[0].ErrorMessage },
      });
    }

    const enrollments = rows
      .filter((r) => r.ENROLLMENTID !== undefined)
      .map((r) => ({
        enrollmentId: r.ENROLLMENTID,
        pathId: r.PATHID,
        pathKey: r.PATHKEY,
        pathName: r.PATHNAME,
        emoji: r.PATHEMOJI,
        priorityOrder: r.PRIORITYORDER,
        isActive: Boolean(r.ISACTIVE),
        enrolledDate: r.ENROLLEDDATE,
      }));

    return res.json({ success: true, data: { enrollments } });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch enrollments",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const setUserEnrollments = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const { pathIds, priorities } = req.body;

    if (!pathIds || !Array.isArray(pathIds) || pathIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: { code: "MISSING_PATH_IDS", message: "pathIds array is required" },
      });
    }

    const limits = getLearningLimits(req);

    const enrollmentsJson = JSON.stringify(
      pathIds.map((id, idx) => ({
        pathId: id,
        priorityOrder: priorities && priorities[idx] !== undefined ? priorities[idx] : idx + 1,
      }))
    );

    const result = await sequelize.query(
      `EXEC USP_SET_USER_PATH_ENROLLMENTS
        @USERID = :userId,
        @ENROLLMENTSJSON = :enrollmentsJson,
        @MAXACTIVEPATHS = :maxActivePaths`,
      {
        replacements: { userId, enrollmentsJson, maxActivePaths: limits.maxActivePaths },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode && rows[0].ErrorCode !== 0) {
      return res.status(httpStatusForLearningError(rows[0])).json({
        success: false,
        error: { code: rows[0].ErrorType, message: rows[0].ErrorMessage },
      });
    }

    return res.json({
      success: true,
      data: {
        enrolled: rows.length ? rows[0].EnrolledCount : pathIds.length,
        message: "Enrollments updated",
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to update enrollments",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

module.exports = { getUserProfile, upsertUserProfile, getUserEnrollments, setUserEnrollments };
