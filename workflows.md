# Workflows

**Tags:** `#workflows` `#sequences` `#user-flows` `#feature-flows`

## 1. Authentication (Google Sign-In)

```mermaid
sequenceDiagram
    participant User
    participant App as Flutter App
    participant Google as Google Sign-In
    participant Auth as Firebase Auth
    participant Router as GoRouter

    User->>App: Tap "Sign in with Google"
    App->>Google: googleSignIn.signIn()
    Google-->>App: GoogleSignInAccount (access + id token)
    App->>Auth: signInWithCredential(GoogleCredential)
    Auth-->>App: UserCredential (uid, email, etc.)
    App->>Router: authStateProvider emits user
    Router->>Router: Redirect to /onboarding or /home
```

**Key points:**
- `authStateProvider` (StreamProvider) listens to `FirebaseAuth.authStateChanges()`
- GoRouter redirect logic: no auth → `/login`, no profile → `/onboarding`, else → `/home`
- Emulator mode uses `signInWithEmulator()` with email/password fallback

---

## 2. Onboarding (Profile Setup)

```mermaid
sequenceDiagram
    participant User
    participant Screen as OnboardingScreen
    participant Firestore as Cloud Firestore

    User->>Screen: Fill in fitness level, goals, split, facilities
    Screen->>Screen: Multi-step form with validation
    User->>Screen: Submit
    Screen->>Firestore: Set users/{uid} document
    Firestore-->>Screen: Success
    Screen->>Screen: userProfileProvider refreshes
    Note over Screen: GoRouter redirects to /home
```

---

## 3. Schedule Management (CRUD)

```mermaid
sequenceDiagram
    participant User
    participant Tab as ScheduleTab
    participant Service as ScheduleService
    participant Firestore as Cloud Firestore
    participant Provider as scheduleBlocksProvider

    User->>Tab: View schedule
    Provider->>Firestore: Listen to scheduleBlocks (realtime)
    Firestore-->>Provider: Stream of blocks
    Provider-->>Tab: Display blocks grouped by day

    User->>Tab: Tap "Add Block"
    Tab->>Tab: Navigate to ScheduleEditScreen
    User->>Tab: Fill form + save
    Tab->>Service: addBlock(block)
    Service->>Firestore: Set scheduleBlocks/{id}
    Note over Firestore,Provider: Realtime snapshot updates UI automatically
```

---

## 4. Plan Generation

```mermaid
sequenceDiagram
    participant User
    participant Tab as TodayTab
    participant Provider as planProvider
    participant API as ApiClient
    participant CF as Cloud Function
    participant PlanGen as plan-generator.ts
    participant Firestore as Cloud Firestore

    User->>Tab: Tap "Generate Plan"
    Tab->>Provider: generatePlan()
    Provider->>API: POST /api/plan/generate
    Note over API: Sends profile + scheduleBlocks + date
    API->>CF: HTTPS + Bearer token
    CF->>CF: requireAuth (verify token)
    CF->>PlanGen: generateDailyPlan(uid, profile, blocks, date)
    PlanGen->>PlanGen: Find free slots in schedule
    PlanGen->>PlanGen: Build workout items based on fitness level/split
    PlanGen-->>CF: DailyPlan object
    CF->>Firestore: Save to users/{uid}/plans/{date}
    CF-->>API: 200 + DailyPlan JSON
    API-->>Provider: DailyPlan
    Provider-->>Tab: Display plan items
```

**Plan generation logic:**
1. Determine day of week from date
2. Filter schedule blocks to that day
3. Find free time slots (between 08:00–22:00)
4. For slots ≥60 min: suggest full workout (based on split + fitness level)
5. For slots 30–59 min: suggest quick cardio/stretching
6. If no early blocks: prepend 07:00 morning warm-up

---

## 5. AI Chat

