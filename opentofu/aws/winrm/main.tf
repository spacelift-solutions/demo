resource "aws_security_group" "this" {
  name        = "win2019"
  description = "Used in the terraform"
  vpc_id      = "vpc-024d5a8db42fd8456"

  ingress {
    description = "WinRM Access"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "windows_server" {
  ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = "subnet-03d1fb0274894b1da"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 35
    iops                  = 0
    delete_on_termination = true
  }

  tags = {
    Name = "Windows Server WinRM Example"
  }

  user_data = data.template_file.windows-userdata.rendered
}