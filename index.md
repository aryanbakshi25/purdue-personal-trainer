# Knowledge Base Index

> **For AI Assistants:** This file is the entry point to understanding this codebase. Read this first to determine which detailed documentation files to consult for specific questions.

## How to Use This Documentation

1. **Start here** — this index tells you what each file covers and when to read it
2. **Use the decision table below** to find the right file for your task
3. **Cross-reference** — files link to each other; follow references for deeper context
4. **The shared schemas** (`packages/shared/src/schemas.ts`) are the single source of truth for all data structures

## Quick Reference: Which File to Read

| If you need to understand... | Read |
|------------------------------|------|
| Overall system design, how components connect | [architecture.md](architecture.md) |
| What a specific module/package does | [components.md](components.md) |
| API endpoints, request/response formats | [interfaces.md](interfaces.md) |
| Firestore schema, Zod validators, data shapes | [data_models.md](data_models.md) |
| How features work end-to-end (auth, chat, plans) | [workflows.md](workflows.md) |
| What libraries are used and why | [dependencies.md](dependencies.md) |
| Raw analysis data and project metadata | [codebase_info.md](codebase_info.md) |

## File Summaries

### [codebase_info.md](codebase_info.md)
**Tags:** `#metadata` `#overview` `#stack` `#firebase-config`

Raw project metadata: package names, versions, technology choices, CI configuration, Firebase project details, and the Mermaid architecture diagram. Start here for quick facts.

### [architecture.md](architecture.md)
**Tags:** `#architecture` `#design-patterns` `#data-flow` `#decisions`

System architecture with Mermaid diagrams showing: client-server communication, the Express middleware pipeline, Riverpod provider hierarchy, and how data flows through authentication → API → services → Firestore. Covers key architectural decisions and their rationale.

### [components.md](components.md)
**Tags:** `#components` `#modules` `#responsibilities` `#directory-map`

Detailed breakdown of each package's internal modules: Flutter feature screens, providers, services; Cloud Functions routes, middleware, services; shared package exports. Describes what each component does and its dependencies.

### [interfaces.md](interfaces.md)
**Tags:** `#api` `#endpoints` `#contracts` `#auth` `#http`

Complete API reference: all 5 endpoints with method, path, auth requirements, request/response schemas, and error cases. Also covers the Dart ApiClient, Firebase Auth token flow, and Firestore realtime listeners.

### [data_models.md](data_models.md)
**Tags:** `#schemas` `#firestore` `#zod` `#dart-models` `#validation`

All data structures: Zod schemas in `@ppt/shared`, corresponding Dart model classes, Firestore document structure, and collection path constants. The authoritative reference for data shapes.

### [workflows.md](workflows.md)
**Tags:** `#workflows` `#sequences` `#user-flows` `#feature-flows`

End-to-end sequence diagrams for: Google Sign-In, onboarding, schedule CRUD, plan generation, AI chat, ICS import, and facility usage. Shows the complete path from user action through all system layers.

### [dependencies.md](dependencies.md)
**Tags:** `#dependencies` `#packages` `#versions` `#external`

All external dependencies organized by package, with version constraints and purpose. Covers Flutter pub dependencies, npm packages, Firebase services, and development tools.

## Project Identity

- **Name:** Purdue Personal Trainer
- **Type:** pnpm monorepo (Flutter + Firebase Cloud Functions + shared TypeScript)
- **Firebase Project:** `scab-purdue` in `us-central1`
- **Languages:** Dart, TypeScript
- **Key Patterns:** Riverpod state management, Express REST API, Zod validation, Firestore realtime
