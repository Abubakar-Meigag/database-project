# VPC and Subnet
resource "aws_vpc" "my_data_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_data_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = false
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_data_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip] # Allow SSH access only from your IP
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for PostgreSQL
resource "aws_instance" "postgres_ec2" {
  ami                    = data.aws_ami.amzlinux2.id
  user_data              = file("${path.module}/app-install.sh")
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
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
