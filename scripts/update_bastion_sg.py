import boto3
import requests
import json

region = "us-east-1"  # Update only if your region changes

def update_bastion_sg():
    # Load Terraform outputs
    with open('terraform/outputs.json') as f:
        data = json.load(f)

    # Read bastion SG ID dynamically
    sg_id = data['bastion_sg_id']['value']

    ec2 = boto3.client('ec2', region_name=region)
    my_ip = requests.get('https://checkip.amazonaws.com').text.strip() + "/32"

    # Check existing rules
    existing_rules = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]['IpPermissions']

    # Remove any old SSH rule
    for perm in existing_rules:
        if perm.get('FromPort') == 22 and perm.get('ToPort') == 22:
            for ip_range in perm.get('IpRanges', []):
                ec2.revoke_security_group_ingress(
                    GroupId=sg_id,
                    IpProtocol='tcp',
                    FromPort=22,
                    ToPort=22,
                    CidrIp=ip_range['CidrIp']
                )

    # Add new SSH rule
    ec2.authorize_security_group_ingress(
        GroupId=sg_id,
        IpProtocol='tcp',
        FromPort=22,
        ToPort=22,
        CidrIp=my_ip
    )

    print(f"✅ Bastion SG ({sg_id}) updated to allow SSH from {my_ip}")


if __name__ == "__main__":
    update_bastion_sg()
