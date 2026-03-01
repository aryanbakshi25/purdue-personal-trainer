# Developer Setup Guide

Step-by-step instructions to get the SCAB Purdue app running on your machine. No prior Flutter experience required.

## Prerequisites

Install the following tools **before** cloning the repo.

| Tool | Version | macOS | Windows | Linux |
|------|---------|-------|---------|-------|
| **Flutter** | 3.24+ (stable) | `brew install --cask flutter` | [Download installer](https://docs.flutter.dev/get-started/install/windows/mobile) | [Install via snap](https://docs.flutter.dev/get-started/install/linux/android) |
| **Xcode** (iOS builds) | 15+ | App Store | N/A | N/A |
| **Android Studio** (Android builds) | latest | [Download](https://developer.android.com/studio) | [Download](https://developer.android.com/studio) | [Download](https://developer.android.com/studio) |
| **Node.js** | 20 LTS | `brew install node@20` | [Download](https://nodejs.org) | `nvm install 20` |
| **pnpm** | 9+ | `npm install -g pnpm` | `npm install -g pnpm` | `npm install -g pnpm` |
| **Firebase CLI** | latest | `npm install -g firebase-tools` | `npm install -g firebase-tools` | `npm install -g firebase-tools` |
| **Java** | 17+ | `brew install openjdk@17` | [Download Temurin](https://adoptium.net/) | `sudo apt install openjdk-17-jdk` |
| **Git** | latest | pre-installed | [Download](https://git-scm.com/) | `sudo apt install git` |

### Platform-Specific Notes

#### macOS
After installing Java via Homebrew, add it to your PATH:
```bash
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

After installing Xcode, accept the license and install command-line tools:
```bash
sudo xcodebuild -license accept
sudo xcode-select --install
```

Set up the iOS simulator:
```bash
open -a Simulator
```

#### Windows
- Use **PowerShell** (not CMD) for all commands.
- After installing Flutter, run `flutter doctor` and follow any prompts to accept Android licenses:
  ```powershell
  flutter doctor --android-licenses
  ```
- Java: after installing, ensure `JAVA_HOME` is set in your environment variables.
- You **cannot build for iOS** on Windows. Use the Android emulator instead.

#### Linux
- You **cannot build for iOS** on Linux. Use the Android emulator instead.
- Install additional Linux dependencies for Flutter:
  ```bash
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```

## Step 1: Clone the Repo

```bash
git clone https://github.com/aryanbakshi25/purdue-personal-trainer.git
cd purdue-personal-trainer
```

## Step 2: Install Dependencies

```bash
# Install Node.js dependencies (functions + shared package)
pnpm install

# Build the shared schema package (functions depend on it)
pnpm --filter @ppt/shared run build

# Install Flutter dependencies
cd apps/mobile
flutter pub get
cd ../..
```

## Step 3: Verify Your Setup

```bash
flutter doctor
```

You should see checkmarks for Flutter, your target platform (iOS/Android), and your IDE. Fix any issues `flutter doctor` reports before continuing.

## Step 4: Start Firebase Emulators

```bash
# From the repo root
pnpm emulators
```

You should see:
```
✔  All emulators ready! It is now safe to connect your app.
```

Leave this terminal running. The emulator UI is at **http://localhost:4000**.

| Service | Port |
|---------|------|
| Auth | 9099 |
| Firestore | 8080 |
| Functions | 5001 |
| Emulator UI | 4000 |

If ports are already in use, kill stale processes:
```bash
# macOS/Linux
lsof -ti :4000 -ti :9099 -ti :8080 | xargs kill

# Windows (PowerShell)
Get-NetTCPConnection -LocalPort 4000,9099,8080 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

## Step 5: Run the App

Open a **new terminal** (keep the emulators running in the first one).

### iOS Simulator (macOS only)
```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5001/scab-purdue/us-central1/api
```

### Android Emulator (all platforms)
1. Open Android Studio → Virtual Device Manager → Create a Pixel device with API 34+.
2. Start the emulator.
3. Run:
```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001/scab-purdue/us-central1/api
```

> **Why different URLs?** The iOS simulator shares your Mac's network, so `127.0.0.1` works directly. The Android emulator runs in a VM where `10.0.2.2` maps to your host machine's localhost.

### Chrome (any platform, for quick UI testing)
```bash
cd apps/mobile
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:5001/scab-purdue/us-central1/api
```

## Step 6: Sign In

On the login screen, tap **"Sign in with Emulator"** (the outlined button at the bottom). This creates a test account (`test@purdue.edu`) against the local Auth emulator — no Google account needed.

You can verify it worked by opening http://localhost:4000/auth in your browser.

> **Note:** The "Sign in with Google" button requires a physical iOS device and won't work on the simulator. Use the emulator sign-in for all local development.

## Step 7: Explore the Emulator UI

Open **http://localhost:4000** in your browser:

- **Auth tab** — see all signed-in users, create/delete test accounts
- **Firestore tab** — browse/edit all data (users, schedules, plans)
- **Functions tab** — see Cloud Functions logs in real-time

## Running Tests

```bash
# Flutter tests
cd apps/mobile && flutter test

# Node.js tests (shared schemas + functions)
pnpm test

# Everything from root
pnpm test && pnpm flutter:test
```

## Branching Workflow

Before starting any work, create a feature branch off `dev`:

```bash
git checkout dev
git pull origin dev
git checkout -b feat/your-feature-name
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for PR guidelines and code style.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `flutter doctor` shows issues | Follow the specific instructions it gives you |
| `pnpm emulators` fails with "Java not found" | Install Java 17+ and add to PATH (see prerequisites) |
| `pnpm emulators` fails with "port taken" | Kill stale processes (see Step 4) |
| Android emulator can't connect to backend | Make sure you're using `10.0.2.2`, not `127.0.0.1` |
| iOS simulator can't connect to backend | Make sure you're using `127.0.0.1`, not `10.0.2.2` |
| `firebase_options.dart` errors | Run `flutter pub get` in `apps/mobile/` |
| Functions build fails | Run `pnpm --filter @ppt/shared run build` first |
| Hot reload doesn't pick up changes | Press `R` (capital) in terminal for full restart |
| Sign in with Google crashes on simulator | Expected — use "Sign in with Emulator" instead |
| `pod install` fails (iOS) | Run `cd ios && pod install --repo-update && cd ..` |

## Do I Need Firebase Console Access?

**No.** For local development, everything runs against the emulators on your machine. You do not need to be added to the Firebase project or Google Cloud Console.

The only time you'd need project access is for:
- Deploying Cloud Functions to production
- Managing Firebase Auth providers
- Viewing production Firestore data

If you need access for these tasks, ask the project lead to add your Google account at [console.firebase.google.com](https://console.firebase.google.com) → SCAB Purdue → Project Settings → Users and permissions.

## Recommended Learning Resources

If you're new to Flutter, work through these before starting your task:

1. **[Your First Flutter App](https://codelabs.developers.google.com/codelabs/flutter-codelab-first)** (Google Codelab, ~1 hour) — covers widgets, state, and navigation basics
2. **[Flutter in 100 Seconds](https://www.youtube.com/watch?v=lHhRhPV--G0)** (Fireship, 2 min) — quick conceptual overview
3. **[Riverpod Tutorial](https://riverpod.dev/docs/introduction/getting_started)** (official docs) — our state management solution
4. **[GoRouter Guide](https://pub.dev/documentation/go_router/latest/)** — our routing library

You do **not** need to master Flutter before starting. Each task is scoped to 1-2 files and you'll learn by doing.
