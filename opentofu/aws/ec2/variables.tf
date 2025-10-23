variable "instance_type" {
  type    = string
  default = "t2.2xlarge"
}

variable "aws_security_group_id" {
  type    = string
  default = ""
}

variable "public_key" {
  type    = string
  default = "/mnt/workspace/id_rsa.pub"
}

variable "subnet_id" {
  type = string
}
