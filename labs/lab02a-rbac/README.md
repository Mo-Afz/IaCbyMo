# Lab 02a -- RBAC

AZ-104 Domain: Manage Azure Identities and Governance (15-20%)

## What This Lab Teaches

- Assigning built-in Azure roles (Contributor, Reader) at the resource group scope
- Creating a custom role definition with explicit `actions` and `not_actions`
- Using `assignable_scopes` to control where a custom role can be assigned
- Understanding scope inheritance: assignments at a resource group apply to all resources within it

Key exam concept: **Owner vs Contributor**. Both can manage Azure resources, but only Owner can grant access to other users via role assignments. Contributor cannot modify role assignments or role definitions.

## Connection to Lab 01

Lab 01 (Identity) creates Entra ID groups and outputs their `group_object_ids`. Use those object IDs as the `contributor_principal_id`, `reader_principal_id`, and `support_principal_id` inputs for this lab.

## Prerequisites

- Terraform >= 1.6.0
- Azure CLI authenticated (`az login`)
- Sufficient permissions to create role assignments (Owner or User Access Administrator on the target subscription)
- Object IDs of the users or groups to assign roles to (from Lab 01 outputs or the Azure portal)

## Quick Start

```bash
cd labs/lab02a-rbac
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your principal IDs and owner info
terraform init
terraform plan
terraform apply
```

## What Gets Deployed

| Resource | Description |
|---|---|
| Resource group | `rg-az104-lab02a` in the configured region |
| Contributor role assignment | Grants the Contributor built-in role to one principal on the resource group |
| Reader role assignment | Grants the Reader built-in role to one principal on the resource group |
| Custom role definition | `az104-support-request-contributor` -- can read resources and manage support tickets, but cannot modify or delete resource groups |
| Custom role assignment | Assigns the custom role to one principal on the resource group |

## Clean Up

```bash
terraform destroy
```

## Cost

$0 -- role assignments and role definitions are free Azure control-plane resources.

## Time

Approximately 2 minutes to deploy.
