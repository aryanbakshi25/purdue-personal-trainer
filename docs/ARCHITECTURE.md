# Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mobile App (Flutter)                      │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │  Login    │  │  Today   │  │ Schedule │  │   Chat           │ │
│  │ (Google)  │  │  (Plan + │  │  (CRUD)  │  │  (AI Assistant)  │ │
│  │          │  │ Facility) │  │          │  │                  │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬──────────┘ │
│       │              │             │                │            │
│  ┌────┴──────────────┴─────────────┴────────────────┴──────────┐ │
│  │              Riverpod Providers + API Client (Dio)           │ │
│  └─────────────────────────┬───────────────────────────────────┘ │
└────────────────────────────┼─────────────────────────────────────┘
                             │ HTTPS + Firebase ID Token
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Cloud Functions (Express)                       │
│                                                                  │
│  ┌─────────────┐  Auth Middleware (verify ID token)              │
│  │             │                                                 │
│  │  /api/      │  ┌──────────────────┐  ┌─────────────────────┐ │
│  │  facility-  │  │ /api/plan/       │  │ /api/chat           │ │
│  │  usage      │  │ generate         │  │                     │ │
│  │             │  │                  │  │ Loads user context   │ │
│  │ Scrapes     │  │ Rule-based plan  │  │ → calls Gemini      │ │
│  │ RecWell     │  │ generator        │  │   (Vertex AI)       │ │
│  │ + caches    │  │                  │  │   server-side only  │ │
│  └──────┬──────┘  └────────┬─────────┘  └──────────┬──────────┘ │
│         │                  │                       │            │
│  ┌──────┴──────────────────┴───────────────────────┴──────────┐ │
│  │                    Firebase Admin SDK                        │ │
│  └─────────────────────────┬───────────────────────────────────┘ │
└────────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Firestore                                 │
│                                                                  │
│  users/{uid}                                                     │
│    ├── displayName, email, fitnessLevel, goals, ...             │
│    ├── scheduleBlocks/{blockId}                                  │
│    │     └── title, dayOfWeek, startTime, endTime, ...          │
│    └── plans/{dateId}                                            │
│          └── items[], generatedAt, disclaimer                    │
│                                                                  │
│  cache/facilityUsage                                             │
│    └── facilities[], cachedAt                                    │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Authentication
1. User taps "Sign in with Google" → Firebase Auth (Google provider)
2. On success, app gets Firebase ID token
3. All API calls include `Authorization: Bearer <token>`
4. Cloud Functions verify the token via `admin.auth().verifyIdToken()`

### 2. Schedule Management
1. User creates/edits schedule blocks in the app
2. Blocks are written directly to Firestore: `users/{uid}/scheduleBlocks/{id}`
3. App listens to realtime snapshots via Riverpod StreamProvider
4. Security rules ensure users can only access their own data

### 3. Plan Generation
1. User requests a plan → app sends profile + schedule to `POST /api/plan/generate`
2. Cloud Function runs rule-based generator (Phase 1) or Gemini (Phase 2)
3. Plan is saved to `users/{uid}/plans/{date}` and returned to app

### 4. Chat (AI Assistant)
1. User sends message → `POST /api/chat`
2. Cloud Function loads context: profile, schedule, today's plan, facility usage
3. Calls Gemini via Vertex AI (server-side, no API keys on client)
4. Returns response with disclaimer

### 5. Facility Usage
1. App requests `GET /api/facility-usage`
2. Cloud Function checks Firestore cache (`cache/facilityUsage`)
3. If cache expired (5 min TTL), scrapes Purdue RecWell page
4. Returns normalized facility data

## Project Structure

```
/
├── apps/mobile/           Flutter app
│   ├── lib/
│   │   ├── app/           App root widget
│   │   ├── features/      Feature modules (auth, chat, home, etc.)
│   │   ├── models/        Dart data models (mirrors shared schemas)
│   │   ├── providers/     Riverpod providers (state management)
│   │   ├── services/      API client, auth service
│   │   └── shared/        Theme, routing, shared widgets
│   └── test/              Widget and unit tests
├── functions/             Firebase Cloud Functions
│   ├── src/
│   │   ├── routes/        Express route handlers
│   │   ├── middleware/     Auth middleware
│   │   ├── services/      Gemini, scraper, plan generator
│   │   └── index.ts       Entry point
│   └── test/              Unit tests
├── packages/shared/       Shared TypeScript schemas (Zod)
├── docs/                  Documentation
└── firebase.json          Firebase project config
```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Gemini server-side only | API keys must not exist on client devices |
| Riverpod over BLoC | Simpler API, compile-safe, good for team onboarding |
| GoRouter | Declarative routing with auth redirects, deep-link ready |
| Express in Cloud Functions | Familiar to most devs, easy to test, middleware support |
| Zod schemas in shared | Single source of truth for validation, TypeScript-native |
| Firestore realtime | Schedule blocks update instantly across devices |
| Facility usage caching | Avoids hammering RecWell page; 5-min TTL is reasonable |

## Phase 2 Plans

- ICS import (parse .ics calendar files into schedule blocks)
- UPlate integration (deep-link to dining recommendations)
- Gemini-powered plan generation (replace rule-based)
- Workout tracking and history
- Push notifications for plan reminders
