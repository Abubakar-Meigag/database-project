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

variable "subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
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
  default     = "YOUR_IP/32"
}