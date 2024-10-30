resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2-key-pair"
  public_key = file(var.public_key)
}

resource "aws_instance" "sd_instance" {
  ami                         = data.aws_ami.dev_server_ami.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnetId
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.aws_security_group_id]

  tags = {
    Name = "dev-node"
  }
}