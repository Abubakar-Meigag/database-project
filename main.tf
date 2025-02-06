# VPC
resource "aws_vpc" "database-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "database-vpc"
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "database-vpc-igw" {
  vpc_id = aws_vpc.database-vpc.id

  tags = {
    Name = "database-vpc-igw"
  }
}

# Public Subnet
resource "aws_subnet" "database-vpc-public-subnet" {
  vpc_id                  = aws_vpc.database-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "database-vpc-public-subnet"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "database-vpc-public-route-table" {
  vpc_id = aws_vpc.database-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.database-vpc-igw.id
  }

  tags = {
    Name = "database-vpc-public-route-table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "database-vpc-public-subnet-association" {
  subnet_id      = aws_subnet.database-vpc-public-subnet.id
  route_table_id = aws_route_table.database-vpc-public-route-table.id
}

# Private Subnet
resource "aws_subnet" "database-vpc-private-subnet" {
  vpc_id                  = aws_vpc.database-vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "database-vpc-private-subnet"
  }
}

# Security Group for EC2 Instance
resource "aws_security_group" "database-vpc-ec2-sg" {
  vpc_id = aws_vpc.database-vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]  # Corrected
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-vpc-ec2-sg"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.database-vpc.id

  # Allow SSH from your laptop only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]  # Only allow your laptop's public IP
  }

  # Allow all outbound traffic (for SSH forwarding)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# EC2 Instance for PostgreSQL
resource "aws_instance" "postgres_ec2" {
  ami                    = var.ami_id
  user_data              = file("${path.module}/app-install.sh")
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.database-vpc-private-subnet.id
  vpc_security_group_ids = [aws_security_group.database-vpc-ec2-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = var.key_name

  tags = {
    Name = "PostgreSQL-Server"
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.database-vpc-public-subnet.id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = var.key_name

  tags = {
    Name = "Bastion-Host"
  }
}

# Store DB Credentials in AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name  = "/myapp/db_password"
  type  = "SecureString"
  value = var.db_password
}