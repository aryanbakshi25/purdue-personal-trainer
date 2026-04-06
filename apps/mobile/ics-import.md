# ICS Import Endpoint — Implementation Notes

## Branch
`feat/ics-import`

## Task Summary
Implement `POST /api/schedule/import-ics` endpoint. Fetch an ICS file from a URL, parse VEVENT entries, expand recurring events to individual day-of-week entries, return as `IcsEvent[]` (ISO datetimes). No Firestore writes — client handles saving.

---

## Files to Modify / Create

| Action | File | Notes |
|--------|------|-------|
| Modify | `functions/src/routes/ics-import.ts` | Replace 501 stub with real implementation |
| Create | `functions/src/services/ics-parser.ts` | Pure function: ICS string → IcsEvent[] |
| Create | `functions/test/ics-parser.test.ts` | Unit tests for the parser |
| Install | `node-ical` in functions/ | ICS parsing library (simpler API than raw ical.js) |

---

## Key Decisions

1. **Input**: URL only — keep existing `IcsImportRequest` schema (`{ icsUrl: string }`)
2. **Output**: `IcsEvent[]` in ISO datetime format — keep existing `IcsImportResponse` schema
3. **No Firestore writes** — endpoint only parses and returns events; client saves to `scheduleBlocks/`
4. **Recurring events**: Expand RRULE (e.g., MWF weekly) into individual event instances with their specific datetimes
5. **Library**: `node-ical` — simpler API, wraps ical.js, good for async URL fetching
6. **Import mode**: Append (not relevant server-side since no Firestore write, but noted for client)

---

## Architecture

### Route: `ics-import.ts`
```
1. Validate request body with IcsImportRequest.safeParse()
2. Fetch ICS content from icsUrl using axios
3. Pass raw ICS string to parseIcsContent()
4. Validate each event against IcsEvent schema
5. Return IcsImportResponse { events, warnings }
```

### Service: `ics-parser.ts`
```
parseIcsContent(icsData: string): { events: IcsEventType[], warnings: string[] }

1. Parse ICS string using node-ical (sync parse, not async URL fetch)
2. Iterate VEVENT entries
3. For each event:
   - Extract SUMMARY → summary
   - Extract DTSTART → startTime (ISO string)
   - Extract DTEND → endTime (ISO string)
   - Extract LOCATION → location (optional)
   - Extract RRULE → expand recurring events
4. For recurring events:
   - Use rrule expansion to generate instances
   - Cap at some reasonable limit (e.g., 1 semester ≈ 16 weeks)
   - Each instance gets its own startTime/endTime
5. Validate each event with IcsEvent schema
6. Collect warnings for any events that fail validation or have issues
```

---

## IcsEvent Schema (existing, no changes needed)
```typescript
{
  summary: string,        // from SUMMARY
  startTime: string,      // ISO datetime from DTSTART
  endTime: string,        // ISO datetime from DTEND
  location: string?,      // from LOCATION
  recurrence: string?,    // raw RRULE string (for reference)
}
```

---

## Recurring Event Expansion

Purdue ICS files (e.g., from Brightspace/Banner) typically have:
- `RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR;UNTIL=...`
- `RRULE:FREQ=WEEKLY;BYDAY=TU,TH;UNTIL=...`

Expansion strategy:
- Use node-ical's built-in RRULE handling (it uses `rrule` internally)
- Generate all instances within the RRULE's UNTIL date (or cap at 6 months from now)
- Each instance becomes a separate IcsEvent with concrete start/end times
- Store the original RRULE string in the `recurrence` field of each expanded event

---

## Error Handling

- **Invalid URL**: 400 error (Zod validation catches this)
- **Fetch failure**: 502 error ("Failed to fetch ICS file from URL")
- **Parse failure**: 422 error ("Failed to parse ICS content")
- **No events found**: 200 with empty events array + warning
- **Partial parse**: 200 with successfully parsed events + warnings for skipped entries

