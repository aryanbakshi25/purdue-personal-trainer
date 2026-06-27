# Data Models

**Tags:** `#schemas` `#firestore` `#zod` `#dart-models` `#validation`

## Schema Authority

The **single source of truth** for all data structures is:
```
packages/shared/src/schemas.ts
```

Dart models in `apps/mobile/lib/models/` mirror these schemas manually. Changes to schemas must be reflected in both places.

---

## Zod Schemas (TypeScript)

### ScheduleBlock

```mermaid
classDiagram
    class ScheduleBlock {
        +string id [UUID]
        +string title [1-200 chars]
        +DayOfWeek dayOfWeek
        +string startTime [HH:mm]
        +string endTime [HH:mm]
        +string? location [max 200]
        +string category [default: "other"]
        +boolean isRecurring [default: true]
    }
```

**DayOfWeek enum:** `monday | tuesday | wednesday | thursday | friday | saturday | sunday`

**Firestore path:** `users/{uid}/scheduleBlocks/{id}`

---

### UserProfile

```mermaid
classDiagram
    class UserProfile {
        +string uid
        +string displayName [max 100]
        +string email
        +string? photoUrl
        +FitnessLevel fitnessLevel [default: beginner]
        +string[] goals [max 10 items]
        +WorkoutSplit? workoutSplit
        +string[] preferredFacilities [max 10]
        +datetime createdAt
        +datetime updatedAt
    }
```

**FitnessLevel enum:** `beginner | intermediate | advanced | athlete`

**WorkoutSplit enum:** `ppl | upper_lower | full_body | bro_split`

**Firestore path:** `users/{uid}`

---

### DailyPlan & PlanItem

```mermaid
classDiagram
    class DailyPlan {
        +string id
        +string uid
        +string date [YYYY-MM-DD]
        +PlanItem[] items
        +datetime generatedAt
        +string disclaimer
    }

    class PlanItem {
        +string time [HH:mm]
        +number duration [5-480 min]
        +string activity [max 200]
        +string category [max 50]
        +string? location [max 200]
        +string? notes [max 500]
    }

    DailyPlan --> PlanItem : items[]
```

**Firestore path:** `users/{uid}/plans/{date}`

---

### FacilityUsageItem

```mermaid
classDiagram
    class FacilityUsageItem {
        +string facilityName
        +number currentCount [≥0]
        +number maxCapacity [≥0]
        +datetime lastUpdated
    }
```

**Firestore path:** `cache/facilityUsage` (field: `facilities[]`)

---

### Chat Models

```mermaid
classDiagram
    class ChatMessage {
        +ChatRole role
        +string content [max 5000]
        +datetime? timestamp
    }

    class ChatRequest {
        +string message [1-2000]
        +ChatMessage[] conversationHistory [max 50]
    }

    class ChatResponse {
        +string reply
        +string disclaimer
    }
```

**ChatRole enum:** `user | assistant`

Chat messages are not persisted to Firestore (kept in client memory only via `StateNotifier`).

---

### ICS Import Models

```mermaid
classDiagram
    class IcsImportRequest {
        +string icsUrl [valid URL]
    }

    class IcsEvent {
        +string summary
        +datetime startTime
        +datetime endTime
        +string? location
        +string? recurrence
    }

    class IcsImportResponse {
        +IcsEvent[] events
        +string[] warnings
    }
```

---

## Firestore Structure

```mermaid
graph TB
    Root["/"] --> Users["users/{uid}"]
    Root --> Cache["cache/facilityUsage"]

    Users --> Profile["(UserProfile fields)"]
    Users --> SB["scheduleBlocks/{blockId}"]
    Users --> Plans["plans/{date}"]

    SB --> SBDoc["(ScheduleBlock fields)"]
    Plans --> PlanDoc["(DailyPlan fields)"]
    Cache --> CacheDoc["facilities[] + cachedAt"]
```

### Collection Paths (from `@ppt/shared`)

```typescript
export const Collections = {
  USERS: "users",
  SCHEDULE_BLOCKS: (uid: string) => `users/${uid}/scheduleBlocks`,
  PLANS: (uid: string) => `users/${uid}/plans`,
  FACILITY_CACHE: "cache/facilityUsage",
};
```

### Security Rules Summary

| Path | Read | Write |
|------|------|-------|
| `users/{uid}` | Owner only | Owner only |
| `users/{uid}/scheduleBlocks/{id}` | Owner only | Owner only |
| `users/{uid}/plans/{id}` | Owner only | Owner only |
| `cache/{docId}` | Any authenticated user | Admin SDK only |
| Everything else | Denied | Denied |

---

## Constants

| Constant | Value | Location |
|----------|-------|----------|
| `FACILITY_CACHE_TTL_MS` | `300000` (5 min) | `packages/shared/src/index.ts` |
| Gemini model | `gemini-2.0-flash` | `functions/src/services/gemini.ts` |
| Gemini max tokens | `1024` | `functions/src/services/gemini.ts` |
| Gemini temperature | `0.7` | `functions/src/services/gemini.ts` |
| ICS fetch timeout | `15000ms` | `functions/src/routes/ics-import.ts` |
| ICS max size | `5MB` | `functions/src/routes/ics-import.ts` |
| Recurring event horizon | `6 months` | `functions/src/services/ics-parser.ts` |

---

## Cross-References

- How models flow through APIs → [interfaces.md](interfaces.md)
- Which components own which models → [components.md](components.md)
- End-to-end data flow → [workflows.md](workflows.md)
