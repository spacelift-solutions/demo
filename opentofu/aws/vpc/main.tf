resource "aws_vpc" "tofu_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tofu"
  }

}

resource "aws_subnet" "tofu_public_subnet" {
  vpc_id                  = aws_vpc.tofu_vpc.id
  cidr_block              = "10.0.0.0/16"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "tofu-public-subnet"
  }
}

resource "aws_security_group" "allow_access" {
  name        = "tofu-sg"
  description = "Allow SSH, HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.tofu_vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tofu-sg"
  }
}

resource "aws_internet_gateway" "tofu_internet_gateway" {
  vpc_id = aws_vpc.tofu_vpc.id

  tags = {
    Name = "tofu_igw"
  }
}

resource "aws_route_table" "tofu_public_rt" {
  vpc_id = aws_vpc.tofu_vpc.id

  tags = {
    Name = "tofu_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.tofu_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tofu_internet_gateway.id
}

resource "aws_route_table_association" "tofu_public_assoc" {
  subnet_id      = aws_subnet.tofu_public_subnet.id
  route_table_id = aws_route_table.tofu_public_rt.id
}
