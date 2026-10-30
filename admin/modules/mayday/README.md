# Mayday control plane

Creates the Mayday spaces, four stacks pointing at `spacelift-solutions/Mayday`, dependency references, SSH context, scoped Flows API key, and Intent policy.
All four stacks use `spacelift.io/spacelift-solutions/stacks-module/spacelift`, matching the other demo stacks.
Context attachments, stack environment variables, and dependencies are configured through those module calls.
The SSH context and mounted file remain here because stacks-module does not create them.
The infrastructure stack receives the public key as `/mnt/workspace/mayday.pub`; OpenTofu reads it with `file()` rather than receiving multiline key material in an environment variable.
`WORKERS` remains a separate resource with `ignore_changes` so admin applies preserve Flows capacity changes.
The parent `admin/mayday.tf` supplies the shared EC2 worker pool, cluster stack, and existing AWS integration.
Service and diagnostic stacks use Spacelift’s standard AWS Ansible runner, pinned by digest, and the AWS integration for SSH through SSM to the private target in the monitor's VPC.
GitHub Actions builds the Go binary; Ansible installs the checksum-verified artifact for its exact source commit.
Set `TF_VAR_mayday_flows_token` as a write-only variable on the admin stack using a deployment API key restricted to the Mayday Flows project.
The module passes it to `mayday-flows` as `FLOWS_TOKEN`; the Jira credential remains separate.

Workload infrastructure and application code live in Mayday.
Flux owns the monitor and `mayday` namespace from Mayday manifests; do not also add that namespace to `eks-tenants`.
There is no monitor Spacelift stack.
Mayday stores its demo password and webhook token in a SOPS-encrypted Secret using Flux’s KMS key.
Set the matching `TF_VAR_webhook_token` as a write-only variable on `mayday-flows`; this module does not overwrite that operator-managed value.

The current Spacelift provider supports Intent policies but does not expose Intent project/attachment resources.
`terraform_data.intent_project` runs the idempotent `bootstrap_intent.py` on creation or configuration changes using a dedicated API key.
Intent rejects administrative run tokens, so the script explicitly exchanges the bootstrap key for a session and never uses the inherited `SPACELIFT_API_TOKEN`.
The key can only read, create projects, and attach policies/cloud integrations in the Mayday Intent space; it cannot edit policies or operate Intent resources.
OpenTofu manages the key and role attachment and passes the sensitive secret only to the provisioner environment.
It creates a project, checks ownership, attaches the policy, then attaches the cloud integration.
It does not delete projects on destroy.
Re-run with `-replace=module.mayday.terraform_data.intent_project` if an administrator removes an attachment outside this configuration.

The recovery API key is restricted to the Operations child space with read, run-trigger, and stack-configuration permissions.
It cannot edit policies or operate infrastructure stacks.
The service's `WORKERS` input starts at two; Flows owns later values.
Policy administration remains a separate role from the operator who demonstrates Intent resource operations.

After applying, follow the [Mayday runbook](https://github.com/spacelift-solutions/Mayday/blob/main/docs/runbook.md) to publish the images/custom app, seed the Intent license, set the Flows project and app version IDs, and connect the monitor webhook.
No resource has a secret hardcoded in source.

## Validation

```sh
tofu init -backend=false
tofu validate
tofu test
python3 -m pip install -r tests/requirements.txt
python3 -m unittest discover -s tests -p 'test_*.py'
```

Render `license.rego.tftpl` with `license_bucket = "example-license"` into a temporary `.rego` file, then run `opa test` against that file and `tests/license_test.rego`.
Live API/worker/network behavior still needs a Spacelift plan and rehearsal in the solutions account.
