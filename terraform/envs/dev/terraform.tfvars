# envs/dev/terraform.tfvars
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24"]
private_subnets = ["10.0.2.0/24"]
azs             = ["us-east-1a"]
env             = "dev"
ami             = "ami-0bbdd8c17ed981ef9"
key_name        = "SlaveNode"
instance_count_app  = 1
instance_count_db = 1

