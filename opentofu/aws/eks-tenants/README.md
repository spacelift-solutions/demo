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

## Current tenants

The retail store demo apps (`ui`, `catalog`, `carts`, `assets`, `checkout`, `orders`) and `backstage`. Their workloads are deployed by the `kubernetes-deployments` stack, which runs after this one. Namespaces and service accounts are owned here, not by the kustomizations.

Network policies follow the service calls: `ui` calls catalog, carts, assets, checkout and orders; `checkout` calls orders. `ui` also accepts the VPC CIDR because its NLB uses instance targets. When an app starts calling a new service, add the caller to that tenant's `allowed_namespaces`.

## Flux

[`flux.tf`](flux.tf) installs the [Flux Operator](https://fluxoperator.dev) into `flux-system` and a `FluxInstance` that runs Flux at the version pinned in `local.flux_version`. To upgrade Flux, bump `flux_version`. If the current operator doesn't bundle that version, bump `flux_operator_version` too.

The `FluxInstance` reconciles
`clusters/spacelift-solutions` from the private
[`spacelift-solutions/flux`](https://github.com/spacelift-solutions/flux)
repository. [`flux_repository.tf`](flux_repository.tf) generates an ED25519 key
pair, registers the public key as a read-only repository deploy key, and stores
the private key in the `flux-system/flux-repository-auth` Secret. GitHub host
keys are pinned in that file and should only be changed against GitHub's
published metadata.

The reconciliation root is intentionally empty. The
`kubernetes-deployments` stack remains the sole owner of the demo workloads.
Before moving any resource to Flux, remove it from that stack in the same
coordinated cutover so the cluster never has two reconcilers for one object.

To rotate the repository credential, replace
`tls_private_key.flux_repository` in a reviewed Spacelift run. The deploy key
and Kubernetes Secret must update together; do not create an unmanaged key.

### SOPS decryption with AWS KMS

[`flux_sops.tf`](flux_sops.tf) gives `flux-system/kustomize-controller` a dedicated EKS Pod Identity role with only `kms:Decrypt` on `var.flux_sops_kms_key_arn`.
It reuses the existing demo SOPS key owned by the `aws-cloudformation-kms` stack; this stack does not own or replace that key.
The existing key policy permits the account to delegate access through IAM.
The cluster's `eks-pod-identity-agent` add-on must remain enabled.

The FluxInstance patches its generated root Kustomization to enable SOPS and its controller pod template with the association ID.
This creates/restarts the pod after the association is ready so EKS injects temporary credentials.
No static AWS credentials, IRSA annotations, decryption Secret reference, or object-level decryption service account are needed.

The key ARN must match `.sops.yaml` in the Flux repository.
Apply this stack before reconciling encrypted Secrets.
See the [Flux secret workflow](https://github.com/spacelift-solutions/flux#encrypting-and-decrypting-secrets) for local encryption, editing, and decryption commands.
Authors need their own IAM access to encrypt/decrypt with this key; the controller only decrypts.

To roll back the integration, first remove or migrate encrypted resources from Flux, then remove the decryption patch and Pod Identity resources.
Keep the KMS key available for encrypted Git history.
Removing access while encrypted resources remain will cause reconciliation failures.

## Inputs

`cluster_name` comes from the cluster stack through a Spacelift dependency.
`aws_region` and `vpc_cidr` come from the `Spacelift-Solutions cluster`
context. The `Spacelift-Solutions[Bot]` context supplies the GitHub App ID,
installation ID, and mounted private key used only to provision the deploy
key. A new cluster re-triggers this stack.

## Testing

```sh
tofu init -backend=false && tofu test
```
