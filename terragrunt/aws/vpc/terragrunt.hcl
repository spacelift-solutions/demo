include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../modules/vpc"
}

inputs = {
  aws_region     = include.root.locals.aws_region
  vpc_name       = "terragrunt-demo"
  vpc_cidr       = "10.60.0.0/16"
  public_subnets = ["10.60.1.0/24"]
}
