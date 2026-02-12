# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WorkAdventure is a platform for creating customizable collaborative virtual worlds (metaverse). It's a TypeScript monorepo using npm workspaces with services communicating via gRPC/Protocol Buffers and WebSockets. Runtime: Node.js 20–22. TypeScript 5.8.3 enforced globally via root `package.json` overrides.

## Architecture

### Main Services
- **`play/`** (workspace: `workadventure-play`) — Actually **two applications** in one package:
  - `play/src/front/` — Frontend (Svelte 4 + Phaser.js 3 game engine, built with Vite). Ports: 8080 (Vite dev), 3000 (HTTP), 3001 (WebSocket)
  - `play/src/pusher/` — Server-side WebSocket relay that forwards calls to the back service (Express, uses `tsconfig-pusher.json`)
  - `play/src/server.ts` — Entry point that starts both the Pusher server and Vite dev server
  - Also builds `iframe-api` — a separate Vite build target for embedding WorkAdventure in iframes
- **`back/`** (workspace: `workadventureback`) — Backend API server (Express 5 + gRPC). Manages rooms, users, maps, variables. Integrates LiveKit, BigBlueButton.
- **`messages/`** (workspace: `workadventure-messages`) — Protocol Buffer definitions (`protos/*.proto`). **Must build first** — uses `grpc_tools_node_protoc` + `protoc-gen-ts_proto` to generate TypeScript into `libs/messages/src/ts-proto-generated/` (generated files have `@ts-nocheck`).
- **`map-storage/`** — Map storage service (disk or S3). Has both a Node backend (`tsconfig-node.json`) and a Svelte frontend for the map editor UI (`tsconfig.json`), run concurrently in dev.
- **`tests/`** — End-to-end Playwright tests
- **`uploader/`** — File upload service (deprecated)

### Shared Libraries (`libs/`)
- `messages/` — Generated TypeScript from Protocol Buffers (consumed by all services)
- `map-editor/` — Map editing types and commands (Zod schemas). CI validates that `export-json-schema` output stays in sync.
- `shared-utils/` — Common utilities across services
- `math-utils/` — Mathematical operations
- `store-utils/` — Svelte state management utilities (has `svelte-check`)
- `eslint-config/` — Shared ESLint 9 flat config (all services import `generateConfig()`)
- `tailwind/` — Shared Tailwind theme and design system

### Communication Flow
```
Browser ←WebSocket→ Pusher (play) ←gRPC→ Back
                                    ↕
                              Map Storage
```
Protocol Buffers (`messages/protos/*.proto`) define all inter-service contracts.

## Build Commands

### Development Environment (Recommended)
```bash
cp .env.template .env
docker-compose up
```
Access: http://play.workadventure.localhost/ (Test user: User1 / pwd)

**Docker Compose overlays** for optional features:
```bash
docker-compose -f docker-compose.yaml -f docker-compose.livekit.yaml up    # LiveKit video
docker-compose -f docker-compose.yaml -f docker-compose.minio.yaml up      # S3 storage
docker-compose -f docker-compose.yaml -f docker-compose.no-oidc.yaml up    # Anonymous access
docker-compose -f docker-compose.yaml -f docker-compose.no-synapse.yaml up # Disable Matrix chat
```

### DevContainer Setup
The repo includes `.devcontainer/` config (node:20-bookworm with docker-in-docker). On first creation, `setup.sh` runs automatically (`postCreateCommand`) to configure hosts file, .env, Docker infrastructure, messages build, and npm install. On every container start, `start-dev.sh` runs automatically (`postStartCommand`) to launch infrastructure via `docker-compose.infra.yaml` (Redis, Traefik, Maps, OIDC) and start back and play natively. Logs go to `/tmp/workadventure-logs/`. You can also run `start-dev.sh` manually for interactive log streaming.

### Manual Build
**Critical**: Messages must be built first — they generate TypeScript from .proto files.

```bash
# 1. Build messages first (REQUIRED)
cd messages && npm install && npm run ts-proto

# 2. Build/check individual services
cd play && npm install && npm run typesafe-i18n && npm run build
cd back && npm install && npm run typecheck
cd map-storage && npm install && npm run typecheck
```

Memory issues: `export NODE_OPTIONS=--max-old-space-size=16384`

## Testing

### Unit Tests (Vitest)
```bash
cd play && npm test -- --watch=false
cd back && npm test -- --watch=false
cd map-storage && npm test -- --watch=false

# Run a single test file
cd play && npx vitest run src/path/to/test.test.ts
```

