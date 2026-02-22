import express, { type Express } from "express";
import cors from "cors";

import { facilityUsageRouter } from "./routes/facility-usage";
import { planRouter } from "./routes/plan";
import { chatRouter } from "./routes/chat";
import { icsRouter } from "./routes/ics-import";

export const app: Express = express();

// ── Middleware ───────────────────────────────────────────────────────

app.use(cors({ origin: true }));
app.use(express.json({ limit: "1mb" }));

// ── Health check ────────────────────────────────────────────────────

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// ── Routes ──────────────────────────────────────────────────────────

app.use("/api/facility-usage", facilityUsageRouter);
app.use("/api/plan", planRouter);
app.use("/api/chat", chatRouter);
app.use("/api/schedule", icsRouter);

// ── 404 fallback ────────────────────────────────────────────────────

app.use((_req, res) => {
  res.status(404).json({ error: "Not found" });
});
