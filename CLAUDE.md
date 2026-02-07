# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WorkAdventure is a platform for creating customizable collaborative virtual worlds (metaverse). It's a TypeScript/JavaScript monorepo with 8 main services using Phaser.js game engine, Svelte, and Docker.

## Architecture

### Main Services
- **`play/`** - Frontend (Svelte + Phaser.js) + Pusher WebSocket server
  - `play/src/front` - Frontend code (Vite build)
  - `play/src/pusher` - Server-side WebSocket relay to back
- **`back/`** - Backend API server (Express + gRPC)
- **`messages/`** - Protocol Buffer definitions (**must build first**)
- **`map-storage/`** - Map storage service (disk or S3)
- **`tests/`** - End-to-end Playwright tests

### Shared Libraries (`libs/`)
- `map-editor/` - Map editing types
- `shared-utils/` - Common utilities
- `math-utils/` - Math operations
- `store-utils/` - Svelte state utilities
- `messages/` - Generated TypeScript from Protocol Buffers

### Communication
- Frontend ↔ Pusher: WebSocket
- Pusher ↔ Backend: gRPC
- Protocol Buffers define all inter-service contracts

## Build Commands

### Development Environment (Recommended)
```bash
cp .env.template .env
docker-compose up
```
Access: http://play.workadventure.localhost/ (Test user: User1 / pwd)

### Manual Build
**Critical**: Messages must be built first - they generate TypeScript from .proto files.

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
```

### End-to-End Tests (Playwright)
```bash
cd tests
npm install && npx playwright install --with-deps
npm run test-headed-chrome -- tests/[test-file.ts]
```

## Linting & Formatting

All services use standardized commands:
```bash
npm run lint          # Check only
npm run lint-fix      # Check and auto-fix
npm run pretty        # Prettier format
npm run pretty-check  # Check formatting
npm run svelte-check  # Svelte type checking (play only)
```

Pre-commit hooks run automatically after `npm install` at root.

## I18n (Internationalization)

Uses typesafe-i18n. Translation files: `play/src/i18n/[language]/[module].ts`

```bash
cd play
npm run typesafe-i18n     # Generate i18n files (required before build)
npm run i18n:diff         # Summary of missing translations
npm run i18n:diff -- fr-FR  # Detailed diff for specific locale
```

## Key Entry Points
- `play/src/server.ts` - Frontend + Pusher server
- `back/src/server.ts` - Backend API server
- `map-storage/src/server.ts` - Map storage service
- `messages/protos/*.proto` - Protocol Buffer definitions

## Common Issues

| Issue | Solution |
|-------|----------|
| "Cannot find module 'ts-proto-generated'" | Build messages first: `cd messages && npm run ts-proto` |
| "JavaScript heap out of memory" | `export NODE_OPTIONS=--max-old-space-size=16384` |
| Port conflicts | `docker-compose down` or kill processes on ports 3000, 3001, 8080 |
| GRPC issues | Use Docker dev environment (handles grpc-tools installation) |

## Windows Note

Before cloning, set: `git config --global core.autocrlf false`

## Hosts File (if needed)

Add to `/etc/hosts`:
```
127.0.0.1 oidc.workadventure.localhost redis.workadventure.localhost play.workadventure.localhost traefik.workadventure.localhost matrix.workadventure.localhost extra.workadventure.localhost icon.workadventure.localhost map-storage.workadventure.localhost uploader.workadventure.localhost maps.workadventure.localhost api.workadventure.localhost front.workadventure.localhost
```
