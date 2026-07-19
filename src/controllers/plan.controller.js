const { QueryTypes } = require("sequelize");
const sequelize = require("../config/database");
const { getLearningLimits } = require("../utils/learningEntitlements");

function formatPlanDateForSql(value) {
  if (value == null || value === "") {
    return new Date().toISOString().split("T")[0];
  }
  if (value instanceof Date) {
    return value.toISOString().split("T")[0];
  }
  const s = String(value);
  return s.includes("T") ? s.split("T")[0] : s.slice(0, 10);
}

function mapSqlRowsToPlan(planRows) {
  return planRows.map((r) => ({
    planId: r.PLANID,
    planDate: r.PLANDATE,
    planType: r.PLANTYPE,
    planSlot: r.PLANSLOT,
    status: r.STATUS,
    topicId: r.TOPICID,
    topicName: r.TOPICNAME,
    topicKey: r.TOPICKEY,
    pathName: r.PATHNAME,
    pathEmoji: r.PATHEMOJI,
    contentId: r.CONTENTID,
    contentTitle: r.CONTENTTITLE,
    contentType: r.CONTENTTYPE,
    externalUrl: r.EXTERNALURL,
    platformCode: r.PLATFORMCODE,
    difficulty: r.DIFFICULTY,
    estimatedMinutes: r.ESTIMATEDMINUTES,
    theoryMarkdown: r.THEORYMARKDOWN,
    quizRequired: Boolean(r.QUIZREQUIRED),
    quizPassed: r.QUIZPASSED != null ? Boolean(r.QUIZPASSED) : null,
    quizScorePercent: r.QUIZSCOREPERCENT,
    completedAt: r.COMPLETEDAT,
    dayId: r.DAYID != null ? Number(r.DAYID) : null,
  }));
}

