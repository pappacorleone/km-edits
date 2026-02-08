#!/bin/bash

BACKGROUND=false
if [ "$1" = "--background" ]; then
    BACKGROUND=true
fi

# Navigate to workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "============================================="
echo "  Starting WorkAdventure Development"
echo "============================================="

# Ensure infrastructure is running
if docker info >/dev/null 2>&1; then
    if ! docker compose -f .devcontainer/docker-compose.infra.yaml ps --status running | grep -q redis; then
        echo "Starting infrastructure services..."
        docker compose -f .devcontainer/docker-compose.infra.yaml up -d
        sleep 3
    else
        echo "Infrastructure services already running."
    fi
else
    echo "Warning: Docker not available. Redis and other infra won't be available."
fi

# Export environment variables for local development
export REDIS_HOST=localhost
export REDIS_PORT=6379
export NODE_ENV=development
export DEBUG_MODE=true
export DEBUG="socket,space"
export DEBUG_COLORS=true
export DEBUG_ERROR_MESSAGES=true

# API/gRPC settings
export API_URL=localhost:50051
export MAP_STORAGE_URL=localhost:50053

# URLs
export PLAY_URL=http://play.workadventure.localhost
export FRONT_URL=http://play.workadventure.localhost
export VITE_URL=http://front.workadventure.localhost
export PUSHER_URL=http://play.workadventure.localhost
export PUBLIC_MAP_STORAGE_URL=http://map-storage.workadventure.localhost
export INTERNAL_MAP_STORAGE_URL=http://localhost:3000
export ALLOWED_CORS_ORIGIN=http://play.workadventure.localhost
export UPLOADER_URL=http://uploader.workadventure.localhost
export ICON_URL=http://icon.workadventure.localhost

# Auth/Security
export SECRET_KEY=yourSecretKey2020
export MAP_STORAGE_API_TOKEN=FFVSGBSGBSGFB23SFGBSFG4BS
export OPENID_CLIENT_ID=authorization-code-client-id
export OPENID_CLIENT_SECRET=authorization-code-client-secret
export OPENID_CLIENT_ISSUER=http://oidc.workadventure.localhost
export OPENID_SCOPE="profile openid email tags-scope"

# Features
export ENABLE_MAP_EDITOR=true
export ENABLE_CHAT=true
export ENABLE_CHAT_UPLOAD=true
export STORE_VARIABLES_FOR_LOCAL_MAPS=true
export START_ROOM_URL=/_/global/maps.workadventure.localhost/starter/map.json

# Kill any existing processes on our ports
echo ""
echo "Cleaning up any existing processes..."
pkill -f "tsx.*back/src" 2>/dev/null || true
pkill -f "tsx.*play/src" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 1

# Create log directory
mkdir -p /tmp/workadventure-logs

# Start back service
echo ""
echo "Starting back service..."
cd back
npm run dev > /tmp/workadventure-logs/back.log 2>&1 &
BACK_PID=$!
cd ..

echo "Waiting for back service to initialize (gRPC on port 50051)..."
for i in {1..30}; do
    if nc -z localhost 50051 2>/dev/null; then
        echo "Back service is ready!"
        break
    fi
    sleep 1
done

# Start play service (includes Pusher + Vite frontend)
echo ""
echo "Starting play service..."
cd play
npm run dev > /tmp/workadventure-logs/play.log 2>&1 &
PLAY_PID=$!
cd ..

echo "Waiting for play service to initialize..."
sleep 5

echo ""
echo "============================================="
echo "  Services Started!"
echo "============================================="
echo ""
echo "Process IDs:"
echo "  Back: $BACK_PID"
echo "  Play: $PLAY_PID"
echo ""
echo "View Logs:"
echo "  tail -f /tmp/workadventure-logs/back.log"
echo "  tail -f /tmp/workadventure-logs/play.log"
echo ""
echo "Access URLs:"
echo "  http://play.workadventure.localhost  - Main app (via Traefik)"
echo "  http://localhost:8080                - Vite dev server (direct)"
echo "  http://localhost:3000                - Pusher HTTP (direct)"
echo ""
echo "Test Login: User1 / pwd"
echo ""
echo "Stop services:"
echo "  pkill -f tsx; pkill -f vite"
echo ""

# Save PIDs for later
echo "$BACK_PID" > /tmp/workadventure-logs/back.pid
echo "$PLAY_PID" > /tmp/workadventure-logs/play.pid

# Keep script running and show combined logs (unless running in background)
if [ "$BACKGROUND" = false ]; then
    echo "Streaming logs (Ctrl+C to stop viewing, services keep running)..."
    echo ""
    tail -f /tmp/workadventure-logs/back.log /tmp/workadventure-logs/play.log 2>/dev/null || wait
fi
