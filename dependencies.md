# Dependencies

**Tags:** `#dependencies` `#packages` `#versions` `#external`

## Mobile App (`apps/mobile/pubspec.yaml`)

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | UI framework |
| `firebase_core` | ^3.8.0 | Firebase initialization |
| `firebase_auth` | ^5.3.0 | Authentication (Google Sign-In) |
| `cloud_firestore` | ^5.5.0 | Realtime database access |
| `cloud_functions` | ^5.1.0 | Cloud Functions client (unused currently — API via Dio instead) |
| `google_sign_in` | ^6.2.0 | Google OAuth flow |
| `flutter_riverpod` | ^2.6.0 | State management |
| `riverpod_annotation` | ^2.6.0 | Codegen annotations for providers |
| `go_router` | ^14.6.0 | Declarative routing |
| `dio` | ^5.7.0 | HTTP client for API calls |
| `intl` | ^0.19.0 | Date formatting |
| `uuid` | ^4.5.0 | UUID generation for schedule blocks |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `freezed_annotation` | ^2.4.0 | Immutable model annotations |
| `shared_preferences` | ^2.5.5 | Local key-value storage |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Widget/unit testing |
| `flutter_lints` | ^5.0.0 | Lint rules |
| `build_runner` | ^2.4.0 | Code generation runner |
| `json_serializable` | ^6.8.0 | JSON serialization codegen |
| `freezed` | ^2.5.0 | Immutable model codegen |
| `riverpod_generator` | ^2.6.0 | Provider codegen |

---

## Cloud Functions (`functions/package.json`)

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@google-cloud/vertexai` | ^1.9.0 | Vertex AI SDK for Gemini calls |
| `@ppt/shared` | workspace:* | Shared Zod schemas |
| `axios` | ^1.7.0 | HTTP client (facility scraper, ICS fetch) |
| `cheerio` | ^1.0.0 | HTML parsing for facility scraping |
| `cors` | ^2.8.5 | CORS middleware |
| `express` | ^4.21.0 | HTTP framework |
| `firebase-admin` | ^12.7.0 | Firebase Admin SDK (Firestore, Auth verification) |
| `firebase-functions` | ^6.1.0 | Cloud Functions v2 framework |
| `node-ical` | ^0.26.0 | ICS calendar file parsing |
| `zod` | ^3.23.0 | Schema validation |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@types/cors` | ^2.8.17 | TypeScript types |
| `@types/express` | ^4.17.21 | TypeScript types |
| `@types/node` | ^20.11.0 | TypeScript types |
| `@typescript-eslint/*` | ^8.0.0 | ESLint for TypeScript |
| `eslint` | ^9.0.0 | Linting |
| `firebase-functions-test` | ^3.3.0 | Functions test utilities |
| `prettier` | ^3.2.0 | Code formatting |
| `typescript` | ^5.5.0 | TypeScript compiler |
| `vitest` | ^2.0.0 | Test runner |

---

## Shared Package (`packages/shared/package.json`)

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `zod` | ^3.23.0 | Schema definition and validation |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@types/node` | ^20.11.0 | TypeScript types |
| `eslint` | ^9.0.0 | Linting |
| `prettier` | ^3.2.0 | Code formatting |
| `typescript` | ^5.5.0 | TypeScript compiler |
| `vitest` | ^2.0.0 | Test runner |

---

## External Services

| Service | Usage | Configuration |
|---------|-------|---------------|
| Firebase Auth | User authentication (Google provider) | `firebase.json`, app config |
| Cloud Firestore | Document database | Security rules in `firestore.rules` |
| Cloud Functions | API hosting | Single `onRequest` function |
| Vertex AI (Gemini 2.0 Flash) | AI chat + plan generation (future) | Project `scab-purdue`, region `us-central1` |
| Purdue RecWell website | Facility usage scraping | URL hardcoded in `facility-scraper.ts` |
| GitHub Actions | CI/CD | `.github/workflows/` |

---

## Dependency Graph

```mermaid
graph TB
    subgraph App["Flutter App"]
        Riverpod
        GoRouter
        Dio
        FirebaseSDK[Firebase SDKs]
        Freezed
    end

    subgraph Functions["Cloud Functions"]
        Express
        VertexAI[@google-cloud/vertexai]
        Cheerio[cheerio]
        NodeIcal[node-ical]
        Axios[axios]
        FirebaseAdmin[firebase-admin]
    end

    subgraph Shared["@ppt/shared"]
        Zod
    end

    Functions -->|imports| Shared
    App -.->|mirrors schemas| Shared
    Express --> FirebaseAdmin
    VertexAI --> FirebaseAdmin
```

---

## Version Constraints

| Tool | Required Version |
|------|-----------------|
| Node.js | ≥20 |
| pnpm | ≥9 |
| Flutter | ≥3.24.0 |
| Dart SDK | ≥3.5.0, <4.0.0 |

---

## Cross-References

- How dependencies are used in components → [components.md](components.md)
- Architecture showing service integrations → [architecture.md](architecture.md)
