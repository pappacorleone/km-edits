#!/bin/bash
# Deploy WorkAdventure to Google Cloud Platform (GCP) using gcloud CLI
#
# Prerequisites:
#   - gcloud CLI installed and authenticated (gcloud auth login)
#   - kubectl installed
#   - helm 3.x installed
#
# Usage:
#   ./deploy-gcp.sh [options]
#
# Options:
#   -p, --project     GCP project ID (required)
#   -r, --region     GCP region (default: us-central1)
#   -n, --name       Cluster name (default: workadventure)
#   -d, --domain     Domain name for WorkAdventure (required)
#   -m, --machine-type  GKE node machine type (default: e2-standard-4)
#   -v, --version    WorkAdventure image version (default: master)
#   -h, --help       Show this help

set -e

# Defaults
PROJECT=""
REGION="us-central1"
CLUSTER_NAME="workadventure"
DOMAIN=""
MACHINE_TYPE="e2-standard-4"
VERSION="master"
NAMESPACE="workadventure"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--project)
      PROJECT="$2"
      shift 2
      ;;
    -r|--region)
      REGION="$2"
      shift 2
      ;;
    -n|--name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    -d|--domain)
      DOMAIN="$2"
      shift 2
      ;;
    -m|--machine-type)
      MACHINE_TYPE="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -h|--help)
      head -26 "$0" | tail -20
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required args
if [[ -z "$PROJECT" ]]; then
  echo "Error: --project is required"
  echo "Run with --help for usage"
  exit 1
fi

if [[ -z "$DOMAIN" ]]; then
  echo "Error: --domain is required (e.g., play.example.com)"
  echo "Run with --help for usage"
  exit 1
fi

echo "=== WorkAdventure GCP Deployment ==="
echo "Project:  $PROJECT"
echo "Region:   $REGION"
echo "Cluster:  $CLUSTER_NAME"
echo "Domain:   $DOMAIN"
echo "Machine:  $MACHINE_TYPE"
echo "Version:  $VERSION"
echo ""

# Generate secrets once for consistency
MAP_STORAGE_PASSWORD=$(openssl rand -base64 24)
ROOM_API_SECRET=$(openssl rand -base64 24)
SECRET_KEY=$(openssl rand -base64 32)

# Set project
echo "Setting GCP project..."
gcloud config set project "$PROJECT"

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com 2>/dev/null || true

# Create GKE cluster (or use existing)
echo "Creating GKE cluster (this may take 5-10 minutes)..."
if gcloud container clusters describe "$CLUSTER_NAME" --region="$REGION" &>/dev/null; then
  echo "Cluster '$CLUSTER_NAME' already exists."
else
  gcloud container clusters create "$CLUSTER_NAME" \
    --region="$REGION" \
    --num-nodes=2 \
    --machine-type="$MACHINE_TYPE" \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-ip-alias
fi

# Get cluster credentials
echo "Fetching cluster credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" --region="$REGION"

# Install NGINX Ingress Controller (required for path-based routing)
echo "Installing NGINX Ingress Controller..."
if ! helm status ingress-nginx -n ingress-nginx &>/dev/null; then
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.type=LoadBalancer
  echo "Waiting for NGINX Ingress LoadBalancer IP..."
  sleep 30
else
  echo "NGINX Ingress Controller already installed."
fi

# Create namespace
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Install Helm dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELM_DIR="$(cd "$SCRIPT_DIR/../helm" && pwd)"
VALUES_GCP="$SCRIPT_DIR/values-gcp.yaml"

echo "Installing Helm chart dependencies..."
helm dependency update "$HELM_DIR"

# Deploy WorkAdventure with Helm
echo "Deploying WorkAdventure..."
helm upgrade --install workadventure "$HELM_DIR" \
  --namespace "$NAMESPACE" \
  -f "$VALUES_GCP" \
  --set appVersion="$VERSION" \
  --set domainName="$DOMAIN" \
  --set singleDomain=true \
  --set play.image.tag="$VERSION" \
  --set back.image.tag="$VERSION" \
  --set mapstorage.image.tag="$VERSION" \
  --set uploader.image.tag="$VERSION" \
  --set ingress.enabled=true \
  --set ingress.className="nginx" \
  --set mapstorage.secretEnv.AUTHENTICATION_PASSWORD="$MAP_STORAGE_PASSWORD" \
  --set play.secretEnv.ROOM_API_SECRET_KEY="$ROOM_API_SECRET" \
  --set secretKey="$SECRET_KEY" \
  --set commonSecretEnv.MAP_STORAGE_API_TOKEN="$SECRET_KEY" \
  --wait

echo ""
echo "=== Deployment complete ==="
echo ""
echo "Your WorkAdventure instance is deploying. To get the external IP:"
echo "  kubectl get ingress -n $NAMESPACE"
echo "  kubectl get svc -n ingress-nginx  # NGINX LoadBalancer IP"
echo ""
echo "Configure your DNS to point $DOMAIN to the Ingress/LoadBalancer IP."
echo ""
echo "Secrets (save these securely):"
echo "  Map Storage password: $MAP_STORAGE_PASSWORD"
echo "  MAP_STORAGE_API_TOKEN: $SECRET_KEY"
echo ""
echo "To upload maps:"
echo "  npm run upload -- -u https://$DOMAIN/map-storage/ -k $SECRET_KEY"
echo "  # Or with Basic auth: -u https://admin:$MAP_STORAGE_PASSWORD@$DOMAIN/map-storage/"
echo ""
