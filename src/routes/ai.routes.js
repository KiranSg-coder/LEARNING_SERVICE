const express = require("express");
const router = express.Router();
const extractUser = require("../middleware/extractUser");

router.use(extractUser);

const stub = (_req, res) => {
  return res.status(501).json({
    success: false,
    error: {
      code: "NOT_IMPLEMENTED",
      message: "AI features are planned for a future release",
    },
  });
};

router.post("/plan/preview", stub);
router.post("/quiz/generate", stub);
router.post("/explain", stub);

module.exports = router;
