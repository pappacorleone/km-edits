# DevPod / DevContainer Setup for WorkAdventure

This configuration provides a fast development environment optimized for DevPod. It avoids Docker volume mount performance issues on Windows by running Node.js services directly in the container.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  DevPod Container (Node.js 22)                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Your Code + Node Services                          │    │
│  │  - play (Pusher + Vite frontend)                    │    │
│  │  - back (gRPC API server)                           │    │
│  │  - map-storage (optional)                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Docker-in-Docker (Infrastructure)                  │    │
│  │  - Traefik (reverse proxy, port 80)                 │    │
│  │  - Redis (session/cache, port 6379)                 │    │
│  │  - Maps (static map server)                         │    │
│  │  - OIDC Mock (authentication testing)               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start with DevPod

### Option 1: DevPod CLI (Recommended)

```bash
# Install DevPod if you haven't
# https://devpod.sh/docs/getting-started/install

# Start the dev environment
devpod up https://github.com/YOUR_ORG/workadventure
# Or from local path:
devpod up /path/to/workadventure
```

### Option 2: VS Code Dev Containers

1. Install the "Dev Containers" extension in VS Code
2. Open this folder in VS Code
3. Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
4. Wait for the container to build and setup to complete

## After Container Starts

The `postCreateCommand` automatically:
1. Adds `/etc/hosts` entries for `*.workadventure.localhost`
2. Starts infrastructure (Redis, Traefik, Maps, OIDC)
3. Builds Protocol Buffer messages
4. Installs all npm dependencies

Then start the services:

```bash
# Start all services with one command
.devcontainer/start-dev.sh

# Or start manually in separate terminals:
cd back && npm run dev      # Terminal 1 (gRPC API)
cd play && npm run dev      # Terminal 2 (Pusher + Frontend)
```

## Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| **Main App** | http://play.workadventure.localhost | Via Traefik |
| Vite Dev Server | http://localhost:8080 | Direct access |
| Pusher HTTP | http://localhost:3000 | Direct access |
| Pusher WebSocket | ws://localhost:3001 | Direct access |
| Maps Server | http://maps.workadventure.localhost | Static maps |
| OIDC Mock | http://oidc.workadventure.localhost | Auth testing |

**Test Credentials:** `User1` / `pwd`

## View Logs

```bash
# Combined logs (if using start-dev.sh)
tail -f /tmp/workadventure-logs/back.log
tail -f /tmp/workadventure-logs/play.log

# Infrastructure logs
docker compose -f .devcontainer/docker-compose.infra.yaml logs -f
```

## Stop Services

```bash
# Stop Node services
pkill -f tsx
pkill -f vite

# Stop infrastructure
docker compose -f .devcontainer/docker-compose.infra.yaml down
```

## Common Issues

### "Module not found" or TypeScript errors
The Protocol Buffer messages need to be built first:
```bash
cd messages && npm run ts-proto && cd ..
```

### Redis connection errors
Ensure infrastructure is running:
```bash
docker compose -f .devcontainer/docker-compose.infra.yaml up -d
```

### "Cannot resolve host" errors
Check that hosts entries exist:
```bash
cat /etc/hosts | grep workadventure
# Should show: 127.0.0.1 play.workadventure.localhost ...
```

### Port conflicts
```bash
pkill -f tsx
pkill -f vite
lsof -i :3000 -i :8080 -i :50051  # Check what's using ports
```

### Out of memory
The container has `NODE_OPTIONS=--max-old-space-size=8192` set. If you still hit issues:
```bash
export NODE_OPTIONS="--max-old-space-size=16384"
```

## Running Tests

```bash
# Unit tests
cd play && npm test -- --watch=false
cd back && npm test -- --watch=false

# E2E tests require the full docker-compose setup
# Use the main docker-compose.yaml for E2E testing
```

## Tips

- **Hot Reload:** Both Vite (frontend) and tsx (backend) support hot reload
- **Debugging:** Ports 9231-9234 are exposed for Node.js debugging
- **Full Setup:** For E2E tests or production-like env, use the main `docker-compose.yaml`
