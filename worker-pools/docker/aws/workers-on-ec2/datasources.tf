data "aws_subnets" "dev_subnet" {
  tags = {
    Name = "dev-public-subnet"
  }
}

data "aws_security_groups" "dev_sg" {
  tags = {
    Name = "dev_sg"
  }
}
