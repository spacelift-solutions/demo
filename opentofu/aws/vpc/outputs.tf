output "subnet_id" {
  description = "ID of the Subnet"
  value       = aws_subnet.tofu_public_subnet.id
}

output "tofu_sg" {
  value = aws_security_group.allow_access.id
}
