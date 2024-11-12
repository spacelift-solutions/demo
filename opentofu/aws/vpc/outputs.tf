output "subnet_id" {
  description = "ID of the Subnet"
  value       = aws_subnet.dev_public_subnet.id
}

output "dev_sg" {
  value = aws_security_group.allow_access.id
}