### End-to-End Tests (Playwright)
```bash
cd tests
npm install && npx playwright install --with-deps

# Run a single test with browser UI
npm run test-headed-chrome -- tests/[test-file.ts]

# Run all tests headless
npm run test

# Other modes
npm run test-prod-like        # Production-like environment
npm run test-single-domain-install  # Single domain setup
```

## Linting & Formatting

All services use standardized commands:
```bash
npm run lint          # ESLint check only
npm run lint-fix      # ESLint with auto-fix
npm run pretty        # Prettier format
npm run pretty-check  # Check formatting
npm run svelte-check  # Svelte type checking (play and map-storage)
npm run typecheck     # TypeScript type checking
```

Prettier config: 120 char print width, 4-space tabs, Svelte plugin enabled. Each service has its own `.prettierrc.json`.

Pre-commit hooks (Husky) run lint-staged (ESLint + Prettier) across all services, `i18n:check` for play, and `export-json-schema` for libs/map-editor. After first clone, run `npm install` at the root to install Husky hooks.

### Key ESLint Rules (enforced project-wide)
- `no-explicit-any`: **error** — avoid `any` types
- `consistent-type-imports`: **error** — use `import type` for type-only imports (auto-fixed)
- `rxjs/no-ignored-subscription`: **error**
- `svelte/require-each-key`: **error**
- `import/order`: **error** — imports must be ordered

## I18n (Internationalization)

Uses typesafe-i18n. Translation files: `play/src/i18n/[language]/[module].ts`

```bash
cd play
npm run typesafe-i18n     # Generate i18n files (required before build)
npm run i18n:diff         # Summary of missing translations across all locales
npm run i18n:diff -- fr-FR  # Detailed diff for specific locale
npm run i18n:check        # Validation (runs in pre-commit)
```

Any user-facing message added to the code should be translated in all supported languages.

## CI/CD Pipeline

### CI — Continuous Integration
GitHub Actions (`.github/workflows/continuous_integration.yml`) runs per-service jobs in parallel on Node.js 22. Each service job:
1. Installs protoc (arduino/setup-protoc@v3) and builds messages first
2. Runs typecheck, lint, tests, prettier-check
3. Play additionally runs: i18n:check, svelte-check, build, build-iframe-api
4. libs/map-editor validates that `export-json-schema` output matches committed files (git diff check)

### CD — Deploy to GCP VM
GitHub Actions (`.github/workflows/deploy-gcp.yml`) triggers on push to `master`:
1. Builds Docker images for play, back, map-storage in parallel on GitHub runners
2. Pushes to GHCR (`ghcr.io/pappacorleone/workadventure-{play,back,map-storage}:master`)
3. SSHes into GCP VM via service account, writes `docker-compose.override.yaml`, pulls and restarts

**GCP VM**: `workadventure` (e2-small, us-east1-b, project: sundaistack, IP: 35.185.4.222)
**GitHub Secret**: `GCP_SA_KEY` — service account key for `github-deployer@sundaistack.iam.gserviceaccount.com`
**Deployment scripts**: `contrib/gcp/deploy-e2-small.sh` (create VM), `contrib/gcp/vm-startup.sh` (bootstrap)

## Key Entry Points
- `play/src/server.ts` — Frontend + Pusher server
- `back/src/server.ts` — Backend API server
- `map-storage/src/server.ts` — Map storage service
- `messages/protos/*.proto` — Protocol Buffer definitions

## Common Issues

| Issue | Solution |
|-------|----------|
| "Cannot find module 'ts-proto-generated'" | Build messages first: `cd messages && npm run ts-proto` |
| "JavaScript heap out of memory" | `export NODE_OPTIONS=--max-old-space-size=16384` |
| Port conflicts | `docker-compose down` or kill processes on ports 3000, 3001, 8080 |
| GRPC/network issues | Use Docker dev environment (handles grpc-tools installation) |
| Containers exit 125/137 | Increase Docker memory to 6GB+ |

## Hosts File (if needed)

Add to `/etc/hosts`:
```
127.0.0.1 oidc.workadventure.localhost redis.workadventure.localhost play.workadventure.localhost traefik.workadventure.localhost matrix.workadventure.localhost extra.workadventure.localhost icon.workadventure.localhost map-storage.workadventure.localhost uploader.workadventure.localhost maps.workadventure.localhost api.workadventure.localhost front.workadventure.localhost
```