const getTodayPlan = async (req, res) => {
  try {
    const userId = req.userId;
    const planDate = req.query.date || null;

    const limits = getLearningLimits(req);

    const result = await sequelize.query(
      `EXEC USP_GET_OR_CREATE_DAILY_LEARNING_PLAN
        @USERID = :userId,
        @PLANDATE = :planDate,
        @DAYID = NULL,
        @MAXNONMASTEREDTOPICS = :maxNonMasteredTopics`,
      {
        replacements: { userId, planDate, maxNonMasteredTopics: limits.maxNonMasteredTopics },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode) {
      const err = rows[0];
      const errorMap = {
        1: { status: 404, code: err.ErrorType },
        2: { status: 200, code: err.ErrorType },
        4: { status: 404, code: err.ErrorType },
        5: { status: 403, code: err.ErrorType },
      };
      const mapped = errorMap[err.ErrorCode] || { status: 500, code: "INTERNAL_ERROR" };
      return res.status(mapped.status).json({
        success: false,
        error: { code: mapped.code || err.ErrorType, message: err.ErrorMessage },
      });
    }

    const statusRow = rows.find((r) => r.Status === "SUCCESS" || r.Action !== undefined);
    let planRows = rows.filter((r) => r.PLANID !== undefined);

    const resolvedDate = formatPlanDateForSql(planRows[0]?.PLANDATE ?? planDate);

    await sequelize.query(
      `EXEC USP_APPEND_MISSING_QUIZ_PLAN_ROW @USERID = :userId, @PLANDATE = :planDate`,
      {
        replacements: { userId, planDate: resolvedDate },
        type: QueryTypes.RAW,
      }
    );

    const refresh = await sequelize.query(
      `EXEC USP_GET_DAILY_PLAN_FOR_DATE
        @USERID = :userId,
        @PLANDATE = :planDate,
        @PLANID = NULL`,
      {
        replacements: { userId, planDate: resolvedDate },
        type: QueryTypes.RAW,
      }
    );

    const refreshed = refresh[0] || [];
    const refreshedPlanRows = refreshed.filter((r) => r.PLANID !== undefined);
    if (refreshedPlanRows.length > 0) {
      planRows = refreshedPlanRows;
    }

    const plan = mapSqlRowsToPlan(planRows);

    return res.json({
      success: true,
      data: {
        action: statusRow?.Action || "LOADED",
        planDate: plan.length ? plan[0].planDate : resolvedDate,
        totalItems: plan.length,
        plan,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to load daily learning plan",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getPlanById = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const planId = parseInt(req.params.planId, 10);

    if (!planId || isNaN(planId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_PLAN_ID", message: "Valid planId is required" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_GET_DAILY_PLAN_FOR_DATE
        @USERID = :userId,
        @PLANDATE = NULL,
        @PLANID = :planId`,
      {
        replacements: { userId, planId },
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

    const planRow = rows.find((r) => r.PLANID !== undefined);
    if (!planRow) {
      return res.status(404).json({
        success: false,
        error: { code: "PLAN_NOT_FOUND", message: "Plan not found" },
      });
    }

    return res.json({
      success: true,
      data: {
        planId: planRow.PLANID,
        planDate: planRow.PLANDATE,
        planType: planRow.PLANTYPE,
        planSlot: planRow.PLANSLOT,
        status: planRow.STATUS,
        topicId: planRow.TOPICID,
        topicName: planRow.TOPICNAME,
        topicKey: planRow.TOPICKEY,
        pathName: planRow.PATHNAME,
        pathEmoji: planRow.PATHEMOJI,
        contentId: planRow.CONTENTID,
        contentTitle: planRow.CONTENTTITLE,
        contentType: planRow.CONTENTTYPE,
        externalUrl: planRow.EXTERNALURL,
        platformCode: planRow.PLATFORMCODE,
        difficulty: planRow.DIFFICULTY,
        estimatedMinutes: planRow.ESTIMATEDMINUTES,
        theoryMarkdown: planRow.THEORYMARKDOWN,
        quizRequired: Boolean(planRow.QUIZREQUIRED),
        quizPassed: planRow.QUIZPASSED != null ? Boolean(planRow.QUIZPASSED) : null,
        quizScorePercent: planRow.QUIZSCOREPERCENT,
        completedAt: planRow.COMPLETEDAT,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch plan",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const updatePlanStatus = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const planId = parseInt(req.params.planId, 10);
    const { status } = req.body;

    if (!planId || isNaN(planId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_PLAN_ID", message: "Valid planId is required" },
      });
    }

    if (!status || !["IN_PROGRESS", "COMPLETED", "SKIPPED"].includes(status)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_STATUS", message: "status must be IN_PROGRESS, COMPLETED, or SKIPPED" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_UPDATE_DAILY_PLAN_STATUS
        @USERID = :userId,
        @PLANID = :planId,
        @NEWSTATUS = :status`,
      {
        replacements: { userId, planId, status },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode && rows[0].ErrorCode !== 0) {
      const err = rows[0];
      const statusMap = { 1: 404, 2: 403, 3: 400, 4: 400 };
      return res.status(statusMap[err.ErrorCode] || 500).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    return res.json({
      success: true,
      data: { planId, status, message: "Plan status updated" },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to update plan status",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const getPlanQuiz = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const planId = parseInt(req.params.planId, 10);
    const limit = parseInt(req.query.limit, 10) || 3;

    if (!planId || isNaN(planId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_PLAN_ID", message: "Valid planId is required" },
      });
    }

    const result = await sequelize.query(
      `EXEC USP_GET_QUIZ_QUESTIONS_BY_TOPIC
        @USERID = :userId,
        @PLANID = :planId,
        @LIMIT = :limit`,
      {
        replacements: { userId, planId, limit },
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

    const questions = rows
      .filter((r) => r.QUESTIONID !== undefined)
      .map((r) => ({
        questionId: r.QUESTIONID,
        questionText: r.QUESTIONTEXT,
        optionA: r.OPTIONA,
        optionB: r.OPTIONB,
        optionC: r.OPTIONC,
        optionD: r.OPTIOND,
        difficulty: r.DIFFICULTY,
      }));

    return res.json({
      success: true,
      data: {
        planId,
        totalQuestions: questions.length,
        questions,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to fetch quiz questions",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

const submitPlanQuiz = async (req, res) => {
  try {
    // const userId = req.userId;
    const userId = req.userId;
    const planId = parseInt(req.params.planId, 10);
    const { answers } = req.body;

    if (!planId || isNaN(planId)) {
      return res.status(400).json({
        success: false,
        error: { code: "INVALID_PLAN_ID", message: "Valid planId is required" },
      });
    }

    if (!answers || !Array.isArray(answers) || answers.length === 0) {
      return res.status(400).json({
        success: false,
        error: { code: "MISSING_ANSWERS", message: "answers array is required" },
      });
    }

    for (const a of answers) {
      if (!a.questionId || !a.selectedOption) {
        return res.status(400).json({
          success: false,
          error: { code: "INVALID_ANSWER", message: "Each answer must have questionId and selectedOption" },
        });
      }
      if (!["A", "B", "C", "D"].includes(a.selectedOption.toUpperCase())) {
        return res.status(400).json({
          success: false,
          error: { code: "INVALID_OPTION", message: "selectedOption must be A, B, C, or D" },
        });
      }
    }

    const answersJson = JSON.stringify(
      answers.map((a) => ({
        questionId: a.questionId,
        selectedOption: a.selectedOption.toUpperCase(),
      }))
    );

    const result = await sequelize.query(
      `EXEC USP_SUBMIT_LEARNING_QUIZ
        @USERID = :userId,
        @PLANID = :planId,
        @ANSWERSJSON = :answersJson`,
      {
        replacements: { userId, planId, answersJson },
        type: QueryTypes.RAW,
      }
    );

    const rows = result[0] || [];

    if (rows.length && rows[0].ErrorCode && rows[0].ErrorCode !== 0) {
      const err = rows[0];
      const statusMap = { 1: 404, 2: 403, 3: 400, 4: 400, 5: 400 };
      return res.status(statusMap[err.ErrorCode] || 500).json({
        success: false,
        error: { code: err.ErrorType, message: err.ErrorMessage },
      });
    }

    const scoreRow = rows.find((r) => r.ScorePercent !== undefined);
    const detailRows = rows.filter((r) => r.QUESTIONID !== undefined);
    const progressRow = rows.find((r) => r.NewLeitnerBox !== undefined);

    const quizResult = {
      scorePercent: scoreRow?.ScorePercent ?? null,
      totalQuestions: scoreRow?.TotalQuestions ?? answers.length,
      correctCount: scoreRow?.CorrectCount ?? 0,
      passed: scoreRow?.Passed != null ? Boolean(scoreRow.Passed) : null,
    };

    const questionResults = detailRows.map((r) => ({
      questionId: r.QUESTIONID,
      selectedOption: r.SELECTEDOPTION,
      correctOption: r.CORRECTOPTION,
      isCorrect: Boolean(r.ISCORRECT),
      explanation: r.EXPLANATION,
    }));

    const topicUpdate = progressRow
      ? {
          newLeitnerBox: progressRow.NewLeitnerBox,
          newMasteryLevel: progressRow.NewMasteryLevel,
          nextReviewDate: progressRow.NextReviewDate,
        }
      : null;

    return res.json({
      success: true,
      data: { quizResult, questionResults, topicUpdate },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Failed to submit quiz",
        ...(process.env.NODE_ENV === "development" && { details: error.message }),
      },
    });
  }
};

module.exports = { getTodayPlan, getPlanById, updatePlanStatus, getPlanQuiz, submitPlanQuiz };
