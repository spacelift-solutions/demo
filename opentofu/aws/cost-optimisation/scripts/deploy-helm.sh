#!/bin/bash

set -e

# Deploy Helm charts for FinOps monitoring stack
# This script is called as a hook from Spacelift after infrastructure is provisioned

echo "========================================="
echo "Deploying FinOps Monitoring Stack"
echo "========================================="

# Configuration
CLUSTER_NAME="${TF_VAR_cluster_name:-eks-cluster}"
AWS_REGION="${TF_VAR_aws_region:-us-east-1}"
OPENCOST_NAMESPACE="${TF_OUTPUT_opencost_namespace:-opencost}"
PROMETHEUS_NAMESPACE="${TF_OUTPUT_prometheus_namespace:-prometheus}"
GRAFANA_NAMESPACE="${TF_OUTPUT_grafana_namespace:-grafana}"

# Helm chart versions
OPENCOST_VERSION="1.108.0"
PROMETHEUS_VERSION="25.8.0"
GRAFANA_VERSION="7.0.8"

# Paths to values files
# Script runs from /mnt/workspace in Spacelift
REPO_ROOT="/mnt/workspace/source"
VALUES_DIR="${REPO_ROOT}/kubernetes/aws/finops"

echo "Configuration:"
echo "  Cluster: ${CLUSTER_NAME}"
echo "  Region: ${AWS_REGION}"
echo "  Values Dir: ${VALUES_DIR}"

# Update kubeconfig
echo ""
echo "[1/5] Updating kubeconfig for EKS cluster..."
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

# Verify cluster connectivity
echo ""
echo "[2/5] Verifying cluster connectivity..."
kubectl cluster-info
kubectl get nodes

# Add Helm repositories
echo ""
echo "[3/5] Adding Helm repositories..."
helm repo add opencost https://opencost.github.io/opencost-helm-chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Deploy Prometheus (required for OpenCost)
echo ""
echo "[4/5] Deploying Prometheus..."
if helm list -n "${PROMETHEUS_NAMESPACE}" | grep -q "prometheus"; then
    echo "  Prometheus already installed, upgrading..."
    helm upgrade prometheus prometheus-community/prometheus \
        --namespace "${PROMETHEUS_NAMESPACE}" \
        --version "${PROMETHEUS_VERSION}" \
        --values "${VALUES_DIR}/prometheus/values.yaml" \
        --wait \
        --timeout 10m
else
    echo "  Installing Prometheus..."
    helm install prometheus prometheus-community/prometheus \
        --namespace "${PROMETHEUS_NAMESPACE}" \
        --version "${PROMETHEUS_VERSION}" \
        --values "${VALUES_DIR}/prometheus/values.yaml" \
        --wait \
        --timeout 10m
fi

# Wait for Prometheus to be ready
echo "  Waiting for Prometheus to be ready..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/component=server,app.kubernetes.io/name=prometheus \
    -n "${PROMETHEUS_NAMESPACE}" \
    --timeout=300s || true

# Deploy OpenCost
echo ""
echo "[5/5] Deploying OpenCost..."
if helm list -n "${OPENCOST_NAMESPACE}" | grep -q "opencost"; then
    echo "  OpenCost already installed, upgrading..."
    helm upgrade opencost opencost/opencost \
        --namespace "${OPENCOST_NAMESPACE}" \
        --version "${OPENCOST_VERSION}" \
        --values "${VALUES_DIR}/opencost/values.yaml" \
        --wait \
        --timeout 10m
else
    echo "  Installing OpenCost..."
    helm install opencost opencost/opencost \
        --namespace "${OPENCOST_NAMESPACE}" \
        --version "${OPENCOST_VERSION}" \
        --values "${VALUES_DIR}/opencost/values.yaml" \
        --wait \
        --timeout 10m
fi

# Wait for OpenCost to be ready
echo "  Waiting for OpenCost to be ready..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/name=opencost \
    -n "${OPENCOST_NAMESPACE}" \
    --timeout=300s || true

# Deploy Grafana
echo ""
echo "[6/7] Deploying Grafana..."
if helm list -n "${GRAFANA_NAMESPACE}" | grep -q "grafana"; then
    echo "  Grafana already installed, upgrading..."
    helm upgrade grafana grafana/grafana \
        --namespace "${GRAFANA_NAMESPACE}" \
        --version "${GRAFANA_VERSION}" \
        --values "${VALUES_DIR}/grafana/values.yaml" \
        --wait \
        --timeout 10m
else
    echo "  Installing Grafana..."
    helm install grafana grafana/grafana \
        --namespace "${GRAFANA_NAMESPACE}" \
        --version "${GRAFANA_VERSION}" \
        --values "${VALUES_DIR}/grafana/values.yaml" \
        --wait \
        --timeout 10m
fi

# Wait for Grafana to be ready
echo "  Waiting for Grafana to be ready..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/name=grafana \
    -n "${GRAFANA_NAMESPACE}" \
    --timeout=300s || true

# Verification
echo ""
echo "[7/7] Verifying deployments..."
echo ""
echo "Prometheus:"
kubectl get pods -n "${PROMETHEUS_NAMESPACE}" -l app.kubernetes.io/name=prometheus
echo ""
echo "OpenCost:"
kubectl get pods -n "${OPENCOST_NAMESPACE}" -l app.kubernetes.io/name=opencost
echo ""
echo "Grafana:"
kubectl get pods -n "${GRAFANA_NAMESPACE}" -l app.kubernetes.io/name=grafana

echo ""
echo "========================================="
echo "FinOps Monitoring Stack Deployed Successfully!"
echo "========================================="
echo ""
echo "Access Instructions:"
echo ""
echo "OpenCost UI:"
echo "  kubectl port-forward -n ${OPENCOST_NAMESPACE} svc/opencost 9090:9090"
echo "  Open: http://localhost:9090"
echo ""
echo "Prometheus:"
echo "  kubectl port-forward -n ${PROMETHEUS_NAMESPACE} svc/prometheus-server 9091:80"
echo "  Open: http://localhost:9091"
echo ""
echo "Grafana:"
echo "  kubectl port-forward -n ${GRAFANA_NAMESPACE} svc/grafana 3000:80"
echo "  Open: http://localhost:3000"
echo "  Username: admin"
echo "  Password: (run) kubectl get secret -n ${GRAFANA_NAMESPACE} grafana -o jsonpath='{.data.admin-password}' | base64 -d"
echo ""
