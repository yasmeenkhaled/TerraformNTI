# Global Variables
region       = "us-east-1"
project_name = "terraform-aws-lab"
environment  = "dev"

# VPC Variables
vpc_cidr = "10.0.0.0/16"

# Subnet Variables
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.3.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# EC2 Variables
proxy_instance_type   = "t2.micro"
backend_instance_type = "t2.micro"
proxy_ami             = "ami-0953476d60561c955"
backend_ami           = "ami-0953476d60561c955"
key_name              = "terraform-aws-lab-key"
private_key_path      = "/home/jess/Downloads/terraform-aws-lab-last/terraform-aws-lab-key.pem"

# Remote Backend Variables
backend_s3_bucket     = "terraform-aws-lab.stateaws"
backend_dynamodb_table = "terraform-aws-lab-locks"

# Security Group Variables
proxy_ingress_ports   = [22, 80, 443]
backend_ingress_ports = [22, 80]

# Tags
tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "terraform-aws-lab"
  Owner       = "DevOps"
}
