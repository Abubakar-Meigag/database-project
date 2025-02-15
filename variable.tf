variable "aws_region" {
  description = "Region in which AWS Resources will be created"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
  default     = "ami-091f18e98bc129c4e"
}

variable "db_password" {
  description = "Database password for PostgreSQL stored securely in AWS SSM Parameter Store"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "SSH Key Pair Name for EC2 Instance"
  type        = string
}

variable "allowed_ip" {
  description = "Allowed IP address for SSH access (e.g., your home IP)"
  type        = string
}