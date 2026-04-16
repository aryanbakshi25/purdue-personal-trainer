import { describe, it, expect } from "vitest";
import { parseIcsContent } from "../src/services/ics-parser";

const makeIcs = (vevents: string) => `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//Test//EN
${vevents}
END:VCALENDAR`;

const singleEvent = makeIcs(`BEGIN:VEVENT
UID:test-1@example.com
DTSTART:20250115T093000Z
DTEND:20250115T102000Z
SUMMARY:CS 252 Lecture
LOCATION:LWSN B134
END:VEVENT`);

const noSummary = makeIcs(`BEGIN:VEVENT
UID:test-2@example.com
DTSTART:20250115T140000Z
DTEND:20250115T150000Z
END:VEVENT`);

const noEndTime = makeIcs(`BEGIN:VEVENT
UID:test-3@example.com
DTSTART:20250115T140000Z
SUMMARY:Office Hours
END:VEVENT`);

const multipleEvents = makeIcs(`BEGIN:VEVENT
UID:test-4@example.com
DTSTART:20250115T093000Z
DTEND:20250115T102000Z
SUMMARY:CS 252
LOCATION:LWSN B134
END:VEVENT
BEGIN:VEVENT
UID:test-5@example.com
DTSTART:20250115T113000Z
DTEND:20250115T122000Z
SUMMARY:MA 265
LOCATION:UNIV 101
END:VEVENT`);

const withTodo = makeIcs(`BEGIN:VEVENT
UID:test-6@example.com
DTSTART:20250115T093000Z
DTEND:20250115T102000Z
SUMMARY:Lecture
END:VEVENT
BEGIN:VTODO
UID:todo-1@example.com
SUMMARY:Homework
END:VTODO`);

const recurringEvent = makeIcs(`BEGIN:VEVENT
UID:test-7@example.com
DTSTART:20250113T093000Z
DTEND:20250113T102000Z
SUMMARY:CS 252 Lecture
LOCATION:LWSN B134
RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=6
END:VEVENT`);

describe("parseIcsContent", () => {
  it("parses a single non-recurring event", () => {
    const { events, warnings } = parseIcsContent(singleEvent);

    expect(events).toHaveLength(1);
    expect(events[0].summary).toBe("CS 252 Lecture");
    expect(events[0].startTime).toContain("2025-01-15");
    expect(events[0].endTime).toContain("2025-01-15");
    expect(events[0].location).toBe("LWSN B134");
    expect(events[0].recurrence).toBeUndefined();
    expect(warnings).toHaveLength(0);
  });

  it("uses 'Untitled Event' when SUMMARY is missing", () => {
    const { events } = parseIcsContent(noSummary);

    expect(events).toHaveLength(1);
    expect(events[0].summary).toBe("Untitled Event");
  });

  it("defaults to 1 hour duration when DTEND is missing", () => {
    const { events } = parseIcsContent(noEndTime);

    expect(events).toHaveLength(1);
    const start = new Date(events[0].startTime).getTime();
    const end = new Date(events[0].endTime).getTime();
    expect(end - start).toBe(60 * 60 * 1000); // 1 hour
  });

  it("parses multiple events", () => {
    const { events } = parseIcsContent(multipleEvents);

    expect(events).toHaveLength(2);
    const summaries = events.map((e) => e.summary);
    expect(summaries).toContain("CS 252");
    expect(summaries).toContain("MA 265");
  });

  it("skips non-VEVENT components (VTODO)", () => {
    const { events } = parseIcsContent(withTodo);

    expect(events).toHaveLength(1);
    expect(events[0].summary).toBe("Lecture");
  });

  it("expands recurring weekly events", () => {
    const { events, warnings } = parseIcsContent(recurringEvent);

    // RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=6 should produce 6 instances
    expect(events.length).toBe(6);
    expect(warnings).toHaveLength(0);

    // All should have the same summary
    for (const event of events) {
      expect(event.summary).toBe("CS 252 Lecture");
      expect(event.location).toBe("LWSN B134");
      expect(event.recurrence).toBeDefined();
    }

    // Should have instances on different days
    const dates = events.map((e) => new Date(e.startTime).toISOString().split("T")[0]);
    const uniqueDates = new Set(dates);
    expect(uniqueDates.size).toBeGreaterThan(1);
  });

  it("returns warning for empty ICS content", () => {
    const emptyIcs = makeIcs("");
    const { events, warnings } = parseIcsContent(emptyIcs);

    expect(events).toHaveLength(0);
    expect(warnings.length).toBeGreaterThan(0);
  });

  it("returns warning for invalid ICS content", () => {
    const { events, warnings } = parseIcsContent("not valid ics data");

    expect(events).toHaveLength(0);
    expect(warnings.length).toBeGreaterThan(0);
  });

  it("sets location to undefined when not provided", () => {
    const noLocation = makeIcs(`BEGIN:VEVENT
UID:test-8@example.com
DTSTART:20250115T093000Z
DTEND:20250115T102000Z
SUMMARY:Meeting
END:VEVENT`);

    const { events } = parseIcsContent(noLocation);
    expect(events[0].location).toBeUndefined();
  });
});
