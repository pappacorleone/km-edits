#!/bin/bash
# WorkAdventure VM startup script for GCP e2-small
# This runs as root on first boot

set -euo pipefail
exec > /var/log/workadventure-setup.log 2>&1

echo "=== WorkAdventure Setup Starting ==="

# Add 2GB swap (e2-small only has 2GB RAM)
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "Swap enabled"
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    echo "Docker installed"
fi

# Create app directory
APP_DIR=/opt/workadventure
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Write docker-compose.yaml
cat > "$APP_DIR/docker-compose.yaml" << 'COMPOSE_EOF'
version: "3.6"
services:
  reverse-proxy:
    image: traefik:v3.6.1
    command:
      - --log.level=WARN
      - --providers.docker
      - --providers.docker.exposedbydefault=false
      - --entryPoints.web.address=:80
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
      - --entryPoints.websecure.address=:443
      - --certificatesresolvers.myresolver.acme.email=${ACME_EMAIL}
      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - letsencrypt:/letsencrypt
    restart: unless-stopped

  play:
    image: thecodingmachine/workadventure-play:${VERSION}
    environment:
      - DEBUG_MODE=false
      - JITSI_URL=meet.jit.si
      - JITSI_PRIVATE_MODE=false
      - ENABLE_MAP_EDITOR=true
      - MAP_EDITOR_ALLOW_ALL_USERS=true
      - PUSHER_URL=https://${DOMAIN}/
      - ICON_URL=/icon
      - STUN_SERVER=stun:stun.l.google.com:19302
      - MAX_PER_GROUP=4
      - MAX_USERNAME_LENGTH=10
      - DISABLE_ANONYMOUS=false
      - SECRET_KEY=${SECRET_KEY}
      - API_URL=back:50051
      - FRONT_URL=/
      - INTERNAL_MAP_STORAGE_URL=http://map-storage:3000
      - PUBLIC_MAP_STORAGE_URL=https://${DOMAIN}/map-storage
      - START_ROOM_URL=${START_ROOM_URL}
      - ENABLE_CHAT=true
      - ENABLE_CHAT_UPLOAD=true
      - ENABLE_CHAT_ONLINE_LIST=true
      - ENABLE_CHAT_DISCONNECTED_LIST=true
      - UPLOADER_URL=https://${DOMAIN}/uploader
      - ENABLE_OPENAPI_ENDPOINT=true
      - ROOM_API_PORT=50051
      - ROOM_API_SECRET_KEY=${ROOM_API_SECRET_KEY}
      - MAP_STORAGE_API_TOKEN=${SECRET_KEY}
      - YOUTUBE_ENABLED=true
      - GOOGLE_DRIVE_ENABLED=true
      - GOOGLE_DOCS_ENABLED=true
      - GOOGLE_SHEETS_ENABLED=true
      - GOOGLE_SLIDES_ENABLED=true
      - EXCALIDRAW_ENABLED=true
      - EXCALIDRAW_DOMAINS=excalidraw.com
      - TLDRAW_ENABLED=true
      - CARDS_ENABLED=true
    labels:
      traefik.enable: "true"
      # HTTP play (redirects to HTTPS via entrypoint config)
      traefik.http.routers.play.rule: "Host(`${DOMAIN}`) && PathPrefix(`/`)"
      traefik.http.routers.play.entryPoints: "web"
      traefik.http.routers.play.service: play
      traefik.http.routers.play.priority: "1"
      traefik.http.services.play.loadbalancer.server.port: "3000"
      # HTTPS play
      traefik.http.routers.play-ssl.rule: "Host(`${DOMAIN}`) && PathPrefix(`/`)"
      traefik.http.routers.play-ssl.entryPoints: "websecure"
      traefik.http.routers.play-ssl.tls: "true"
      traefik.http.routers.play-ssl.tls.certresolver: "myresolver"
      traefik.http.routers.play-ssl.service: "play"
      traefik.http.routers.play-ssl.priority: "1"
      # HTTP WebSocket
      traefik.http.routers.play-ws.rule: "Host(`${DOMAIN}`) && PathPrefix(`/ws/`)"
      traefik.http.routers.play-ws.entryPoints: "web"
      traefik.http.routers.play-ws.service: play-ws
      traefik.http.routers.play-ws.priority: "10"
      traefik.http.services.play-ws.loadbalancer.server.port: "3001"
      # HTTPS WebSocket
      traefik.http.routers.play-ws-ssl.rule: "Host(`${DOMAIN}`) && PathPrefix(`/ws/`)"
      traefik.http.routers.play-ws-ssl.entryPoints: "websecure"
      traefik.http.routers.play-ws-ssl.tls: "true"
      traefik.http.routers.play-ws-ssl.tls.certresolver: "myresolver"
      traefik.http.routers.play-ws-ssl.service: "play-ws"
      traefik.http.routers.play-ws-ssl.priority: "10"
    restart: unless-stopped

  back:
    image: thecodingmachine/workadventure-back:${VERSION}
    environment:
      - PLAY_URL=https://${DOMAIN}
      - ENABLE_MAP_EDITOR=true
      - SECRET_KEY=${SECRET_KEY}
      - JITSI_URL=meet.jit.si
      - MAX_PER_GROUP=4
      - STORE_VARIABLES_FOR_LOCAL_MAPS=true
      - REDIS_HOST=redis
      - MAP_STORAGE_URL=map-storage:50053
      - INTERNAL_MAP_STORAGE_URL=http://map-storage:3000
      - PUBLIC_MAP_STORAGE_URL=https://${DOMAIN}/map-storage
      - ENABLE_CHAT=true
      - ENABLE_CHAT_UPLOAD=true
    labels:
      traefik.enable: "true"
      traefik.http.middlewares.strip-api-prefix.stripprefix.prefixes: "/api"
      # HTTP back
      traefik.http.routers.back.rule: "Host(`${DOMAIN}`) && PathPrefix(`/api`)"
      traefik.http.routers.back.middlewares: "strip-api-prefix@docker"
      traefik.http.routers.back.entryPoints: "web"
      traefik.http.routers.back.priority: "10"
      traefik.http.services.back.loadbalancer.server.port: "8080"
      # HTTPS back
      traefik.http.routers.back-ssl.rule: "Host(`${DOMAIN}`) && PathPrefix(`/api`)"
      traefik.http.routers.back-ssl.middlewares: "strip-api-prefix@docker"
      traefik.http.routers.back-ssl.entryPoints: "websecure"
      traefik.http.routers.back-ssl.tls: "true"
      traefik.http.routers.back-ssl.tls.certresolver: "myresolver"
      traefik.http.routers.back-ssl.service: "back"
      traefik.http.routers.back-ssl.priority: "10"
    restart: unless-stopped

  icon:
    image: matthiasluedtke/iconserver:v3.21.0
    labels:
      traefik.enable: "true"
      traefik.http.middlewares.strip-icon-prefix.stripprefix.prefixes: "/icon"
      # HTTP icon
      traefik.http.routers.icon.middlewares: "strip-icon-prefix@docker"
      traefik.http.routers.icon.rule: "Host(`${DOMAIN}`) && PathPrefix(`/icon`)"
      traefik.http.routers.icon.entryPoints: "web"
      traefik.http.routers.icon.priority: "10"
      traefik.http.services.icon.loadbalancer.server.port: "8080"
      # HTTPS icon
      traefik.http.routers.icon-ssl.middlewares: "strip-icon-prefix@docker"
      traefik.http.routers.icon-ssl.rule: "Host(`${DOMAIN}`) && PathPrefix(`/icon`)"
      traefik.http.routers.icon-ssl.entryPoints: "websecure"
      traefik.http.routers.icon-ssl.tls: "true"
      traefik.http.routers.icon-ssl.tls.certresolver: "myresolver"
      traefik.http.routers.icon-ssl.service: "icon"
      traefik.http.routers.icon-ssl.priority: "10"
    restart: unless-stopped

  redis:
    image: redis:6
    volumes:
      - redisdata:/data
    restart: unless-stopped

  map-storage:
    image: thecodingmachine/workadventure-map-storage:${VERSION}
    environment:
      API_URL: back:50051
      ENABLE_BEARER_AUTHENTICATION: "false"
      ENABLE_BASIC_AUTHENTICATION: "true"
      ENABLE_DIGEST_AUTHENTICATION: "false"
      AUTHENTICATION_USER: "${MAP_STORAGE_AUTHENTICATION_USER}"
      AUTHENTICATION_PASSWORD: "${MAP_STORAGE_AUTHENTICATION_PASSWORD}"
      SECRET_KEY: "${SECRET_KEY}"
      PATH_PREFIX: "/map-storage"
      MAP_STORAGE_API_TOKEN: "${SECRET_KEY}"
      PUSHER_URL: "https://${DOMAIN}/"
    volumes:
      - map-storage-data:/maps
    labels:
      traefik.enable: "true"
      traefik.http.middlewares.strip-map-storage-prefix.stripprefix.prefixes: "/map-storage"
      # HTTP map-storage
      traefik.http.routers.map-storage.middlewares: "strip-map-storage-prefix@docker"
      traefik.http.routers.map-storage.rule: "Host(`${DOMAIN}`) && PathPrefix(`/map-storage`)"
      traefik.http.routers.map-storage.entryPoints: "web"
      traefik.http.routers.map-storage.priority: "10"
      traefik.http.services.map-storage.loadbalancer.server.port: "3000"
      # HTTPS map-storage
      traefik.http.routers.map-storage-ssl.middlewares: "strip-map-storage-prefix@docker"
      traefik.http.routers.map-storage-ssl.rule: "Host(`${DOMAIN}`) && PathPrefix(`/map-storage`)"
      traefik.http.routers.map-storage-ssl.entryPoints: "websecure"
      traefik.http.routers.map-storage-ssl.tls: "true"
      traefik.http.routers.map-storage-ssl.tls.certresolver: "myresolver"
      traefik.http.routers.map-storage-ssl.service: "map-storage"
      traefik.http.routers.map-storage-ssl.priority: "10"
    restart: unless-stopped

