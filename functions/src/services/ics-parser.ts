import * as ical from "node-ical";
import type { VEvent, ParameterValue, EventInstance } from "node-ical";
import type { IcsEventType } from "@ppt/shared";

interface ParseResult {
  events: IcsEventType[];
  warnings: string[];
}

/**
 * Parse an ICS string and return normalized IcsEvent objects.
 * Recurring events are expanded into individual instances.
 */
export function parseIcsContent(icsData: string): ParseResult {
  const events: IcsEventType[] = [];
  const warnings: string[] = [];

  let parsed: ical.CalendarResponse;
  try {
    parsed = ical.parseICS(icsData);
  } catch {
    return { events: [], warnings: ["Failed to parse ICS content"] };
  }

  const vevents = Object.values(parsed).filter(
    (c): c is VEvent => c !== undefined && c.type === "VEVENT"
  );

  if (vevents.length === 0) {
    warnings.push("No VEVENT entries found in the ICS data");
    return { events, warnings };
  }

  for (const event of vevents) {
    try {
      if (event.rrule) {
        const expanded = expandRecurring(event, warnings);
        events.push(...expanded);
      } else {
        const mapped = mapSingleEvent(event);
        if (mapped) {
          events.push(mapped);
        } else {
          warnings.push(
            `Skipped event "${extractString(event.summary)}": missing start or end time`
          );
        }
      }
    } catch {
      warnings.push(
        `Failed to parse event "${extractString(event.summary)}"`
      );
    }
  }

  return { events, warnings };
}

function expandRecurring(event: VEvent, warnings: string[]): IcsEventType[] {
  const results: IcsEventType[] = [];
  const rruleString = event.rrule?.toString() ?? undefined;

  // Expand from the event's start date up to 6 months after it
  // (covers a full semester even for past/future events)
  const from = new Date(event.start);
  const to = new Date(event.start);
  to.setMonth(to.getMonth() + 6);

  let instances: EventInstance[];
  try {
    instances = ical.expandRecurringEvent(event, { from, to });
  } catch {
    warnings.push(
      `Failed to expand recurrence for "${extractString(event.summary)}"`
    );
    // Fall back to the base event as a single instance
    const mapped = mapSingleEvent(event);
    if (mapped) results.push(mapped);
    return results;
  }

  for (const instance of instances) {
    const summary = extractString(instance.summary) || extractString(event.summary) || "Untitled Event";
    const location = extractString(event.location) || undefined;

    results.push({
      summary,
      startTime: instance.start.toISOString(),
      endTime: instance.end.toISOString(),
      location,
      recurrence: rruleString,
    });
  }

  return results;
}

function mapSingleEvent(event: VEvent): IcsEventType | null {
  if (!event.start) return null;

  const summary = extractString(event.summary) || "Untitled Event";
  const startTime = event.start.toISOString();

  let endTime: string;
  if (event.end && event.end.getTime() !== event.start.getTime()) {
    endTime = event.end.toISOString();
  } else {
    // Default to 1 hour if no end time (node-ical sets end === start when DTEND is missing)
    const end = new Date(event.start.getTime() + 60 * 60 * 1000);
    endTime = end.toISOString();
  }

  const location = extractString(event.location) || undefined;
  const recurrence = event.rrule?.toString() ?? undefined;

  return { summary, startTime, endTime, location, recurrence };
}

/** Extract a plain string from a ParameterValue (which may be string or { val, params }). */
function extractString(value: ParameterValue | undefined): string {
  if (value === undefined || value === null) return "";
  if (typeof value === "string") return value;
  if (typeof value === "object" && "val" in value) return value.val;
  return "";
}
