import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";

import { app } from "./app";

// Initialize Firebase Admin SDK (uses default credentials in Cloud Functions
// and emulator environment automatically).
admin.initializeApp();

/**
 * Main HTTP function that serves the Express app.
 * All API routes are handled by Express under /api/*.
 */
export const api = onRequest(
  {
    region: "us-central1",
    cors: true,
    // Allow up to 60s for Gemini calls
    timeoutSeconds: 60,
  },
  app
);
