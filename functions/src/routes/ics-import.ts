import { Router, type IRouter } from "express";
import { requireAuth } from "../middleware/auth";
import { IcsImportRequest } from "@ppt/shared";
import type { IcsImportResponseType } from "@ppt/shared";

export const icsRouter: IRouter = Router();

/**
 * POST /api/schedule/import-ics
 *
 * Accepts an ICS URL and returns parsed calendar events.
 *
 * Phase 1: Scaffolding only – validates input and returns a stub response.
 * Phase 2: Will implement actual ICS parsing using ical.js or similar.
 *
 * Requires Firebase Auth.
 */
icsRouter.post("/import-ics", requireAuth, async (req, res) => {
  const parseResult = IcsImportRequest.safeParse(req.body);
  if (!parseResult.success) {
    res.status(400).json({
      error: "Invalid request body",
      details: parseResult.error.flatten(),
    });
    return;
  }

  const { icsUrl } = parseResult.data;

  // TODO: Phase 2 – Implement actual ICS parsing
  // 1. Fetch the ICS file from icsUrl
  // 2. Parse using ical.js or node-ical
  // 3. Convert VEVENT entries to our IcsEvent schema
  // 4. Handle recurring events (RRULE)
  // 5. Return parsed events

  const stubResponse: IcsImportResponseType = {
    events: [],
    warnings: [
      `ICS import is not yet implemented. Received URL: ${icsUrl}`,
      "This endpoint will be available in Phase 2.",
    ],
  };

  res.status(501).json(stubResponse);
});
