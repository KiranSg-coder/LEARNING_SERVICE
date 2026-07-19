const express = require("express");
const router = express.Router();
const extractUser = require("../middleware/extractUser");
const {
  getLearningPaths,
  getTopicsByPath,
  getContentByTopic,
} = require("../controllers/catalog.controller");

router.use(extractUser);

router.get("/paths", getLearningPaths);
router.get("/paths/:pathKey/topics", getTopicsByPath);
router.get("/topics/:topicId/content", getContentByTopic);

module.exports = router;
