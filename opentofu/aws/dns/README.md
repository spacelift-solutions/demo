# Shared demo DNS

The `demo-dns` Spacelift stack owns the public Route 53 zone
`spacelift.shovel-emporium.com` in demo AWS account `234878555361`.
`admin/dns.tf` manages the stack with the existing demo AWS integration and
EC2 worker pool. Spacelift owns its state. A dependency supplies `cluster_name` from the shared EKS stack.

This stack also provisions the ExternalDNS IAM role and EKS Pod Identity
association for `external-dns/external-dns`. It can list zones, but record
reads and writes are scoped to this hosted zone; writes allow only A, AAAA,
CNAME and ownership TXT records, never delegation NS or SOA records.
The Flux repository owns the controller, its namespace and service account.
Apply this stack before reconciling the ExternalDNS HelmRelease. No AWS keys
or credentials belong in Flux.

The parent `shovel-emporium.com` stays registered and hosted in Cloudflare.
After initial creation, use this stack's `name_servers` output to configure all four delegation NS records for `spacelift` in the Cloudflare parent zone.
Do not replace the parent domain's Cloudflare nameservers.

Application stacks own records below the delegated zone and their certificates.
Mayday uses `mayday.spacelift.shovel-emporium.com` for its authenticated Flow
callback. The shared hosted zone has deletion protection and is independent of
Mayday's application lifecycle.

Validate with `tofu init -backend=false -lockfile=readonly`, `tofu fmt -check`,
and `tofu validate`. Before confirming the first run, verify the plan creates
only this hosted zone and its scoped ExternalDNS IAM role, policy, and Pod Identity association. After delegation, query the parent Cloudflare nameserver
and all four Route 53 nameservers to verify the delegation and SOA answers.
