# Lab 04 -- Virtual Networking

**AZ-104 Domain:** Implement and Manage Virtual Networking (15--20% of the exam)

## What You Will Learn

This lab builds the foundational Azure networking layer from scratch, covering:

- **Virtual Networks (VNets)** -- creating a VNet with a /16 address space (65,536 addresses)
- **Subnets (tiered segmentation)** -- carving the VNet into app, database, and management tiers, each with its own /24 block
- **Network Security Groups (NSGs)** -- writing priority-based inbound rules (HTTP/HTTPS for app, SSH for management)
- **NSG-to-subnet associations** -- binding NSGs to specific subnets so rules apply to all NICs within them
- **Public IPs** -- allocating a Standard-SKU static public IP for management access
- **Network Interfaces (NICs)** -- placing a NIC in the management subnet with both private and public IP configurations
- **Private DNS zones** -- creating an internal DNS zone (`az104lab.internal`) and linking it to the VNet with auto-registration enabled

## Security Highlight

The `allowed_ssh_cidr` variable has **no default value**. This is intentional -- it forces you to make a conscious decision about which IP address or CIDR range can reach the management subnet over SSH. This fixes the `source_address_prefix = "*"` anti-pattern found in the original IaCbyMo project, where SSH was open to the entire internet.

## Prerequisites

- Terraform >= 1.6.0
- Azure CLI authenticated (`az login`)
- An active Azure subscription

## Quick Start

```bash
cd labs/lab04-virtual-networking

# Copy the example variables file and fill in your values
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars -- set lab_owner and allowed_ssh_cidr

terraform init
terraform plan
terraform apply
```

## What Gets Deployed

| Resource                       | Name                 | Purpose                                  |
|--------------------------------|----------------------|------------------------------------------|
| Resource Group                 | rg-az104-lab04       | Container for all lab resources           |
| Virtual Network                | vnet-az104-lab04     | /16 address space (10.0.0.0/16)          |
| Subnet (app)                   | snet-app             | Application tier (10.0.1.0/24)           |
| Subnet (db)                    | snet-db              | Database tier (10.0.2.0/24)              |
| Subnet (mgmt)                  | snet-mgmt            | Management tier (10.0.3.0/24)            |
| NSG (app)                      | nsg-app              | Allows HTTP (80) and HTTPS (443) inbound |
| NSG (mgmt)                     | nsg-mgmt             | Allows SSH (22) from allowed_ssh_cidr    |
| NSG associations               | --                   | Binds NSGs to app and mgmt subnets       |
| Public IP                      | pip-mgmt-lab04       | Static Standard-SKU IP for management    |
| NIC                            | nic-mgmt-lab04       | Management NIC with public + private IP  |
| Private DNS Zone               | az104lab.internal    | Internal name resolution                 |
| Private DNS Zone VNet Link     | link-vnet-lab04      | Links DNS zone to VNet, auto-registers   |

## Cost

Approximately **$0.50/day**. The primary cost drivers are the Standard public IP and the private DNS zone. Destroy resources when not in use:

```bash
terraform destroy
```

## Time to Deploy

Approximately **5 minutes**.

## Clean Up

```bash
terraform destroy
```
