import { Router, type IRouter } from "express";
import * as admin from "firebase-admin";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { ChatRequest, Collections } from "@ppt/shared";
import { callGemini } from "../services/gemini";

export const chatRouter: IRouter = Router();

/**
 * POST /api/chat
 *
 * Accepts a user message and conversation history.
 * Loads user context (profile, schedule, today's plan, facility usage)
 * and calls Gemini server-side.
 *
 * Requires Firebase Auth.
 */
chatRouter.post("/", requireAuth, async (req, res) => {
  const authReq = req as AuthenticatedRequest;
  const uid = authReq.uid;

  const parseResult = ChatRequest.safeParse(req.body);
  if (!parseResult.success) {
    res.status(400).json({
      error: "Invalid request body",
      details: parseResult.error.flatten(),
    });
    return;
  }

  const { message, conversationHistory } = parseResult.data;

  try {
    const db = admin.firestore();

    // Load user context in parallel
    const [profileSnap, scheduleSnap, facilitySnap] = await Promise.all([
      db.doc(`${Collections.USERS}/${uid}`).get(),
      db.collection(Collections.SCHEDULE_BLOCKS(uid)).get(),
      db.doc(Collections.FACILITY_CACHE).get(),
    ]);

    // Build today's plan path
    const today = new Date().toISOString().split("T")[0];
    const planSnap = await db
      .doc(`${Collections.USERS}/${uid}/plans/${today}`)
      .get();

    const context = {
      profile: (profileSnap.exists ? profileSnap.data() : null) as Record<string, unknown> | null,
      scheduleBlocks: scheduleSnap.docs.map((d) => d.data()) as Record<string, unknown>[],
      todayPlan: (planSnap.exists ? planSnap.data() : null) as Record<string, unknown> | null,
      facilityUsage: (facilitySnap.exists
        ? facilitySnap.data()?.facilities ?? []
        : []) as Record<string, unknown>[],
    };

    const reply = await callGemini(message, conversationHistory, context);

    res.json({
      reply,
      disclaimer:
        "I'm an AI fitness assistant. My responses are not medical advice.",
    });
  } catch (err) {
    console.error("Chat endpoint failed:", err);
    res.status(500).json({ error: "Failed to process chat message" });
  }
});
