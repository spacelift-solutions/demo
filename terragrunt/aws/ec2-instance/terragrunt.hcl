include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                    = "vpc-00000000000000000"
    public_subnet_ids         = ["subnet-00000000000000000"]
    default_security_group_id = "sg-00000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "../modules/ec2-instance"
}

inputs = {
  aws_region    = include.root.locals.aws_region
  vpc_id        = dependency.vpc.outputs.vpc_id
  subnet_id     = dependency.vpc.outputs.public_subnet_ids[0]
  instance_name = "terragrunt-demo"
  instance_type = "t3.micro"
}
