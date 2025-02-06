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
  cidr_block              = var.public_subnet_cidr
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

# Security Group for PostgreSQL Server
resource "aws_security_group" "postgres-sg" {
  vpc_id = aws_vpc.database-vpc.id

  # Allow SSH from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # Allow PostgreSQL traffic from your IP
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # Allow HTTP/HTTPS for NGINX reverse proxy
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-sg"
  }
}

# EC2 Instance for PostgreSQL
resource "aws_instance" "postgres_ec2" {
  ami                    = var.ami_id
  user_data              = file("${path.module}/app-install.sh")
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.database-vpc-public-subnet.id
  vpc_security_group_ids = [aws_security_group.postgres-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = var.key_name

  tags = {
    Name = "PostgreSQL-Server"
  }
}

# Store DB Credentials in AWS SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name  = "/myapp/db_password"
  type  = "SecureString"
  value = var.db_password
}