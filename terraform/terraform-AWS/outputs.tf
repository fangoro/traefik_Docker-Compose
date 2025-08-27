output "instance_id" {
  value = aws_instance.traefik.id
}

output "public_ip_address" {
  value = aws_eip.traefik.public_ip
}

output "ssh_connection_command" {
  value = "ssh ${var.admin_username}@${aws_eip.traefik.public_ip}"
}

output "security_group_id" {
  value = aws_security_group.traefik.id
}