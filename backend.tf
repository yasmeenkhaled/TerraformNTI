terraform {
  backend "s3" {
    bucket         = "terraform-aws-lab.stateaws"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-aws-lab-locks"
    encrypt        = true
  }
}

# Note: The actual backend configuration will be initialized with terraform init -backend-config
# This file serves as a template and variables will be replaced during initialization
