const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");

const generatePlan = async (req, res) => {
  try {
    const { userId, planDate, dayId } = req.body;

    if (!userId || !planDate) {
      return res.status(400).json({
        success: false,
        error: { code: "MISSING_FIELDS", message: "userId and planDate are required" },
      });
    }

    const resolvedDayId =
      dayId != null && dayId !== "" && !Number.isNaN(Number(dayId)) ? Number(dayId) : null;

    const result = await sequelize.query(
      `EXEC USP_GENERATE_DAILY_LEARNING_PLAN
        @USERID = :userId,
        @PLANDATE = :planDate,
        @DAYID = :resolvedDayId`,
      {
        replacements: { userId, planDate, resolvedDayId },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode && rows[0].ErrorCode !== 0) {
      const row = rows[0];
      return res.status(400).json({
        success: false,
        error: { code: row.ErrorType, message: row.ErrorMessage },
      });
    }

    const planRows = rows.filter((r) => r.PLANID !== undefined);

    return res.json({
      success: true,
      data: {
        userId,
        planDate,
        generatedCount: planRows.length,
        plans: planRows.map((r) => ({
          planId: r.PLANID,
          planSlot: r.PLANSLOT,
          planType: r.PLANTYPE,
          topicId: r.TOPICID,
          contentId: r.CONTENTID,
        })),
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to generate learning plan",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const generateBatchPlans = async (req, res) => {
  try {
    const { planDate, userIds } = req.body;

    if (!planDate) {
      return res.status(400).json({
        success: false,
        error: { code: "MISSING_PLAN_DATE", message: "planDate is required" },
      });
    }

    const userIdsJson = userIds && Array.isArray(userIds) ? JSON.stringify(userIds) : null;

    const result = await sequelize.query(
      `EXEC USP_INTERNAL_BATCH_GENERATE_PLANS
        @PLANDATE = :planDate,
        @USERIDSJSON = :userIdsJson`,
      {
        replacements: { planDate, userIdsJson },
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

    const summaryRow = rows.find((r) => r.TotalProcessed !== undefined);

    return res.json({
      success: true,
      data: {
        planDate,
        totalProcessed: summaryRow?.TotalProcessed ?? 0,
        totalGenerated: summaryRow?.TotalGenerated ?? 0,
        totalSkipped: summaryRow?.TotalSkipped ?? 0,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to generate batch plans",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

module.exports = { generatePlan, generateBatchPlans };
