# Shared demo DNS

The `demo-dns` Spacelift stack owns the public Route 53 zone
`spacelift.shovel-emporium.com` in demo AWS account `234878555361`.
`admin/dns.tf` manages the stack with the existing demo AWS integration and
EC2 worker pool. Spacelift owns its state.

The parent `shovel-emporium.com` stays registered and hosted in Cloudflare.
Its zone and four delegation NS records are managed in
`TheOutdoorProgrammer/configurations`, in
`cloudflare/dns_shovel_emporium_com.tf`.
Copy this stack's `name_servers` output into those records after initial creation.
Do not replace the parent domain's Cloudflare nameservers.

Application stacks own records below the delegated zone and their certificates.
Mayday uses `mayday.spacelift.shovel-emporium.com` for its authenticated Flow
callback. The shared hosted zone has deletion protection and is independent of
Mayday's application lifecycle.

Validate with `tofu init -backend=false -lockfile=readonly`, `tofu fmt -check`,
and `tofu validate`. Before confirming the first run, verify the plan creates
only this hosted zone. After delegation, query the parent Cloudflare nameserver
and all four Route 53 nameservers to verify the delegation and SOA answers.
