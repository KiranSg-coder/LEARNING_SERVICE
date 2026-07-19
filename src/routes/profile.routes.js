const express = require("express");
const router = express.Router();
const extractUser = require("../middleware/extractUser");
const {
  getUserProfile,
  upsertUserProfile,
  getUserEnrollments,
  setUserEnrollments,
} = require("../controllers/profile.controller");

router.use(extractUser);

router.get("/profile", getUserProfile);
router.put("/profile", upsertUserProfile);
router.get("/enrollments", getUserEnrollments);
router.put("/enrollments", setUserEnrollments);

module.exports = router;
