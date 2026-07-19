const INTERNAL_SERVICE_KEY = process.env.INTERNAL_SERVICE_KEY;

/**
 * When INTERNAL_SERVICE_KEY is set, require matching x-service-key.
 * When unset (local dev), allow requests without a key.
 */
const internalServiceAuth = (req, res, next) => {
  if (!INTERNAL_SERVICE_KEY) {
    return next();
  }

  const sent = req.headers["x-service-key"];
  if (sent !== INTERNAL_SERVICE_KEY) {
    return res.status(401).json({
      success: false,
      error: {
        code: "UNAUTHORIZED",
        message: "Invalid or missing x-service-key",
      },
    });
  }

  next();
};

module.exports = internalServiceAuth;
