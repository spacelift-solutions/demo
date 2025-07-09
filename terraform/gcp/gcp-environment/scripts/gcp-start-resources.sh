#!/bin/bash

# GCP Resource Start Script
# This script starts GKE clusters, Cloud SQL databases, and Compute Engine instances
# after they have been stopped for cost optimization.

set -euo pipefail

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-}"
REGION="${GCP_REGION:-us-east1}"
ZONE="${GCP_ZONE:-us-central1-a}"
CLUSTER_NAME="${GKE_CLUSTER_NAME:-demo-env-gke-cluster}"
CLUSTER_LOCATION="${GKE_CLUSTER_LOCATION:-europe-west4}"
NODE_POOL_NAME="${GKE_NODE_POOL_NAME:-demo-env-node-pool}"
DEFAULT_NODE_COUNT="${GKE_NODE_COUNT:-1}"

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

log "Starting GCP resource startup for project: $PROJECT_ID"

# Set the project
gcloud config set project "$PROJECT_ID"

# Function to start GKE cluster by scaling node pool up
start_gke_cluster() {
    log "Starting GKE cluster: $CLUSTER_NAME"
    
    # Check if cluster exists
    if ! gcloud container clusters describe "$CLUSTER_NAME" --location="$CLUSTER_LOCATION" &>/dev/null; then
        warn "GKE cluster $CLUSTER_NAME not found, skipping..."
        return 0
    fi
    
    # Scale node pool to desired size
    log "Scaling node pool $NODE_POOL_NAME to $DEFAULT_NODE_COUNT nodes..."
    if gcloud container clusters resize "$CLUSTER_NAME" \
        --node-pool="$NODE_POOL_NAME" \
        --num-nodes="$DEFAULT_NODE_COUNT" \
        --location="$CLUSTER_LOCATION" \
        --quiet; then
        log "Successfully scaled up GKE cluster $CLUSTER_NAME"
        
        # Wait for nodes to be ready
        log "Waiting for nodes to be ready..."
        sleep 30
        
        # Check node status
        if kubectl get nodes &>/dev/null; then
            log "GKE cluster nodes are ready"
        else
            warn "Could not verify node readiness (kubectl may not be configured)"
        fi
    else
        error "Failed to scale up GKE cluster $CLUSTER_NAME"
        return 1
    fi
}

# Function to start Cloud SQL instances
start_cloud_sql() {
    log "Starting Cloud SQL instances..."
    
    # Get all Cloud SQL instances that match our pattern
    local sql_instances
    sql_instances=$(gcloud sql instances list --filter="name:demo-env-db-*" --format="value(name)" || true)
    
    if [ -z "$sql_instances" ]; then
        warn "No Cloud SQL instances found matching pattern 'demo-env-db-*'"
        return 0
    fi
    
    while IFS= read -r instance_name; do
        if [ -n "$instance_name" ]; then
            log "Starting Cloud SQL instance: $instance_name"
            if gcloud sql instances patch "$instance_name" --activation-policy=ALWAYS --quiet; then
                log "Successfully started Cloud SQL instance: $instance_name"
                
                # Wait for instance to be ready
                log "Waiting for Cloud SQL instance to be ready..."
                local max_attempts=30
                local attempt=1
                
                while [ $attempt -le $max_attempts ]; do
                    local status
                    status=$(gcloud sql instances describe "$instance_name" --format="value(state)" || echo "UNKNOWN")
                    
                    if [ "$status" = "RUNNABLE" ]; then
                        log "Cloud SQL instance $instance_name is ready"
                        break
                    fi
                    
                    log "Waiting for instance to be ready... (attempt $attempt/$max_attempts)"
                    sleep 10
                    ((attempt++))
                done
                
                if [ $attempt -gt $max_attempts ]; then
                    warn "Cloud SQL instance $instance_name may not be fully ready yet"
                fi
            else
                error "Failed to start Cloud SQL instance: $instance_name"
            fi
        fi
    done <<< "$sql_instances"
}

# Function to start Compute Engine instances
start_compute_instances() {
    log "Starting Compute Engine instances..."
    
    # Start Windows instance
    local windows_instance="windows-instance"
    if gcloud compute instances describe "$windows_instance" --zone="$ZONE" &>/dev/null; then
        local instance_status
        instance_status=$(gcloud compute instances describe "$windows_instance" --zone="$ZONE" --format="value(status)")
        
        if [ "$instance_status" = "TERMINATED" ]; then
            log "Starting Windows instance: $windows_instance"
            if gcloud compute instances start "$windows_instance" --zone="$ZONE" --quiet; then
                log "Successfully started Windows instance: $windows_instance"
            else
                error "Failed to start Windows instance: $windows_instance"
            fi
        else
            log "Windows instance $windows_instance is already running (status: $instance_status)"
        fi
    else
        warn "Windows instance $windows_instance not found, skipping..."
    fi
    
    # Start any other demo-env instances
    local demo_instances
    demo_instances=$(gcloud compute instances list --filter="name:demo-env-* AND status:TERMINATED" --format="value(name,zone)" || true)
    
    while IFS=$'\t' read -r instance_name instance_zone; do
        if [ -n "$instance_name" ] && [ -n "$instance_zone" ]; then
            log "Starting Compute Engine instance: $instance_name in $instance_zone"
            if gcloud compute instances start "$instance_name" --zone="$instance_zone" --quiet; then
                log "Successfully started instance: $instance_name"
            else
                error "Failed to start instance: $instance_name"
            fi
        fi
    done <<< "$demo_instances"
}

# Function to verify resources are running
verify_resources() {
    log "Verifying resources are running..."
    
    # Check GKE cluster
    if gcloud container clusters describe "$CLUSTER_NAME" --location="$CLUSTER_LOCATION" &>/dev/null; then
        local node_count
        node_count=$(gcloud container node-pools describe "$NODE_POOL_NAME" --cluster="$CLUSTER_NAME" --location="$CLUSTER_LOCATION" --format="value(initialNodeCount)" || echo "0")
        log "GKE cluster $CLUSTER_NAME has $node_count nodes"
    fi
    
    # Check Cloud SQL instances
    local running_sql
    running_sql=$(gcloud sql instances list --filter="name:demo-env-db-* AND state:RUNNABLE" --format="value(name)" | wc -l)
    log "Cloud SQL instances running: $running_sql"
    
    # Check Compute Engine instances
    local running_compute
    running_compute=$(gcloud compute instances list --filter="name:(windows-instance OR demo-env-*) AND status:RUNNING" --format="value(name)" | wc -l)
    log "Compute Engine instances running: $running_compute"
}

# Main execution
main() {
    log "=== GCP Resource Startup Started ==="
    
    # Start resources
    start_cloud_sql
    start_compute_instances
    start_gke_cluster
    
    # Verify resources
    verify_resources
    
    log "=== GCP Resource Startup Completed ==="
    log "Resources have been started and should be ready for use."
    log "Use gcp-stop-resources.sh to stop them when done."
}

# Run main function
main "$@"