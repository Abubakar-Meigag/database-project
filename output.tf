output "ec2_instance_id" {
  value = aws_instance.postgres_ec2.id
}

output "subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}