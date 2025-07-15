<<<<<<< HEAD
# Terraform Azure Landing Zone by IaCbyMo

This project sets up a scalable and secure landing zone on Azure using Terraform modules, including:

- Virtual Network with Subnets
- Network Security Groups (NSGs)
- Azure Policy definitions and assignments
- Virtual Machine Scale Set (VMSS) cluster

## Features

- Modular structure
- Environment-based configurations (via `.tfvars`)
- Repeatable infrastructure provisioning
- IAM and governance baked in

## How to Use

1. Update `terraform.tfvars` for your environment (dev, staging, prod)
2. Run:

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
=======
# IaCbyMo
Modular Azure Landing Zone with Governance &amp; Scale using Terraform
>>>>>>> 21c859e10329c76798c50184adf8f13167a03096
