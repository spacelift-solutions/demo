# Terragrunt AWS run-all example

Minimal Terragrunt example with two units, run together via `terragrunt run-all`:

- `vpc` — a VPC with a single public subnet (`terraform-aws-modules/vpc/aws`)
- `ec2-instance` — a `t3.micro` instance launched into that subnet, wired to `vpc` via a Terragrunt `dependency` block

`terragrunt.hcl` at the root of this directory generates the AWS provider block for both units. Local module code lives under `modules/`.

Orchestrated by the "terragrunt-aws-demo" Spacelift stack (`admin/stacks_terragrunt_aws.tf`), which runs this directory with `use_run_all = true`.
