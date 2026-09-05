require("dotenv").config();
const express = require("express");
const cors = require("cors");
const app = express();
const sequelizeConnection = require("./config/database");

const corsOrigin =
  process.env.CORS_ORIGIN === "*"
    ? true
    : (process.env.CORS_ORIGIN || "http://localhost:5173")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean);
app.use(cors({ origin: corsOrigin, credentials: true }));

const catalogRoutes = require("./routes/catalog.routes");
const profileRoutes = require("./routes/profile.routes");
const planRoutes = require("./routes/plan.routes");
const progressRoutes = require("./routes/progress.routes");
const internalRoutes = require("./routes/internal.routes");
const aiRoutes = require("./routes/ai.routes");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, _res, next) => {
  if (req.url === "/learning" || req.url.startsWith("/learning/")) {
    req.url = req.url.slice("/learning".length) || "/";
  }
  next();
});

app.get("/", (req, res) => {
  res.send("Learning service running.....");
});

// Mount specific prefixes BEFORE "/" routers — catalog/profile use extractUser on "/"
// and would otherwise intercept /internal/* and return 401 (no x-user-id).
app.use("/internal", internalRoutes);
app.use("/plan", planRoutes);
app.use("/progress", progressRoutes);
app.use("/ai", aiRoutes);
app.use("/", catalogRoutes);
app.use("/", profileRoutes);

sequelizeConnection
  .authenticate()
  .then(() => {
    console.log("Database connection has been established successfully.");
    return sequelizeConnection.sync();
  })
  .then(() => {
    const PORT = process.env.PORT || 6009;
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);

      // Register event bus subscriptions after server is ready
      const { registerEventSubscriptions } = require("./startup/registerSubscriptions");
      registerEventSubscriptions().catch((err) =>
        console.error("[Learning] Event subscription registration failed:", err.message)
      );
    });
  })
  .catch((err) => {
    console.error("Error occured while syncing database: ", err);
  });

module.exports = app;
