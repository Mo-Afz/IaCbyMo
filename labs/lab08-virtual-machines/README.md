# Lab 08 -- Virtual Machines

**AZ-104 Domain:** Deploy and Manage Azure Compute Resources (20--25%)

## What This Lab Teaches

- **Linux VM** -- SSH key authentication, custom script extensions (nginx install), attaching data disks
- **Windows VM** -- Password-based authentication, RDP access via NSG rules, the 15-character computer name limit (this lab uses `vm-win-01`, 10 characters, well under the limit)
- **Availability Sets** -- Fault domains (protect against hardware failure) vs. update domains (protect against planned maintenance); this lab configures 2 fault domains and 5 update domains
- **VM Extensions** -- Post-deployment configuration using the Azure CustomScript extension to install and start nginx automatically

## Key Concepts

| Concept | Description |
|---|---|
| Managed Disks | Azure-managed storage for OS and data disks; no storage account management required |
| Availability Sets | Group VMs across fault domains and update domains within a single datacenter |
| Availability Zones | Physically separate locations within a region (not used in this lab, but a key comparison point) |
| Custom Script Extensions | Run scripts on VMs after deployment for automated configuration |
| NSG Rules | Control inbound/outbound traffic per NIC -- this lab allows SSH (22), HTTP (80), and RDP (3389) |

## Prerequisites

- An Azure subscription
- Terraform >= 1.6.0
- An SSH key pair (`ssh-keygen -t rsa -b 4096`)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```

## Cost Estimate

Approximately **$2.50/day** running two Standard_B2s VMs. Deployment time is roughly **8 minutes**.
