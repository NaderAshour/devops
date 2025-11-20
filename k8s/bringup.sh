#!/bin/bash

# ----------------------------------------------
# Set namespace
NAMESPACE=dev

# ----------------------------------------------
# Create namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace $NAMESPACE
else
    echo "Namespace $NAMESPACE already exists."
fi

# ----------------------------------------------
# Deploy PostgreSQL (Dev)
echo "=== Deploying PostgreSQL (Dev) ==="
if helm status postgres-dev -n $NAMESPACE &> /dev/null; then
    echo "PostgreSQL already exists, upgrading..."
    helm upgrade postgres-dev bitnami/postgresql -n $NAMESPACE -f k8s/helm/postgres/values-dev.yaml
else
    echo "PostgreSQL not found, installing..."
    helm install postgres-dev bitnami/postgresql -n $NAMESPACE -f k8s/helm/postgres/values-dev.yaml
fi

# ----------------------------------------------
# Deploy Redis (Dev)
echo "=== Deploying Redis (Dev) ==="
if helm status redis-dev -n $NAMESPACE &> /dev/null; then
    echo "Redis already exists, upgrading..."
    helm upgrade redis-dev bitnami/redis -n $NAMESPACE -f k8s/helm/redis/values-dev.yaml
else
    echo "Redis not found, installing..."
    helm install redis-dev bitnami/redis -n $NAMESPACE -f k8s/helm/redis/values-dev.yaml
fi

# ----------------------------------------------
# Apply Application Deployments & Services
echo "=== Applying Application Manifests (Dev) ==="
kubectl apply -f k8s/dev/

# ----------------------------------------------
# Deploy Ingress (Dev)
echo "=== Deploying Ingress (Dev) ==="
if helm status ingress-dev -n $NAMESPACE &> /dev/null; then
    echo "Ingress already exists, upgrading..."
    helm upgrade ingress-dev k8s/helm/ingress -n $NAMESPACE -f k8s/helm/ingress/values-dev.yaml
else
    echo "Ingress not found, installing..."
    helm install ingress-dev k8s/helm/ingress -n $NAMESPACE -f k8s/helm/ingress/values-dev.yaml
fi

# ----------------------------------------------
echo "=== Waiting for LoadBalancer external IP ==="

# Wait until LB IP is assigned
while true; do
    EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx \
        -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>/dev/null)

    if [[ -n "$EXTERNAL_IP" ]]; then
        echo "LoadBalancer IP assigned: $EXTERNAL_IP"
        break
    fi

    echo "Waiting for external IP..."
    sleep 5
done

# ----------------------------------------------
# Print final URLs
echo ""
echo "=============================="
echo "   🚀 Dev Environment Ready"
echo "=============================="
echo "Vote App URL:    http://$EXTERNAL_IP/vote"
echo "Result App URL:  http://$EXTERNAL_IP/result"
echo "=============================="
