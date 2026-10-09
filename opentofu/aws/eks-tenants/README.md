# eks-tenants

Root configuration for the `eks-tenants` Spacelift stack. It creates one isolated tenant per application on the Spacelift-Solutions cluster using the [`eks-tenant`](../modules/eks-tenant) module.

## Onboarding an app

1. Add an entry to `local.tenants` in [`tenants.tf`](tenants.tf):

   ```hcl
   locals {
     tenants = {
       my-app = {
         resource_quota = { requests_cpu = "8", requests_memory = "16Gi" }
         admin_groups   = ["demo-apps"]
       }
     }
   }
   ```

   Every field is optional. `my-app = {}` gets the module defaults.

2. Open a PR. The stack plans on the PR and applies on merge.
3. Deploy the app into the `my-app` namespace. To use the tenant's IAM role, run its pods as service account `my-app`.

The key becomes the namespace, service account and part of the IAM role name. Keep it a lowercase DNS label of at most 29 characters.

## Inputs

`cluster_name` comes from the cluster stack through a Spacelift dependency, and `aws_region` from the `Spacelift-Solutions cluster` context. A new cluster re-triggers this stack.
