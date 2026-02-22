import axios from "axios";
import * as cheerio from "cheerio";
import type { FacilityUsageItemType } from "@ppt/shared";

const RECWELL_URL =
  "https://www.purdue.edu/recwell/facility-usage/index.html";

/**
 * Scrapes the Purdue RecWell facility usage page and returns
 * normalized usage data.
 *
 * The page structure may change – if scraping breaks, update
 * the selectors here. Consider adding alerts/monitoring.
 */
export async function scrapeFacilityUsage(): Promise<FacilityUsageItemType[]> {
  const { data: html } = await axios.get(RECWELL_URL, {
    timeout: 10_000,
    headers: {
      "User-Agent": "PurduePersonalTrainer/0.1 (server-side, non-commercial)",
    },
  });

  const $ = cheerio.load(html);
  const facilities: FacilityUsageItemType[] = [];

  // The RecWell page uses divs with facility count data.
  // This selector is a best-effort parse; adjust if the page changes.
  $(".capacity-item, .occupancy-item, [data-facility]").each((_i, el) => {
    const name =
      $(el).find(".facility-name, .name, h3, h4").first().text().trim() ||
      $(el).attr("data-facility") ||
      "Unknown Facility";
    const countText =
      $(el).find(".count, .current, .occupancy-count").first().text().trim();
    const maxText =
      $(el).find(".max, .capacity, .max-capacity").first().text().trim();

    const currentCount = parseInt(countText, 10) || 0;
    const maxCapacity = parseInt(maxText, 10) || 0;

    if (name !== "Unknown Facility" || currentCount > 0) {
      facilities.push({
        facilityName: name,
        currentCount,
        maxCapacity,
        lastUpdated: new Date().toISOString(),
      });
    }
  });

  // If scraping returned nothing, return placeholder data so the
  // endpoint still works during development / when page is down.
  if (facilities.length === 0) {
    return [
      {
        facilityName: "CoRec Main Gym",
        currentCount: 0,
        maxCapacity: 300,
        lastUpdated: new Date().toISOString(),
      },
      {
        facilityName: "CoRec Aquatics Center",
        currentCount: 0,
        maxCapacity: 100,
        lastUpdated: new Date().toISOString(),
      },
      {
        facilityName: "CoRec Feature Gym",
        currentCount: 0,
        maxCapacity: 150,
        lastUpdated: new Date().toISOString(),
      },
    ];
  }

  return facilities;
}
