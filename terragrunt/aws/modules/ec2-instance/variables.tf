variable "aws_region" {
  description = "AWS region"
}

variable "vpc_id" {
  description = "VPC ID the instance's security group belongs to"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
}

variable "instance_name" {
  description = "Name tag for the instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}
