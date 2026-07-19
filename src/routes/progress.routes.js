const express = require("express");
const router = express.Router();
const extractUser = require("../middleware/extractUser");
const {
  getUserProgress,
  getTopicProgress,
} = require("../controllers/progress.controller");

router.use(extractUser);

router.get("/", getUserProgress);
router.get("/topic/:topicId", getTopicProgress);

module.exports = router;
