# eks-tenant

Onboards one application onto the shared EKS cluster. Each tenant gets:

| Resource | Purpose |
|---|---|
| Namespace | Isolation boundary, labelled `tenant=<name>` |
| ResourceQuota | Caps total CPU, memory, pods, PVCs, storage and load balancers so one app can't starve the others |
| LimitRange | Default requests and limits for containers that don't set them (needed once a quota exists) |
| NetworkPolicy | Pods only accept ingress from their own namespace, `kube-system`, `prometheus`, and any extra namespaces or CIDRs you allow. Egress is open. |
| RoleBinding (optional) | Grants the built-in `admin` ClusterRole in the namespace to `admin_groups` |
| Service account + IAM role (optional) | IRSA role that the `<name>` service account assumes; created when `iam_policy_arns` or `iam_policy_json` is set |

## Usage

The caller configures the `aws` and `kubernetes` providers for the cluster.

```hcl
module "reports" {
  source = "../modules/eks-tenant"

  name         = "reports"
  cluster_name = "eks-cluster"

  resource_quota = {
    requests_cpu    = "8"
    requests_memory = "16Gi"
  }

  # Let an ALB in IP mode reach the pods
  network_policy = {
    allowed_cidrs = ["10.0.0.0/16"]
  }

  iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}
```

Workloads use the IAM role by setting `serviceAccountName: <name>`.

See [`examples/basic`](examples/basic) for a full configuration.

## Inputs

| Name | Default | Description |
|---|---|---|
| `name` | — | Tenant name; becomes the namespace, service account and IAM role suffix |
| `cluster_name` | — | EKS cluster name, used to find its OIDC provider |
| `labels` | `{}` | Extra namespace labels |
| `resource_quota` | 4 CPU / 8Gi requested, 8 CPU / 16Gi limit, 50 pods, 10 PVCs, 100Gi storage, 2 LBs | Set to `null` to skip the quota |
| `container_defaults` | 100m / 128Mi requested, 500m / 512Mi limit | LimitRange defaults |
| `network_policy` | enabled, allows `kube-system` and `prometheus` | `enabled`, `allowed_namespaces`, `allowed_cidrs` |
| `admin_groups` | `[]` | Kubernetes groups given `admin` in the namespace |
| `iam_policy_arns` | `[]` | Managed policies for the IRSA role |
| `iam_policy_json` | `null` | Inline policy for the IRSA role |
| `tags` | `{}` | Tags for AWS resources |

## Outputs

`namespace`, `service_account`, `iam_role_arn` (null when no role is created).

## Testing

```sh
tofu init -backend=false && tofu test
```

Tests use mocked providers, so they need no AWS credentials or cluster.
