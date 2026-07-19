const express = require("express");
const router = express.Router();
const extractUser = require("../middleware/extractUser");
const {
  getTodayPlan,
  getPlanById,
  updatePlanStatus,
  getPlanQuiz,
  submitPlanQuiz,
} = require("../controllers/plan.controller");

router.use(extractUser);

router.get("/today", getTodayPlan);
router.get("/:planId", getPlanById);
router.patch("/:planId/status", updatePlanStatus);
router.get("/:planId/quiz", getPlanQuiz);
router.post("/:planId/quiz/submit", submitPlanQuiz);

module.exports = router;
