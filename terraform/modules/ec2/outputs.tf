output "bastion_public_ip" {
  description = "Elastic IP of the Bastion Host"
  value       = aws_eip.bastion_host_eip.public_ip
}

output "web_node_private_ips" {
  description = "Public IPs of the Web Nodes"
  value       = aws_instance.web[*].private_ip
}

output "db_node_private_ips" {
  description = "Private IPs of the DB Nodes"
  value       = aws_instance.db[*].private_ip
}

output "bastion_sg_id" {
  description = "Security Group ID of the Bastion Host"
  value       = aws_security_group.bastion_host_sg.id
}