---

## Unit Tests (`ics-parser.test.ts`)

Test cases:
1. Parse a simple ICS string with one non-recurring event
2. Parse ICS with recurring weekly events (MWF) — verify expansion
3. Handle missing SUMMARY gracefully (use "Untitled Event")
4. Handle missing DTEND (use DTSTART + DURATION, or skip with warning)
5. Handle missing LOCATION (optional field)
6. Skip non-VEVENT components (VTODO, VFREEBUSY, etc.)
7. Return warning for unparseable events
8. Empty ICS file → empty events + warning

---

## Dependencies

- `node-ical` — ICS parsing with RRULE expansion
- `axios` — already available for HTTP fetching (or use node-ical's async fetch)

---

## Implementation Progress

- [x] Install `node-ical` (types are bundled, no separate `@types` needed)
- [x] Create `ics-parser.ts` service — `parseIcsContent()` handles single + recurring events
- [x] Update `ics-import.ts` route — fetches URL with axios, passes to parser, returns IcsImportResponse
- [x] Create `ics-parser.test.ts` — 9 unit tests covering: single event, missing summary, missing DTEND, multiple events, non-VEVENT skipping, recurring expansion, empty/invalid ICS, missing location
- [x] Build check (`tsc`) — passes
- [x] Run tests (`vitest run`) — 14/14 pass (5 existing + 9 new)

---

## Bugs Found & Fixed During Implementation

1. **Recurring expansion date range**: Initially used `new Date()` (current date) as `from`. Since test events are from Jan 2025 and current date is 2026, no instances were found. Fixed: use `event.start` as the `from` date, expand 6 months forward from there.

2. **Missing DTEND handling**: node-ical sets `end === start` (same Date object) when DTEND is absent, rather than leaving `end` as undefined. My code checked `if (event.end)` which was always truthy. Fixed: check `event.end.getTime() !== event.start.getTime()` to detect the default-same-time case, then apply 1-hour fallback.

---

## Considerations

1. **`ParameterValue` extraction.** node-ical's `summary` and `location` fields can be either a plain `string` or `{ val: string, params: Record }` when the ICS property has parameters (e.g., `SUMMARY;LANGUAGE=en:Meeting`). The `extractString()` helper handles both cases transparently. Any new fields pulled from VEvent should use it.

2. **Recurring expansion window.** Expansion uses `event.start` → `event.start + 6 months`. This covers a full Purdue semester. If a user imports a calendar with year-long recurring events, only the first 6 months of instances are returned. This is a deliberate cap to avoid returning thousands of events. Could be made configurable via a query param if needed.

3. **No Firestore writes server-side.** The endpoint is purely a parser — the client receives `IcsEvent[]` and is responsible for converting to `ScheduleBlock` objects and writing to Firestore. This keeps the endpoint stateless and testable, but means the client needs conversion logic (ISO datetime → dayOfWeek + HH:mm).

4. **Axios fetch limits.** The route sets `maxContentLength: 5MB` and `timeout: 15000ms`. Purdue ICS files are typically small (< 100KB), but the limits protect against abuse or accidentally pointing at large files.

5. **Error granularity.** Parse failures for individual events don't fail the whole request — they add a warning and continue. Only total ICS parse failure or fetch failure returns an error status. This is important for real-world ICS files that may have malformed entries mixed with valid ones.

6. **`parseICS` is synchronous.** node-ical's `parseICS()` (without callback) is a sync call. For very large ICS files this could block the event loop briefly, but Cloud Functions are single-request-per-instance so this is fine. If moved to a shared server, consider using the async variant.

7. **Test ICS strings use inline heredoc format.** The `makeIcs()` helper wraps VEVENT blocks in a valid VCALENDAR envelope. Tests don't hit the network — they test the parser in isolation. Route-level integration testing (with auth + axios mocking) is not included and would require mocking Firebase Admin + HTTP calls.
