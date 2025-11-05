import json
import os

# Load Terraform outputs
with open('terraform/outputs.json') as f:
    data = json.load(f)

# Use the actual keys from your outputs.tf
bastion_ip = data['bastion_public_ip']['value']
web_private_ips = data['web_node_private_ips']['value']
db_private_ips = data['db_node_private_ips']['value']

# Path to SSH config file
config_path = os.path.expanduser('~/.ssh/config')

# Create ~/.ssh if it doesn’t exist
os.makedirs(os.path.dirname(config_path), exist_ok=True)

# Write SSH config dynamically
with open(config_path, 'w') as f:
    f.write(f"""Host bastion
    HostName {bastion_ip}
    User ubuntu
    IdentityFile ~/ansible/keys/SlaveNode.pem
""")

    for i, ip in enumerate(web_private_ips, 1):
        f.write(f"""
Host web{i}
    HostName {ip}
    User ubuntu
    ProxyJump bastion
    IdentityFile ~/ansible/keys/SlaveNode.pem
""")

    for i, ip in enumerate(db_private_ips, 1):
        f.write(f"""
Host db{i}
    HostName {ip}
    User ubuntu
    ProxyJump bastion
    IdentityFile ~/ansible/keys/SlaveNode.pem
""")

print("✅ SSH config file updated successfully!")
