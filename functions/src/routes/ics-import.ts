import { Router, type IRouter } from "express";
import axios from "axios";
import { requireAuth } from "../middleware/auth";
import { IcsImportRequest } from "@ppt/shared";
import type { IcsImportResponseType } from "@ppt/shared";
import { parseIcsContent } from "../services/ics-parser";

export const icsRouter: IRouter = Router();

/**
 * POST /api/schedule/import-ics
 *
 * Accepts an ICS URL, fetches and parses the calendar file,
 * expands recurring events, and returns parsed IcsEvent objects.
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

  // Fetch the ICS file
  let icsData: string;
  try {
    const response = await axios.get<string>(icsUrl, {
      timeout: 15000,
      responseType: "text",
      maxContentLength: 5 * 1024 * 1024, // 5MB limit
    });
    icsData = response.data;
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    res.status(502).json({
      error: "Failed to fetch ICS file from URL",
      details: message,
    });
    return;
  }

  // Parse the ICS content
  const { events, warnings } = parseIcsContent(icsData);

  const response: IcsImportResponseType = { events, warnings };
  res.json(response);
});
