output "bastion_public_ip" {
  description = "Elastic IP of the Bastion Host"
  value       = module.app.bastion_public_ip
  
}

output "web_node_private_ips" {
  description = "Private IPs of the Web Nodes"
  value       = module.app.web_node_private_ips  
}

output "db_node_private_ips" {
  description = "Private IPs of the DB Nodes"
  value       = module.app.db_node_private_ips  
}

output "bastion_sg_id" {
  description = "Security Group ID of the Bastion Host"
  value       = module.app.bastion_sg_id
}
