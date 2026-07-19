/**
 * Per-request learning limits (paths enrolled, concurrent non-mastered topics).
 * SQL treats NULL as unlimited.
 *
 * Header x-streakly-learning-limits: JSON, partial keys merge with env.
 * Env: LEARNING_MAX_ACTIVE_PATHS, LEARNING_MAX_NON_MASTERED_TOPICS
 */

function parseEnvInt(name) {
  const raw = process.env[name];
  if (raw === undefined || raw === "") return null;
  const n = parseInt(String(raw), 10);
  return Number.isFinite(n) && n >= 0 ? n : null;
}

function parseLimitsHeader(req) {
  const raw = req.headers["x-streakly-learning-limits"];
  if (!raw || typeof raw !== "string") return null;
  try {
    const o = JSON.parse(raw);
    if (!o || typeof o !== "object") return null;
    const pick = (k) =>
      typeof o[k] === "number" && Number.isFinite(o[k]) && o[k] >= 0 ? o[k] : undefined;
    return {
      maxActivePaths: pick("maxActivePaths"),
      maxNonMasteredTopics: pick("maxNonMasteredTopics"),
    };
  } catch {
    return null;
  }
}

function getLearningLimits(req) {
  const fromEnv = {
    maxActivePaths: parseEnvInt("LEARNING_MAX_ACTIVE_PATHS"),
    maxNonMasteredTopics: parseEnvInt("LEARNING_MAX_NON_MASTERED_TOPICS"),
  };
  const fromHeader = parseLimitsHeader(req);
  if (!fromHeader) return fromEnv;
  return {
    maxActivePaths: fromHeader.maxActivePaths ?? fromEnv.maxActivePaths,
    maxNonMasteredTopics: fromHeader.maxNonMasteredTopics ?? fromEnv.maxNonMasteredTopics,
  };
}

function httpStatusForLearningError(row) {
  const t = row?.ErrorType;
  if (t === "PATH_LIMIT_REACHED" || t === "TOPIC_LIMIT_REACHED") return 403;
  return 400;
}

module.exports = { getLearningLimits, httpStatusForLearningError };
