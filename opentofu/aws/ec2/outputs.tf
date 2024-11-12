output "instance_ip" {
  description = "Public IP of the ec2"
  value       = aws_instance.sd_instance.id
}
