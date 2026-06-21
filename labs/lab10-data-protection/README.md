# Lab 10 -- Data Protection

**AZ-104 Domain:** Monitor and Maintain Azure Resources (10--15%)

## What This Lab Teaches

- Creating a **Recovery Services Vault** and choosing storage replication (LRS vs GRS)
- Defining **backup policies** with schedule and retention settings
- **Registering a VM** for backup protection
- Understanding **soft delete** -- disabled here for easy lab cleanup, but never disable it in production

## Key Concepts

| Concept | Description |
|---|---|
| Recovery Services Vault | Central management point for backup and site recovery; stores backup data and configuration |
| LRS vs GRS | Locally Redundant Storage keeps 3 copies in one datacenter; Geo-Redundant Storage replicates to a paired region. LRS is cheaper and sufficient for non-critical/lab workloads |
| Backup Policy | Defines backup frequency (daily/weekly) and retention duration. This lab uses daily backups with 7-day retention |
| Backup Protected VM | The Terraform resource that registers a VM with a vault and associates it with a backup policy |
| Soft Delete | Retains deleted backup data for 14 additional days. Enabled by default in production to guard against accidental or malicious deletion |

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

## Testing a Backup

After deployment, trigger an immediate backup to verify the configuration:

```bash
az backup protection backup-now \
  --resource-group rg-az104-lab10 \
  --vault-name rsv-az104-lab10 \
  --container-name "IaasVMContainer;iaasvmcontainerv2;rg-az104-lab10;vm-backup-01" \
  --item-name "VM;iaasvmcontainerv2;rg-az104-lab10;vm-backup-01" \
  --retain-until $(date -u -d "+30 days" +%d-%m-%Y)
```

## Clean Up

```bash
terraform destroy
```

Note: Because soft delete is disabled in this lab, `terraform destroy` will remove all backup data immediately. In production, soft-deleted items would be retained for 14 days after deletion.

## Cost and Time

- **Cost:** ~$1.50/day (VM + vault instance charges; backup storage is minimal with daily retention)
- **Time:** ~8 minutes to deploy
