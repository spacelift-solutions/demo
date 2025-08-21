# GCP Spacelift Worker Pool Deployment

This Terraform configuration deploys a private Docker-based worker pool in GCP through a Spacelift stack.

## 🏗️ Architecture

- **Worker Type**: Private Docker-based worker pool
- **Location**: us-central1-a (GCP)
- **Instance**: 1x e2-micro (cost-optimized)
- **Network**: Private VPC with 10.0.0.0/16 subnet
- **Scaling**: Min/Max 1 instance

## 📋 Prerequisites

1. **Spacelift Account**: Access to spacelift-solutions.app.spacelift.io
2. **GCP Project**: swift-climate-439711-s0 
3. **Worker Pool Config**: worker-pool-01K34CN577PKJ3KVR1TMGSX03K file
4. **GCP Context**: gcp-config context with GOOGLE_APPLICATION_CREDENTIALS

## 🚀 Deployment Steps

### 1. Create New Spacelift Stack

1. Go to Spacelift UI → **Stacks** → **Create Stack**
2. Choose **Version Control System**
3. Connect to your repository containing this code
4. Set stack name: `gcp-worker-pool`
5. Set root space or desired space

### 2. Configure Stack Settings

#### **Contexts**
- Attach the `gcp-config` context to your stack
- This provides GCP authentication via the mounted gcp.json file

#### **Variables** (Environment → Variables)
Add these as **stack variables**:

| Variable | Value | Type | Sensitive |
|----------|-------|------|-----------|
| `spacelift_api_key_endpoint` | `https://spacelift-solutions.app.spacelift.io/graphql` | Environment | No |
| `spacelift_api_key_id` | `***REMOVED***` | Environment | Yes ✅ |
| `spacelift_api_key_secret` | `***REMOVED***` | Environment | Yes ✅ |

### 3. Handle Worker Pool Configuration File

The worker pool config file needs to be available to the stack. Options:

**Option A**: Add to repository (not recommended - contains sensitive data)
**Option B**: Mount as file in gcp-config context
**Option C**: Convert content to variable

For security, I recommend **Option B** - add the file to your gcp-config context:
1. Go to Contexts → gcp-config → Mounted files
2. Add new file: `/mnt/workspace/worker-pool-config.json`
3. Upload your `worker-pool-01K34CN577PKJ3KVR1TMGSX03K` file

### 4. Deploy the Stack

1. **Trigger Run**: Go to your stack → **Trigger** → **Run**
2. **Plan Phase**: Review the planned resources
3. **Apply Phase**: Confirm and apply

## 📊 Expected Resources

The deployment will create:
- 1x Compute Instance (e2-micro)
- 1x Instance Group Manager
- 1x VPC Network 
- 1x Subnet
- 1x Firewall Rules
- IAM roles and service accounts

## 🔧 Post-Deployment

### Verify Worker Pool
1. Go to Spacelift UI → **Worker Pools**
2. Your new worker pool should appear as "Healthy"
3. Test by running a stack with this worker pool

### Use the Worker Pool
1. Go to any stack → **Settings** → **Behavior** 
2. Set **Worker pool** to your new worker pool
3. The stack will now run on your private GCP workers

## 💰 Cost Estimation

- **e2-micro instance**: ~$5-10/month (depending on usage)
- **Networking**: ~$1-2/month
- **Total**: ~$6-12/month

## 🛠️ Troubleshooting

### Common Issues

1. **Authentication Error**
   - Verify gcp-config context is attached
   - Check GCP service account permissions

2. **Worker Pool Config Not Found**
   - Ensure worker pool config file is properly mounted
   - Check file path in main.tf

3. **API Key Issues**
   - Verify API keys are set as sensitive variables
   - Check endpoint URL format

### Logs & Monitoring

- **Spacelift Logs**: Check run logs in Spacelift UI
- **GCP Logs**: View instance logs in GCP Console
- **Worker Status**: Monitor in Worker Pools section

## 🔄 Updates & Maintenance

To update the worker pool:
1. Modify the Terraform configuration
2. Commit changes to your repository
3. Trigger a new run in Spacelift

## 🗑️ Cleanup

To destroy the worker pool:
1. Go to your stack → **Settings** → **Destruction**
2. Enable **Allows manual destruction**
3. Trigger a **Destroy** run

---

## Files Structure

```
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions  
├── outputs.tf           # Output definitions
├── terraform.tfvars     # Non-sensitive variables
├── README.md           # This guide
└── .gitignore          # Git ignore rules
```