```mermaid
sequenceDiagram
    participant User
    participant Tab as ChatTab
    participant Notifier as ChatNotifier
    participant API as ApiClient
    participant CF as Cloud Function
    participant Firestore as Cloud Firestore
    participant Gemini as Vertex AI Gemini

    User->>Tab: Type message + send
    Tab->>Notifier: sendMessage(text)
    Notifier->>Notifier: Add user message to state
    Notifier->>API: POST /api/chat {message, conversationHistory}
    API->>CF: HTTPS + Bearer token
    CF->>CF: requireAuth
    CF->>Firestore: Load profile, scheduleBlocks, today's plan, facility cache
    CF->>Gemini: generateContent(systemPrompt + context + history + message)
    Gemini-->>CF: AI response text
    CF-->>API: {reply, disclaimer}
    API-->>Notifier: Response
    Notifier->>Notifier: Add assistant message to state
    Notifier-->>Tab: UI updates with new message
```

**Gemini context injection:**
- System instruction defines role as Purdue fitness assistant with safety guardrails
- User context (profile, schedule, plan, facility data) injected as first message pair
- Conversation history maintained client-side (max 50 messages)

---

## 6. ICS Import

```mermaid
sequenceDiagram
    participant User
    participant App as Flutter App
    participant API as ApiClient
    participant CF as Cloud Function
    participant External as ICS URL (Purdue Registrar)
    participant Parser as ics-parser.ts

    User->>App: Provide ICS URL
    App->>API: POST /api/schedule/import-ics {icsUrl}
    API->>CF: HTTPS + Bearer token
    CF->>CF: requireAuth
    CF->>External: GET icsUrl (15s timeout, 5MB max)
    External-->>CF: ICS file content
    CF->>Parser: parseIcsContent(icsData)
    Parser->>Parser: Parse VEVENT entries
    Parser->>Parser: Expand recurring events (6 months)
    Parser-->>CF: {events[], warnings[]}
    CF-->>API: IcsImportResponse
    API-->>App: Display parsed events
    Note over App: User can then convert events to ScheduleBlocks
```

---

## 7. Facility Usage

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as ApiClient
    participant CF as Cloud Function
    participant Firestore as Cloud Firestore
    participant RecWell as Purdue RecWell Page

    App->>API: GET /api/facility-usage
    API->>CF: HTTPS (no auth required)
    CF->>Firestore: Read cache/facilityUsage
    alt Cache valid (< 5 min old)
        Firestore-->>CF: Cached data
        CF-->>API: {facilities, fromCache: true}
    else Cache expired or missing
        CF->>RecWell: HTTP GET + cheerio scrape
        RecWell-->>CF: HTML response
        CF->>CF: Parse facility counts
        CF->>Firestore: Update cache/facilityUsage
        CF-->>API: {facilities, fromCache: false}
    end
    API-->>App: FacilityUsageItem[]
```

---

## CI Workflows

```mermaid
graph LR
    subgraph Trigger["Push/PR to main"]
        FunctionsChange["functions/** or packages/shared/**"]
        FlutterChange["apps/mobile/**"]
    end

    subgraph FunctionsCI["functions.yml"]
        Install[pnpm install]
        BuildShared[Build @ppt/shared]
        Lint[Lint functions]
        Typecheck[Build/typecheck functions]
        TestShared[Test shared]
        TestFunctions[Test functions]
    end

    subgraph FlutterCI["flutter.yml"]
        PubGet[flutter pub get]
        Analyze[flutter analyze]
        Test[flutter test]
    end

    FunctionsChange --> FunctionsCI
    FlutterChange --> FlutterCI
    Install --> BuildShared --> Lint --> Typecheck --> TestShared --> TestFunctions
    PubGet --> Analyze --> Test
```

---

## Cross-References

- API request/response details → [interfaces.md](interfaces.md)
- Component implementation details → [components.md](components.md)
- Data structures flowing through these workflows → [data_models.md](data_models.md)