volumes:
  redisdata:
  map-storage-data:
  letsencrypt:
COMPOSE_EOF

# Generate secrets
SECRET_KEY=$(openssl rand -hex 32)
ROOM_API_SECRET=$(openssl rand -hex 32)
MAP_STORAGE_PASS=$(openssl rand -hex 16)

# Get external IP
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Write .env
cat > "$APP_DIR/.env" << ENV_EOF
VERSION=master
DOMAIN=laplaya.chat
ACME_EMAIL=kmondlane@gmail.com
SECRET_KEY=${SECRET_KEY}
ROOM_API_SECRET_KEY=${ROOM_API_SECRET}
MAP_STORAGE_AUTHENTICATION_USER=admin
MAP_STORAGE_AUTHENTICATION_PASSWORD=${MAP_STORAGE_PASS}
START_ROOM_URL=/_/global/workadventure.github.io/map-starter-kit/office.tmj
ENV_EOF

echo "=== Configuration ==="
echo "External IP: ${EXTERNAL_IP}"
echo "Map Storage User: admin"
echo "Map Storage Password: ${MAP_STORAGE_PASS}"
echo "=== Starting WorkAdventure ==="

# Pull and start
cd "$APP_DIR"
docker compose pull
docker compose up -d

echo "=== WorkAdventure is starting at https://laplaya.chat ==="
echo "External IP: ${EXTERNAL_IP} (ensure DNS A record for laplaya.chat points here)"
echo "Setup complete at $(date)"
