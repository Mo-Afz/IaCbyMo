# Lab 01 -- Identity

**AZ-104 Domain:** Manage Azure Identities and Governance (15--20%)

## What This Lab Teaches

- Creating and managing Entra ID (Azure AD) users with Terraform
- Creating security groups and assigning group memberships
- Using the `azuread` provider (distinct from the `azurerm` provider)
- Generating and managing sensitive credentials with the `random` provider

**Important:** This is the ONLY lab in the series that uses the `azuread` provider. All subsequent labs use `azurerm` exclusively and reference the identities created here via their object IDs.

## Prerequisites

- An Azure subscription with Entra ID (Azure Active Directory) access
- Permissions to create users and groups in your Entra ID tenant
- Terraform >= 1.6.0
- Azure CLI (`az login` completed)

## What Gets Deployed

| Resource | Count | Details |
|----------|-------|---------|
| Entra ID Users | 3 | IT Admin, Help Desk Operator, Developer |
| Security Groups | 2 | AZ104-IT-Admins, AZ104-Developers |
| Group Memberships | 3 | IT Admin and Help Desk in IT-Admins group; Developer in Developers group |

## Quick Start

```bash
cd labs/lab01-identity
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set lab_owner to your name or email

terraform init
terraform plan
terraform apply
```

## Key Concepts

- **azuread vs azurerm:** The `azuread` provider manages Entra ID resources (users, groups, applications). The `azurerm` provider manages Azure Resource Manager resources (VMs, storage, networking). They authenticate separately but typically use the same credentials.
- **User Principal Names (UPNs):** Each user gets a UPN in the format `az104-<role>@<your-tenant-domain>`. The tenant domain is discovered automatically via the `azuread_domains` data source.
- **Random Passwords:** The `random_password` resource generates secure 24-character passwords. These are stored in Terraform state (which should be treated as sensitive).
- **Outputs for Downstream Labs:** The `user_object_ids` and `group_object_ids` outputs are consumed by Lab 02a (RBAC) to assign Azure role-based access control.

## Viewing Sensitive Outputs

User passwords are marked as sensitive. To retrieve them after apply:

```bash
terraform output -json user_passwords
```

These passwords are for initial login only. In a production environment, users would reset their password on first sign-in.

## Cost and Time

- **Cost:** $0 (Entra ID user and group creation incurs no charge)
- **Time:** ~2 minutes to deploy

## Cleanup

```bash
terraform destroy
```
