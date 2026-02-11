#!/bin/bash
# Deploy WorkAdventure to a GCP e2-small Compute Engine VM
# Usage: ./deploy-e2-small.sh
#
# Prerequisites: gcloud CLI authenticated with access to the sundaistack project

set -euo pipefail

PROJECT_ID="sundaistack"
ZONE="us-east1-b"
INSTANCE_NAME="workadventure"
MACHINE_TYPE="e2-small"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Deploying WorkAdventure to GCP ==="
echo "Project:  $PROJECT_ID"
echo "Zone:     $ZONE"
echo "Machine:  $MACHINE_TYPE"
echo "Instance: $INSTANCE_NAME"
echo ""

# Set project
gcloud config set project "$PROJECT_ID"

# Create firewall rule for HTTP if it doesn't exist
if ! gcloud compute firewall-rules describe allow-http --project="$PROJECT_ID" &>/dev/null; then
    echo "Creating firewall rule for HTTP (port 80)..."
    gcloud compute firewall-rules create allow-http \
        --project="$PROJECT_ID" \
        --direction=INGRESS \
        --priority=1000 \
        --network=default \
        --action=ALLOW \
        --rules=tcp:80 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=http-server
    echo "Firewall rule created."
else
    echo "Firewall rule 'allow-http' already exists."
fi

# Create firewall rule for HTTPS if it doesn't exist
if ! gcloud compute firewall-rules describe allow-https --project="$PROJECT_ID" &>/dev/null; then
    echo "Creating firewall rule for HTTPS (port 443)..."
    gcloud compute firewall-rules create allow-https \
        --project="$PROJECT_ID" \
        --direction=INGRESS \
        --priority=1000 \
        --network=default \
        --action=ALLOW \
        --rules=tcp:443 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=https-server
    echo "Firewall rule created."
else
    echo "Firewall rule 'allow-https' already exists."
fi

# Delete existing instance if it exists
if gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID" &>/dev/null; then
    echo ""
    read -p "Instance '$INSTANCE_NAME' already exists. Delete and recreate? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        gcloud compute instances delete "$INSTANCE_NAME" \
            --zone="$ZONE" \
            --project="$PROJECT_ID" \
            --quiet
    else
        echo "Aborting."
        exit 1
    fi
fi

# Create the VM
echo ""
echo "Creating e2-small VM..."
gcloud compute instances create "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server,https-server \
    --metadata-from-file=startup-script="$SCRIPT_DIR/vm-startup.sh"

echo ""
echo "VM created. Waiting for external IP..."

# Get the external IP
EXTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --project="$PROJECT_ID" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "=========================================="
echo "  VM External IP: $EXTERNAL_IP"
echo "=========================================="
echo ""
echo "The startup script is now installing Docker and WorkAdventure."
echo "This takes 3-5 minutes on an e2-small."
echo ""
echo "To monitor progress:"
echo "  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID -- tail -f /var/log/workadventure-setup.log"
echo ""
echo "Once ready, access WorkAdventure at:"
echo "  https://laplaya.chat"
echo "  (IP: $EXTERNAL_IP — ensure DNS A record points to this IP)"
echo ""
echo "To check service status:"
echo "  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID -- 'cd /opt/workadventure && docker compose ps'"
echo ""
echo "To view secrets (map-storage password etc):"
echo "  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID -- cat /opt/workadventure/.env"
echo ""
echo "To tear down:"
echo "  gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID"
echo "  gcloud compute firewall-rules delete allow-http --project=$PROJECT_ID"
echo "  gcloud compute firewall-rules delete allow-https --project=$PROJECT_ID"
