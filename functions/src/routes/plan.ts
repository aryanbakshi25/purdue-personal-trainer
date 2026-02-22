import { Router, type IRouter } from "express";
import * as admin from "firebase-admin";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { generateDailyPlan } from "../services/plan-generator";
import { ScheduleBlock, UserProfile } from "@ppt/shared";
import { z } from "zod";

export const planRouter: IRouter = Router();

const GeneratePlanBody = z.object({
  profile: UserProfile,
  scheduleBlocks: z.array(ScheduleBlock),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

/**
 * POST /api/plan/generate
 *
 * Accepts user profile + schedule blocks for a given date.
 * Returns a generated daily plan and persists it to Firestore.
 *
 * Requires Firebase Auth.
 */
planRouter.post("/generate", requireAuth, async (req, res) => {
  const authReq = req as AuthenticatedRequest;

  const parseResult = GeneratePlanBody.safeParse(req.body);
  if (!parseResult.success) {
    res.status(400).json({
      error: "Invalid request body",
      details: parseResult.error.flatten(),
    });
    return;
  }

  const { profile, scheduleBlocks, date } = parseResult.data;

  try {
    const plan = generateDailyPlan(authReq.uid, profile, scheduleBlocks, date);

    // Persist to Firestore
    const db = admin.firestore();
    await db
      .doc(`users/${authReq.uid}/plans/${date}`)
      .set(plan, { merge: true });

    res.json(plan);
  } catch (err) {
    console.error("Plan generation failed:", err);
    res.status(500).json({ error: "Failed to generate plan" });
  }
});
