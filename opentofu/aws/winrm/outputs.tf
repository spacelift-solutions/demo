output "private_ip" {
    description = "The private IP of the Windows instance."
    value       = aws_instance.windows_server.private_ip
}