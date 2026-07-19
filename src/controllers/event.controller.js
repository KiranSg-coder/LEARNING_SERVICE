const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");

const handleEvent = async (req, res) => {
  try {
    const { eventType, payload } = req.body;
    const userId = payload?.userId;

    console.log(`[Learning Event] Received ${eventType} for user ${userId}`);

    if (eventType === "DAY_CREATED" && userId) {
      const rawDate = payload?.dayDate;
      const planDate =
        rawDate instanceof Date
          ? rawDate.toISOString().split("T")[0]
          : String(rawDate || new Date().toISOString().split("T")[0]).slice(0, 10);
      const mode = payload?.mode;
      const dayId =
        payload?.dayId != null && payload?.dayId !== "" && !Number.isNaN(Number(payload.dayId))
          ? Number(payload.dayId)
          : null;

      if (mode === "MINIMUM") {
        console.log(`[Learning Event] Minimum day — skipping plan generation for user ${userId}`);
        return res.json({ success: true, action: "SKIPPED_MINIMUM" });
      }

      try {
        const raw = await sequelize.query(
          `EXEC USP_GET_OR_CREATE_DAILY_LEARNING_PLAN @USERID = :userId, @PLANDATE = :planDate, @DAYID = :dayId`,
          { replacements: { userId, planDate, dayId }, type: QueryTypes.RAW }
        );
        const rows = raw[0] || [];
        const first = rows[0];
        if (first?.ErrorCode != null && first.ErrorCode !== 0) {
          console.log(
            `[Learning Event] Plan not created for user ${userId}: ${first.ErrorType} — ${first.ErrorMessage}`
          );
          return res.json({ success: true, action: first.ErrorType || "PLAN_SKIPPED" });
        }
        console.log(`[Learning Event] Plan ensured for user ${userId} on ${planDate}`);
      } catch (planErr) {
        console.error(`[Learning Event] Plan generation failed:`, planErr.message);
      }

      return res.json({ success: true, action: "PLAN_GENERATED" });
    }

    return res.json({ success: true, action: "IGNORED" });
  } catch (error) {
    console.error("[Learning Event] Error:", error.message);
    return res.status(500).json({
      success: false,
      error: { code: "EVENT_HANDLER_ERROR", message: error.message },
    });
  }
};

module.exports = { handleEvent };
