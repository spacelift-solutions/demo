# EKS Spacelift workers

The `worker-pool-on-eks` stack installs the controller, stores the existing admin-managed pool credentials in a Kubernetes Secret, and creates a two-worker `WorkerPool` in `spacelift-worker-controller-system`.
The private key input is already base64-encoded by `admin/outputs.tf`; preserve that encoding in the Secret value as required by the controller.

Run pods reference the `mayday-ghcr` image-pull Secret.
Flux owns that new Secret through `spacelift-solutions/flux` at `clusters/spacelift-solutions/platform/spacelift-workers/ghcr.sops.yaml`.
It contains a dedicated `read:packages` credential for the private Mayday images.
Reconcile that Secret before applying this stack or scheduling Mayday runs.
The controller Helm release owns the namespace; Flux does not take over the controller, pool, or registration credentials.

After apply, verify `spacelift-eks` exists and has two registered workers in Spacelift.
Run a Mayday Ansible stack and confirm its pod pulls the runner image without `ImagePullBackOff`.

For rollback, drain active runs before removing the WorkerPool.
Keep its pool credentials and registry Secret until all worker run pods have finished.
