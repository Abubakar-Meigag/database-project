output "ec2_instance_id" {
  value = aws_instance.postgres_ec2.id
}

output "subnet_id" {
  value = aws_subnet.database-vpc-private-subnet.id
}

output "security_group_id" {
  value = aws_security_group.database-vpc-ec2-sg.id
}

output "public_subnet_id" {
  value = aws_subnet.database-vpc-public-subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.database-vpc-igw.id
}