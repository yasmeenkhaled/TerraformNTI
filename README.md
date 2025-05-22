# TerraformProject

## This project implements a multi-tier AWS infrastructure with the following components:

- VPC with public and private subnets across two availability zones
- Load balancers for traffic distribution
- Proxy servers in public subnets
- Backend web servers in private subnets
- Security groups for access control
- Remote state management with S3 and DynamoDB


## Main Arch
![WhatsApp Image 2025-05-19 at 12 22 39 PM](https://github.com/user-attachments/assets/a8df3bd4-364c-4f8f-9e1a-cd7499fc9d34) 

## OutPut :

## With Server 1

![image](https://github.com/user-attachments/assets/40053613-9ea1-4dd9-87f9-785137c20f5a)

## With server 2
![image](https://github.com/user-attachments/assets/68ab6c0d-eec7-427d-a37f-5e121f8a5ed8)




## 🛠️ Deployment Steps

1. **Install Terraform:**
   - Download from the [official Terraform website](https://www.terraform.io/downloads.html).

2. **Configure AWS Credentials:**
   - Setup AWS CLI credentials on your machine (`aws configure`).

3. **Review and modify variables**
   - in `variables.tf` or create a `terraform.tfvars` file.

4. **Initialize Terraform:**
   - Run `terraform init` to initialize the project.

5. **Plan the Deployment:**
   - Execute `terraform plan` to preview the infrastructure changes.
     
6. **Apply the Deployment:**
   - Run `terraform apply` to create the infrastructure on AWS.





