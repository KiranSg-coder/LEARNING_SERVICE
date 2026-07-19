const express = require("express");
const router = express.Router();
const internalServiceAuth = require("../middleware/internalServiceAuth");
const {
  generatePlan,
  generateBatchPlans,
} = require("../controllers/internal.controller");
const { handleEvent } = require("../controllers/event.controller");

router.use(internalServiceAuth);

router.post("/event", handleEvent);
router.post("/plan/generate", generatePlan);
router.post("/plan/generate-batch", generateBatchPlans);

module.exports = router;
