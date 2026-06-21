# Lab 03 -- Resource Management

**AZ-104 Domain:** Manage Azure Identities and Governance (15--20%)

## Overview

This lab teaches the foundational practices of organizing and managing Azure resources with Terraform. You will create multiple resource groups that serve as lifecycle boundaries, apply a consistent tagging strategy, protect critical resources with management locks, and follow Azure naming conventions.

This is the **template lab** -- it establishes every convention (file layout, tagging, naming, variable validation) that subsequent labs follow.

## What You Will Learn

- **Resource groups as lifecycle boundaries** -- grouping resources by function (networking, compute, shared services) so they can be managed, secured, and deleted independently.
- **Tagging strategy** -- applying a consistent set of tags (Project, Lab, Environment, Owner, ManagedBy) to every resource via a `locals` block.
- **Management locks** -- using `CanNotDelete` locks to prevent accidental destruction of critical resource groups.
- **Naming conventions** -- following Azure Cloud Adoption Framework prefixes (`rg-`, `st`, `vnet-`) for clarity and tooling compatibility.
- **The `moved` block concept** -- how Terraform tracks resource renames in state without destroying and recreating resources (included as a commented reference).
- **Globally unique naming** -- using `random_string` to generate storage account names that satisfy Azure's global uniqueness requirement.

## Prerequisites

- An active Azure subscription
- Terraform >= 1.6.0 installed
- Azure CLI authenticated (`az login`)

## Quick Start

```bash
# 1. Initialize Terraform
terraform init

# 2. Create your variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set lab_owner to your name or email

# 3. Preview the deployment
terraform plan

# 4. Deploy
terraform apply
```

## What Gets Deployed

| Resource | Type | Resource Group |
|---|---|---|
| `rg-az104-lab03-networking` | Resource Group | -- |
| `rg-az104-lab03-compute` | Resource Group | -- |
| `rg-az104-lab03-shared` | Resource Group | -- |
| `staz104lab03<random>` | Storage Account (Standard LRS) | shared |
| `vnet-az104-lab03` | Virtual Network (10.0.0.0/16) | networking |
| `lock-shared-nodelete` | Management Lock (CanNotDelete) | shared |

Total: 3 resource groups, 1 storage account, 1 virtual network, 1 management lock.

## Key Concepts

### Resource Groups as Lifecycle Boundaries

Each resource group represents a distinct functional area. This separation lets you apply different RBAC policies, cost tracking, and deletion schedules per group.

### Tagging Strategy

All resources inherit tags from `local.common_tags`. This ensures consistent metadata for cost management, automation, and compliance reporting.

### Management Locks

The `CanNotDelete` lock on the shared resource group prevents accidental deletion through the portal, CLI, or Terraform. This is a safety net for production-critical resources.

### The moved Block

When you rename a Terraform resource (e.g., from `azurerm_virtual_network.old_name` to `azurerm_virtual_network.main`), the `moved` block tells Terraform to update state rather than destroy and recreate the resource. A commented example is included in `main.tf`.

## Cleanup

Because the shared resource group has a management lock, you must remove it before destroying:

```bash
# Option 1: Destroy the lock first, then everything else
terraform destroy -target=azurerm_management_lock.shared_delete_lock
terraform destroy

# Option 2: Destroy everything in one pass (Terraform handles dependency order)
terraform destroy
```

Note: Terraform is usually smart enough to remove the lock before the resource group in a single `terraform destroy`, but if you encounter errors, use the two-step approach above.

## Estimated Cost and Time

- **Cost:** Approximately $0.50/day (storage account with LRS; resource groups and VNets are free).
- **Deploy time:** Approximately 3 minutes.
