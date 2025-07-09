#!/bin/bash

# GCP Resource Stop Script
# This script stops GKE clusters, Cloud SQL databases, and Compute Engine instances
# to reduce costs when resources are not needed.

set -euo pipefail

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-}"
REGION="${GCP_REGION:-us-east1}"
ZONE="${GCP_ZONE:-us-central1-a}"
CLUSTER_NAME="${GKE_CLUSTER_NAME:-demo-env-gke-cluster}"
CLUSTER_LOCATION="${GKE_CLUSTER_LOCATION:-europe-west4}"
NODE_POOL_NAME="${GKE_NODE_POOL_NAME:-demo-env-node-pool}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Check if project ID is set
if [ -z "$PROJECT_ID" ]; then
    error "GCP_PROJECT_ID environment variable is not set"
    exit 1
fi

log "Starting GCP resource shutdown for project: $PROJECT_ID"

# Set the project
gcloud config set project "$PROJECT_ID"

# Function to stop GKE cluster by scaling node pool to 0
stop_gke_cluster() {
    log "Stopping GKE cluster: $CLUSTER_NAME"
    
    # Check if cluster exists
    if ! gcloud container clusters describe "$CLUSTER_NAME" --location="$CLUSTER_LOCATION" &>/dev/null; then
        warn "GKE cluster $CLUSTER_NAME not found, skipping..."
        return 0
    fi
    
    # Scale node pool to 0
    log "Scaling node pool $NODE_POOL_NAME to 0 nodes..."
    if gcloud container clusters resize "$CLUSTER_NAME" \
        --node-pool="$NODE_POOL_NAME" \
        --num-nodes=0 \
        --location="$CLUSTER_LOCATION" \
        --quiet; then
        log "Successfully scaled down GKE cluster $CLUSTER_NAME"
    else
        error "Failed to scale down GKE cluster $CLUSTER_NAME"
        return 1
    fi
}

# Function to stop Cloud SQL instances
stop_cloud_sql() {
    log "Stopping Cloud SQL instances..."
    
    # Get all Cloud SQL instances that match our pattern
    local sql_instances
    sql_instances=$(gcloud sql instances list --filter="name:demo-env-db-*" --format="value(name)" || true)
    
    if [ -z "$sql_instances" ]; then
        warn "No Cloud SQL instances found matching pattern 'demo-env-db-*'"
        return 0
    fi
    
    while IFS= read -r instance_name; do
        if [ -n "$instance_name" ]; then
            log "Stopping Cloud SQL instance: $instance_name"
            if gcloud sql instances patch "$instance_name" --activation-policy=NEVER --quiet; then
                log "Successfully stopped Cloud SQL instance: $instance_name"
            else
                error "Failed to stop Cloud SQL instance: $instance_name"
            fi
        fi
    done <<< "$sql_instances"
}

# Function to stop Compute Engine instances
stop_compute_instances() {
    log "Stopping Compute Engine instances..."
    
    # Stop Windows instance
    local windows_instance="windows-instance"
    if gcloud compute instances describe "$windows_instance" --zone="$ZONE" &>/dev/null; then
        log "Stopping Windows instance: $windows_instance"
        if gcloud compute instances stop "$windows_instance" --zone="$ZONE" --quiet; then
            log "Successfully stopped Windows instance: $windows_instance"
        else
            error "Failed to stop Windows instance: $windows_instance"
        fi
    else
        warn "Windows instance $windows_instance not found, skipping..."
    fi
    
    # Stop any other demo-env instances
    local demo_instances
    demo_instances=$(gcloud compute instances list --filter="name:demo-env-*" --format="value(name,zone)" || true)
    
    while IFS=$'\t' read -r instance_name instance_zone; do
        if [ -n "$instance_name" ] && [ -n "$instance_zone" ]; then
            log "Stopping Compute Engine instance: $instance_name in $instance_zone"
            if gcloud compute instances stop "$instance_name" --zone="$instance_zone" --quiet; then
                log "Successfully stopped instance: $instance_name"
            else
                error "Failed to stop instance: $instance_name"
            fi
        fi
    done <<< "$demo_instances"
}

# Main execution
main() {
    log "=== GCP Resource Shutdown Started ==="
    
    # Stop resources
    stop_gke_cluster
    stop_cloud_sql
    stop_compute_instances
    
    log "=== GCP Resource Shutdown Completed ==="
    log "Resources have been stopped to reduce costs."
    log "Use gcp-start-resources.sh to start them again."
}

# Run main function
main "$@"