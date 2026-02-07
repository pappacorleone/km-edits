#!/bin/bash
set -e

# Navigate to workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "============================================="
echo "  WorkAdventure DevPod Setup"
echo "============================================="
echo "Working directory: $(pwd)"
echo ""

# Add hosts entries for *.workadventure.localhost
echo "Setting up /etc/hosts entries..."
HOSTS_ENTRIES="127.0.0.1 play.workadventure.localhost front.workadventure.localhost maps.workadventure.localhost oidc.workadventure.localhost map-storage.workadventure.localhost api.workadventure.localhost redis.workadventure.localhost traefik.workadventure.localhost"

if ! grep -q "workadventure.localhost" /etc/hosts 2>/dev/null; then
    echo "Adding hosts entries (requires sudo)..."
    echo "$HOSTS_ENTRIES" | sudo tee -a /etc/hosts > /dev/null
    echo "Hosts entries added."
else
    echo "Hosts entries already exist."
fi

# Copy .env if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env from template..."
    cp .env.template .env
    echo ".env created."
else
    echo ".env already exists, keeping existing configuration."
fi

# Wait for Docker-in-Docker to be ready
echo ""
echo "Waiting for Docker daemon..."
for i in {1..30}; do
    if docker info >/dev/null 2>&1; then
        echo "Docker is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Warning: Docker not available. Infrastructure services won't start."
        echo "You may need to restart the container or check Docker-in-Docker setup."
    fi
    sleep 1
done

# Start infrastructure services
if docker info >/dev/null 2>&1; then
    echo ""
    echo "Starting infrastructure services (Redis, Traefik, Maps, OIDC)..."
    docker compose -f .devcontainer/docker-compose.infra.yaml pull --quiet || true
    docker compose -f .devcontainer/docker-compose.infra.yaml up -d

    # Wait for Redis
    echo "Waiting for Redis..."
    for i in {1..30}; do
        if docker compose -f .devcontainer/docker-compose.infra.yaml exec -T redis redis-cli ping 2>/dev/null | grep -q PONG; then
            echo "Redis is ready!"
            break
        fi
        sleep 1
    done
fi

# Install root dependencies
echo ""
echo "Installing root dependencies..."
npm install --prefer-offline || npm install

# Build messages first (Protocol Buffers - required by other services)
echo ""
echo "Building Protocol Buffer messages (this is required)..."
cd messages
npm install --prefer-offline || npm install
npm run ts-proto
cd ..

# Install dependencies for each service
echo ""
echo "Installing play service dependencies..."
cd play
npm install --prefer-offline || npm install
npm run typesafe-i18n || echo "Warning: typesafe-i18n failed, continuing..."
cd ..

echo ""
echo "Installing back service dependencies..."
cd back
npm install --prefer-offline || npm install
cd ..

echo ""
echo "Installing map-storage service dependencies..."
cd map-storage
npm install --prefer-offline || npm install
cd ..

# Make scripts executable
chmod +x .devcontainer/*.sh 2>/dev/null || true

echo ""
echo "============================================="
echo "  Setup Complete!"
echo "============================================="
echo ""
echo "To start all services, run:"
echo "  .devcontainer/start-dev.sh"
echo ""
echo "Or start services in separate terminals:"
echo "  cd back && npm run dev"
echo "  cd play && npm run dev"
echo "  cd map-storage && npm run start:dev  # optional"
echo ""
echo "Access URLs (after starting services):"
echo "  http://play.workadventure.localhost  - Main app (via Traefik)"
echo "  http://localhost:8080                - Vite dev server"
echo "  http://localhost:3000                - Pusher HTTP"
echo ""
echo "Test user: User1 / pwd"
echo ""
