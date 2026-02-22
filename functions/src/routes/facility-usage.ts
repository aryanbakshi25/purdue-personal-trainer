import { Router, type IRouter } from "express";
import * as admin from "firebase-admin";
import { FACILITY_CACHE_TTL_MS } from "@ppt/shared";
import { scrapeFacilityUsage } from "../services/facility-scraper";

export const facilityUsageRouter: IRouter = Router();

/**
 * GET /api/facility-usage
 *
 * Returns current Purdue RecWell facility usage data.
 * Uses Firestore as a cache with a 5-minute TTL to avoid
 * hammering the RecWell page on every request.
 */
facilityUsageRouter.get("/", async (_req, res) => {
  try {
    const db = admin.firestore();
    const cacheRef = db.doc("cache/facilityUsage");
    const cacheDoc = await cacheRef.get();

    // Check cache validity
    if (cacheDoc.exists) {
      const data = cacheDoc.data()!;
      const cachedAt = new Date(data.cachedAt).getTime();
      const now = Date.now();

      if (now - cachedAt < FACILITY_CACHE_TTL_MS) {
        res.json({
          facilities: data.facilities,
          cachedAt: data.cachedAt,
          fromCache: true,
        });
        return;
      }
    }

    // Cache miss or expired – fetch fresh data
    const facilities = await scrapeFacilityUsage();
    const cachedAt = new Date().toISOString();

    await cacheRef.set({ facilities, cachedAt });

    res.json({ facilities, cachedAt, fromCache: false });
  } catch (err) {
    console.error("Failed to fetch facility usage:", err);
    res.status(500).json({ error: "Failed to fetch facility usage data" });
  }
});
