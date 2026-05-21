# Purdue Personal Trainer – Current State

_Last updated: 2026-05-20_

## Project Overview

AI-powered fitness planning mobile app for Purdue University students. A Flutter app (Android + iOS) backed by Firebase Cloud Functions (Node.js 20, TypeScript) with a Gemini-powered chat assistant and schedule-aware workout planning.

**Tech stack:**
- Mobile: Flutter/Dart (Riverpod, GoRouter, Material 3)
- Backend: Firebase Cloud Functions (Express + TypeScript)
- AI: Gemini 2.0 Flash via Vertex AI (server-side only)
- Database: Cloud Firestore
- Auth: Firebase Auth (Google Sign-In)
- Shared schemas: `@ppt/shared` (Zod)

**Repository structure:**
```
apps/mobile        Flutter app
functions          Firebase Cloud Functions
packages/shared    Shared Zod schemas (used by functions and referenced by Flutter)
```

---

## Build & Run Instructions

### Prerequisites
- Flutter 3.33+ (`flutter --version`)
- Node 20 (see note below)
- pnpm 9+ (`npm i -g pnpm`)
- Firebase CLI (`npm i -g firebase-tools`)

> **Note:** The `functions/` `engines` field pins `"node": "20"`. Using Node 25 (current default on this machine) triggers a pnpm engine warning but builds and tests still pass. For production deploy to Firebase, Node 20 is required (configured in `functions/package.json` `engines`).

### Install dependencies
```bash
pnpm install
cd apps/mobile && flutter pub get && cd ../..
```

### Build TypeScript packages
```bash
pnpm run build          # builds @ppt/shared and @ppt/functions
```

### Run tests
```bash
pnpm run test           # Node: shared (15 tests) + functions (18 tests)
cd apps/mobile && flutter test   # Dart: 13 tests
```

### Lint
```bash
pnpm run lint           # ESLint for functions and shared
cd apps/mobile && flutter analyze
```

### Start Firebase emulators
```bash
pnpm emulators
```

### Run Flutter app
```bash
cd apps/mobile && flutter run
# For Android emulator, pass --dart-define=EMULATOR_HOST=10.0.2.2
# For iOS simulator / desktop, default 127.0.0.1 works
```

### Deploy
```bash
pnpm run deploy:functions   # firebase deploy --only functions (runs lint + build first)
pnpm run deploy:rules       # firebase deploy --only firestore:rules
```

---

## Issues Table

| ID | Priority | Area | Description | Status |
|----|----------|------|-------------|--------|
| 1 | **P1** | Backend / Deploy | ESLint v9 requires `eslint.config.js`; both `functions/` and `packages/shared/` only had `.eslintrc.json` (v8 format), so `pnpm run lint` and the Firebase `predeploy` hook failed with "couldn't find eslint.config" | **Fixed** – created `eslint.config.mjs` for both packages |
| 2 | **P1** | Flutter / Feature | `plan_provider.dart::generatePlan()` called `POST /api/plan/generate` with an **empty body**. The backend requires `{ profile, scheduleBlocks, date }` and returned 400. Plan generation was completely broken. | **Fixed** – provider now reads `userProfileProvider` and `scheduleBlocksProvider` and sends them in the request body |
| 3 | **P2** | Flutter / Lint | `DropdownButtonFormField.value` is deprecated since Flutter 3.33; should use `initialValue` in `schedule_edit_screen.dart` (two occurrences) | **Fixed** – replaced `value:` with `initialValue:` |
| 4 | **P2** | Flutter / Lint | Unnecessary null comparison `user != null` in `profile_tab.dart:285` – `user` is guaranteed non-null at that point (early-return guard at line 53) | **Fixed** – removed redundant check |
| 5 | **P2** | Flutter / Lint | Unnecessary `await` in `return` statement in `auth_provider.dart:50` inside `signInWithEmulator` | **Fixed** – removed the `await` |
| 6 | **P2** | Backend / Lint | Stale `// eslint-disable-next-line @typescript-eslint/no-explicit-any` directive on `gemini.ts:25` – no `any` at that location; the `UserContext` interface uses `Record<string, unknown>` | **Fixed** – removed the directive |
| 7 | **P2** | Infrastructure | Node engine mismatch: `functions/package.json` `engines.node` is `"20"` but host is Node 25. `pnpm install` emits a warning on every run. Firebase Cloud Functions runtime is locked to Node 20 in production so this is a dev-machine config issue. | Skipped – requires `nvm use 20` or `.nvmrc` on the dev machine; not a code fix |
| 8 | **P2** | Flutter / Config | `firebase_options.dart` Android config contains a placeholder API key (`fake-api-key-for-emulator`) and a zeroed `appId`. Works against the emulator in debug mode but will fail in release or if real Android Firebase project is configured. A TODO comment acknowledges this. | Skipped – requires registering an Android app in the Firebase console and downloading `google-services.json` |
| 9 | **P2** | Flutter / Config | `firebase_options.dart::currentPlatform` falls back to iOS options for all non-Android/iOS platforms (`kIsWeb`, macOS, Linux, Windows). The macOS target exists in `apps/mobile/macos/`. Running on macOS host would use iOS Firebase config which may not have matching bundle ID. | Skipped – requires macOS Firebase app registration; low risk since app is iOS/Android only |
| 10 | **P3** | Flutter / UX | Profile tab "Workout Split" and "Preferred Facilities" list tiles have `// TODO: Edit workout split` / `// TODO: Edit preferred facilities` – tapping opens nothing. Onboarding sets these but there's no edit path after onboarding. | Not fixed – feature gap, not a bug |
| 11 | **P3** | Backend / Resilience | `facility-scraper.ts` CSS selectors (`.capacity-item`, `.occupancy-item`) are best-effort guesses at the RecWell page structure. If the page structure doesn't match, scraper silently returns placeholder data (`currentCount: 0`). Acknowledged in a code comment. | Not fixed – requires live verification against the actual RecWell page |
| 12 | **P3** | Infrastructure | `pnpm run lint` fails if run at monorepo root before `pnpm install` is run for the `apps/mobile` Flutter project (not in pnpm workspace). The root `pnpm -r run lint` skips Flutter because Flutter is not a pnpm package, but there's no `flutter:lint` root script. | Not fixed – minor DX issue |
| 13 | **P3** | Backend / Security | `PROJECT_ID` is hardcoded as `"scab-purdue"` in `gemini.ts`. This is fine for the emulator and matches the project in `firebase_options.dart`, but in a team setting it should come from an environment variable or Firebase config. | Not fixed – acceptable for a single-project app |

---

## Build Results

| Command | Result |
|---------|--------|
| `pnpm run build` | ✅ Clean (shared + functions TypeScript compile without errors) |
| `pnpm run test` | ✅ 33 tests pass (15 shared schemas + 9 plan generator + 9 ICS parser) |
| `pnpm run lint` | ✅ Clean after fix (functions + shared) |
| `flutter analyze` | ✅ Clean after fixes ("No issues found") |
| `flutter test` | ✅ 13 tests pass |
| `flutter build apk --debug` | ✅ Build succeeded |
