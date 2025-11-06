import json
import os

# Load Terraform outputs
with open('terraform/envs/outputs.json') as f:
    data = json.load(f)

bastion_ip = data['bastion_public_ip']['value']
web_ip = data['web_node_private_ips']['value'][0]  # Assuming one web node
db_ip = data['db_node_private_ips']['value'][0]    # Assuming one db node

config_path = os.path.expanduser('~/.ssh/config')
key_path = os.path.expanduser('~/.ssh/SlaveNode.pem')

os.makedirs(os.path.dirname(config_path), exist_ok=True)

with open(config_path, 'w') as f:
    f.write(f"""Host bastion
    HostName {bastion_ip}
    User ubuntu
    IdentityFile {key_path}
""")

    f.write(f"""
Host web
    HostName {web_ip}
    User ubuntu
    ProxyJump bastion
    IdentityFile {key_path}
""")

    f.write(f"""
Host db
    HostName {db_ip}
    User ubuntu
    ProxyJump bastion
    IdentityFile {key_path}
""")

print("✅ SSH config file updated successfully!")