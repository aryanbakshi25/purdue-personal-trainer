# Local Development Setup

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter | 3.24+ (stable) | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Node.js | 20 LTS | [nodejs.org](https://nodejs.org) |
| pnpm | 9+ | `npm install -g pnpm` |
| Firebase CLI | latest | `npm install -g firebase-tools` |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` |
| Java | 11+ | Required for Firebase emulators |

## 1. Clone and Install

```bash
git clone <repo-url> purdue-personal-trainer
cd purdue-personal-trainer

# Install Node.js dependencies (functions + shared)
pnpm install

# Build the shared package (functions depend on it)
pnpm --filter @ppt/shared run build

# Install Flutter dependencies
cd apps/mobile
flutter pub get
cd ../..
```

## 2. Firebase Configuration

### FlutterFire Setup

The app uses FlutterFire for Firebase configuration. You need to generate
`firebase_options.dart` for your local environment:

```bash
cd apps/mobile
flutterfire configure --project=scab-purdue
```

This creates `lib/firebase_options.dart`. Then uncomment the import and
options line in `lib/main.dart`:

```dart
import 'firebase_options.dart';

// In main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Gemini / Vertex AI Setup

The Gemini API is called server-side only (Cloud Functions). In production,
the Cloud Functions service account has automatic access to Vertex AI.

For local development with emulators:

```bash
# Option A: Use Application Default Credentials
gcloud auth application-default login

# Option B: Use a service account key (store securely, never commit)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### Secret Manager (Alternative to Vertex AI)

If using the Gemini REST API with an API key instead of Vertex AI:

```bash
# Store the key
firebase functions:secrets:set GEMINI_API_KEY

# Access in functions via defineSecret() – see functions/src/services/gemini.ts
```

## 3. Run Firebase Emulators

```bash
# From repo root – starts Auth, Firestore, and Functions emulators
pnpm emulators

# Or start fresh (no cached data)
pnpm emulators:fresh
```

The emulator UI will be available at http://localhost:4000.

| Service | Port |
|---------|------|
| Auth | 9099 |
| Firestore | 8080 |
| Functions | 5001 |
| Emulator UI | 4000 |

## 4. Run the Flutter App

```bash
# In a separate terminal
cd apps/mobile
flutter run
```

The app is configured to point to the emulator Functions URL by default
(`http://10.0.2.2:5001/scab-purdue/us-central1/api` for Android emulator).

For iOS Simulator or Chrome, override the API base URL:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5001/scab-purdue/us-central1/api
```

## 5. Seed Sample Data (Optional)

Open the Firestore emulator UI at http://localhost:4000/firestore and
create a sample user document:

**Collection:** `users` → **Document:** `<your-uid>`

```json
{
  "uid": "<your-uid>",
  "displayName": "Test User",
  "email": "test@purdue.edu",
  "fitnessLevel": "intermediate",
  "goals": ["Build muscle", "Improve cardio"],
  "preferredFacilities": ["CoRec"],
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

**Sub-collection:** `users/<uid>/scheduleBlocks`

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "title": "CS 252 Lecture",
  "dayOfWeek": "wednesday",
  "startTime": "09:30",
  "endTime": "10:20",
  "location": "LWSN B134",
  "category": "class",
  "isRecurring": true
}
```

## 6. Run Tests

```bash
# All Node.js tests (shared + functions)
pnpm test

# Flutter tests
cd apps/mobile && flutter test

# Or from root
pnpm flutter:test
```

## 7. Build Functions

```bash
pnpm --filter @ppt/functions run build
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `firebase_options.dart` not found | Run `flutterfire configure --project=scab-purdue` |
| Emulator connection refused | Check ports aren't in use; try `lsof -i :8080` |
| Android emulator can't reach localhost | Use `10.0.2.2` instead of `127.0.0.1` |
| iOS simulator can't reach localhost | Use `127.0.0.1` directly |
| Functions build fails | Run `pnpm --filter @ppt/shared run build` first |
