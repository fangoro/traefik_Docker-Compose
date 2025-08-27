# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get latest Debian AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian official

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create security group
resource "aws_security_group" "traefik" {
  name_prefix = "traefik-sg"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Traefik dashboard
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "traefik-security-group"
  }
}

# Create Elastic IP
resource "aws_eip" "traefik" {
  domain = "vpc"
  
  tags = {
    Name = "traefik-server-ip"
  }
}

# Create EC2 instance
resource "aws_instance" "traefik" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.traefik.id]
  subnet_id             = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "traefik-server"
  }
}

# Associate Elastic IP with instance
resource "aws_eip_association" "traefik" {
  instance_id   = aws_instance.traefik.id
  allocation_id = aws_eip.traefik.id
}