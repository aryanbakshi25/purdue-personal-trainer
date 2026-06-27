# Architecture

**Tags:** `#architecture` `#design-patterns` `#data-flow` `#decisions`

## System Overview

```mermaid
graph TB
    subgraph Client["Mobile App (Flutter)"]
        UI[Feature Screens]
        Providers[Riverpod Providers]
        ApiClient[ApiClient - Dio]
        FirestoreSDK[Firestore SDK - Realtime]
    end

    subgraph Backend["Cloud Functions (Express)"]
        AuthMW[Auth Middleware]
        Routes[Route Handlers]
        PlanGen[Plan Generator]
        GeminiSvc[Gemini Service]
        Scraper[Facility Scraper]
        ICSParser[ICS Parser]
    end

    subgraph External["External Services"]
        Gemini[Vertex AI - Gemini 2.0 Flash]
        RecWell[Purdue RecWell Website]
    end

    subgraph Firebase["Firebase Platform"]
        Firestore[(Cloud Firestore)]
        FireAuth[Firebase Auth]
    end

    UI --> Providers
    Providers --> ApiClient
    Providers --> FirestoreSDK
    FirestoreSDK -->|Realtime Snapshots| Firestore
    ApiClient -->|HTTPS + Bearer Token| AuthMW
    AuthMW -->|Verify ID Token| FireAuth
    AuthMW --> Routes
    Routes --> PlanGen
    Routes --> GeminiSvc
    Routes --> Scraper
    Routes --> ICSParser
    GeminiSvc --> Gemini
    Scraper --> RecWell
    Routes -->|Admin SDK| Firestore
    Client -->|Google Sign-In| FireAuth
```

## Layered Architecture

### Client Layer (Flutter)
```mermaid
graph LR
    subgraph Features["Feature Screens"]
        Login
        Onboarding
        Home
        Schedule
        Chat
        Profile
        Today
    end

    subgraph State["Riverpod Providers"]
        AuthP[authStateProvider]
        ProfileP[userProfileProvider]
        ScheduleP[scheduleBlocksProvider]
        PlanP[planProvider]
        ChatP[chatMessagesProvider]
        FacilityP[facilityUsageProvider]
    end

    subgraph Infra["Infrastructure"]
        Router[GoRouter]
        API[ApiClient]
        FS[Firestore SDK]
    end

    Features --> State
    State --> Infra
    Router -->|Auth Redirects| Features
```

- **Feature-first organization:** Each feature has its own directory under `lib/features/`
- **Riverpod for state:** Mix of `StreamProvider` (Firestore realtime), `FutureProvider` (API calls), `AsyncNotifier` (complex state), and `StateNotifier` (chat)
- **GoRouter:** Declarative routing with auth-based redirects (login → onboarding → home)
- **ApiClient:** Dio-based HTTP client with `_AuthInterceptor` that auto-attaches Firebase ID tokens

### Backend Layer (Cloud Functions)
```mermaid
graph TB
    Entry[index.ts - onRequest] --> App[app.ts - Express]
    App --> MW[CORS + JSON middleware]
    MW --> Health[GET /api/health]
    MW --> FU[GET /api/facility-usage]
    MW --> Plan[POST /api/plan/generate]
    MW --> ChatRoute[POST /api/chat]
    MW --> ICS[POST /api/schedule/import-ics]

    Plan --> AuthMW[requireAuth]
    ChatRoute --> AuthMW
    ICS --> AuthMW

    Plan --> PlanGen[plan-generator.ts]
    ChatRoute --> GeminiSvc[gemini.ts]
    FU --> Scraper[facility-scraper.ts]
    ICS --> Parser[ics-parser.ts]
```

- **Single Cloud Function:** One `onRequest` handler serves all routes via Express
- **Auth middleware pattern:** `requireAuth` verifies Firebase ID tokens, attaches `uid` to request
- **Service layer:** Business logic isolated from route handlers
- **Validation:** Zod schemas from `@ppt/shared` validate all request bodies

### Data Layer (Firestore)
- **User-scoped data:** `users/{uid}` document + subcollections (`scheduleBlocks`, `plans`)
- **Cache pattern:** `cache/facilityUsage` with 5-minute TTL, writable only by Admin SDK
- **Security rules:** Owner-only access for user data; authenticated-read for cache; default deny

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Server-side Gemini only | API credentials never exposed to client devices |
| Zod shared schemas | Single source of truth; TypeScript types derived from runtime validators |
| Dart models mirror Zod manually | No cross-language codegen; kept in sync by convention |
| Riverpod over BLoC | Simpler API, compile-safe providers, less boilerplate |
| Single Cloud Function entry point | All routes share cold-start cost; simpler deployment |
| Express for routing | Familiar middleware pattern; easy to test in isolation |
| Firestore realtime for schedules | Instant UI updates without polling |
| Rule-based plan gen (Phase 1) | Deterministic, testable; Gemini upgrade planned for Phase 2 |

## Deployment Architecture

```mermaid
graph LR
    Dev[Developer] -->|pnpm emulators| Emulators[Firebase Emulators]
    Dev -->|flutter run| App[Flutter App]
    App -->|10.0.2.2:5001| Emulators

    CI[GitHub Actions] -->|push to main| Build[Lint + Test]
    Deploy[firebase deploy] --> Prod[Cloud Functions us-central1]
    App2[Production App] -->|HTTPS| Prod
```

- **Local development:** Firebase Emulators (Auth, Functions, Firestore) + Flutter hot reload
- **CI:** GitHub Actions runs lint/typecheck/test on push and PR to `main`
- **Deployment:** Manual `firebase deploy --only functions` (no CD pipeline yet)

## Cross-References

- API contract details → [interfaces.md](interfaces.md)
- Component responsibilities → [components.md](components.md)
- Data structure specifics → [data_models.md](data_models.md)
- End-to-end flows → [workflows.md](workflows.md)
