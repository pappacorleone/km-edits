# Deploy WorkAdventure to Google Cloud Platform (GCP)

This guide walks you through deploying WorkAdventure to GCP using the `gcloud` CLI and Helm.

## Prerequisites

- **gcloud CLI** – [Install](https://cloud.google.com/sdk/docs/install)
- **kubectl** – [Install](https://kubernetes.io/docs/tasks/tools/)
- **helm 3.x** – [Install](https://helm.sh/docs/intro/install/)
- **GCP project** with billing enabled

## Quick start

1. **Authenticate** with GCP:

   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Run the deployment script**:

   ```bash
   cd contrib/gcp
   ./deploy-gcp.sh --project YOUR_GCP_PROJECT_ID --domain play.yourdomain.com
   ```

3. **Configure DNS** – Point your domain to the LoadBalancer IP:

   ```bash
   kubectl get svc -n ingress-nginx
   ```

   Use the `EXTERNAL-IP` of the `ingress-nginx-controller` service.

4. **Upload a map** – After DNS propagates:

   ```bash
   cd map-storage
   npm run upload -- -u https://play.yourdomain.com/map-storage/ -k YOUR_MAP_STORAGE_API_TOKEN
   ```

## Options

| Option | Description | Default |
| ------ | ----------- | ------- |
| `-p, --project` | GCP project ID | (required) |
| `-d, --domain` | Domain for WorkAdventure | (required) |
| `-r, --region` | GCP region | `us-central1` |
| `-n, --name` | GKE cluster name | `workadventure` |
| `-v, --version` | WorkAdventure image tag | `master` |

## What gets created

- **GKE cluster** – 2 nodes, e2-standard-4, autoscaling 1–5 nodes
- **NGINX Ingress Controller** – Path-based routing and LoadBalancer
- **WorkAdventure** – play, back, map-storage, uploader, icon, redis

## SSL/TLS (optional)

For HTTPS with automatic certificates:

1. Install [cert-manager](https://cert-manager.io/docs/installation/):

   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

2. Create a ClusterIssuer (e.g. Let’s Encrypt):

   ```yaml
   # LetsEncrypt (staging for testing)
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-staging
   spec:
     acme:
       server: https://acme-staging-v02.api.letsencrypt.org/directory
       email: your-email@example.com
       privateKeySecretRef:
         name: letsencrypt-staging
       solvers:
         - http01:
             ingress:
               class: nginx
   ```

3. Update `values-gcp.yaml`:

   ```yaml
   ingress:
     tls: true
     secretName: "workadventure-tls"
     annotationsRoot:
       cert-manager.io/cluster-issuer: "letsencrypt-staging"
     annotationsPath:
       cert-manager.io/cluster-issuer: "letsencrypt-staging"
   ```

## Cost estimate

Approximate monthly costs (us-central1):

- GKE cluster (2× e2-standard-4): ~$200–250
- Load balancer: ~$20
- Storage: ~$5–10

Use [GCP Pricing Calculator](https://cloud.google.com/products/calculator) for a detailed estimate.

## Cleanup

```bash
gcloud container clusters delete workadventure --region=us-central1
```

## Troubleshooting

- **Pods not ready**: `kubectl get pods -n workadventure` and `kubectl describe pod <name> -n workadventure`
- **No external IP**: Wait a few minutes for the LoadBalancer; check `kubectl get svc -n ingress-nginx`
- **502/503 errors**: Verify Ingress, services, and pod health
- **WebSocket issues**: NGINX Ingress supports WebSockets by default; ensure no proxy timeouts are too low
