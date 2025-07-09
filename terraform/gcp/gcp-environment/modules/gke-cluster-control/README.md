# GKE Cluster Control Module

This module provides manual control over GKE cluster state for cost optimization during non-working hours.

## Purpose

- **Cost Control**: Stop GKE clusters when not needed (evenings, weekends)
- **Work Hours**: Start clusters for monitoring and development work
- **Manual Control**: Never auto-deploys - requires manual execution

## How It Works

1. **Dependencies**: Gets cluster info from the main GKE stack
2. **State Control**: Uses `desired_state` variable to control cluster
3. **Spacelift Hooks**: Executes scripts via `after.apply` hooks (not local-exec)
4. **Script Execution**: Runs existing `gcp-start-resources.sh` or `gcp-stop-resources.sh`
5. **Status Reporting**: Reports current cluster state after operation

## Usage

### Starting the Cluster for Work Hours

1. Go to Spacelift stack `gcp-gke-control`
2. Set environment variable `TF_VAR_desired_state = "running"`
3. Trigger manual run
4. Cluster will scale up to 1 node (or specified count)

### Stopping the Cluster After Work

1. Go to Spacelift stack `gcp-gke-control`
2. Set environment variable `TF_VAR_desired_state = "stopped"`
3. Trigger manual run
4. Cluster will scale down to 0 nodes

### Force Execution

If you need to force execution regardless of current state:
1. Set `TF_VAR_force_execution = "true"`
2. Trigger manual run
3. Reset `TF_VAR_force_execution = "false"` afterward

## Variables

- `desired_state`: `"running"` or `"stopped"`
- `desired_node_count`: Number of nodes when starting (default: 1)
- `force_execution`: Force execution even if no changes (default: false)

## What Gets Controlled

The underlying scripts control:
- ✅ **GKE Cluster**: Scales node pool to 0 (stopped) or desired count (running)
- ✅ **Cloud SQL**: Stops/starts database instances
- ✅ **Compute Engine**: Stops/starts VM instances

## Integration with Monitoring

- **Monitoring depends on GKE cluster** being running
- **Start cluster first** before expecting monitoring to work
- **Stop cluster** when monitoring not needed to save costs

## Cost Savings

- **GKE Nodes**: ~$20-50/month per node when stopped
- **Cloud SQL**: ~$15-30/month when stopped
- **Compute Engine**: ~$10-25/month per instance when stopped

## Safety Features

- **Manual only**: Never auto-deploys
- **State validation**: Checks current state before operations
- **Error handling**: Scripts have comprehensive error handling
- **Status reporting**: Shows current state after operations