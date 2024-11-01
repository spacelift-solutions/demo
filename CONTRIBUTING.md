# Demo Contribution Guide

## Git

- All commits should be in [Conventional Commit](https://www.conventionalcommits.org) format, so we can generate changelogs easily.
  - PR titles should also be in this format since they are whats used in the commit message when a PR is squashed and merged. 
- All PR's will be squashed and merged into `main` to keep the commit history clean.

1. Create a feature branch off of `main` `git checkout main && git pull origin/main && git branch -b {branch_name}`
2. Make your changes
3. Push your changes to the feature branch `git push origin {branch_name}`
4. Create a pull request against `main` in the repository
5. Request a review from a team member

## OpenTofu Conventions

For the most part, we will follow the [Terraform Best Practices](https://terraform-best-practices.com) conventions. If we differ from these conventions, we will document it here.

### Module/Resource/Local Names

It is recommended to use `this` as stated in [TBP (second point)](https://www.terraform-best-practices.com/naming#resource-and-data-source-arguments).
However, when more descriptive names are required, we will use the following format: `{type}_{cloud_provider}_{service}_{other}`.

Examples:
```hcl
module "stack_aws_ec2_nginx_service" {}
```


### Object Key Names

All object keys should be `SCREAMING_SNAKE_CASE`. For example, when using the [module-stacks](https://github.com/spacelift-solutions/module-stacks) module,
the `dependencies` object requires key names. These key names should be `SCREAMING_SNAKE_CASE`.

```hcl
module "stack_example" {
  dependencies = {
    STACK_2 = {
      dependent_stack_id = module.stack_2.id
    }
    MY_OTHER_AWESOME_DEPENDENCY = {
      dependent_stack_id = module.stack_3.id
    }
  }
}
```