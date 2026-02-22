import { Request, Response, NextFunction } from "express";
import * as admin from "firebase-admin";

/**
 * Express middleware that verifies a Firebase ID token from the
 * Authorization: Bearer <token> header.
 *
 * On success, attaches `req.uid` for downstream handlers.
 */
export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing or malformed Authorization header" });
    return;
  }

  const idToken = authHeader.split("Bearer ")[1];

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    // Attach uid to request for downstream use
    (req as AuthenticatedRequest).uid = decoded.uid;
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token" });
  }
}

/** Extended Request type with authenticated user ID */
export interface AuthenticatedRequest extends Request {
  uid: string;
}
