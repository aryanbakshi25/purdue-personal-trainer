# Purdue Personal Trainer

AI-powered fitness planning for Purdue students. A Flutter mobile app backed by Firebase and Google Cloud with a Gemini-powered assistant and schedule-aware workout planning.

## Quick Start

```bash
# Prerequisites: Flutter 3.24+, Node 20+, pnpm 9+, Firebase CLI

# Install dependencies
pnpm install
cd apps/mobile && flutter pub get && cd ../..

# Build shared package
pnpm --filter @ppt/shared run build

# Start Firebase emulators
pnpm emulators

# In another terminal, run the app
cd apps/mobile && flutter run
```

See [docs/SETUP.md](docs/SETUP.md) for detailed instructions.

## Repository Structure

```
/apps/mobile        Flutter app (Android + iOS)
/functions          Firebase Cloud Functions (Node.js 20, TypeScript)
/packages/shared    Shared schemas (Zod) used by functions and app
/docs               Setup, architecture, contributing guides
```

## Documentation

- [Setup Guide](docs/SETUP.md) – local development environment
- [Architecture](docs/ARCHITECTURE.md) – system design and data flow
- [Contributing](docs/CONTRIBUTING.md) – branching, PRs, code style

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter, Dart, Riverpod, GoRouter, Material 3 |
| Backend | Firebase Cloud Functions, Express, TypeScript |
| AI | Gemini via Vertex AI (server-side only) |
| Database | Cloud Firestore |
| Auth | Firebase Auth (Google Sign-In) |
| CI | GitHub Actions |
