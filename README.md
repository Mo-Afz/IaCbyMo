# IaCbyMo: Master Azure Administration Through Infrastructure as Code

A complete, hands-on lab collection covering every skill tested on the AZ-104 Azure Administrator certification -- built entirely in Terraform so every piece of infrastructure is version-controlled, repeatable, and reviewable.

## What This Is

14 self-contained Terraform labs that walk through the full AZ-104 curriculum: identity, governance, networking, compute, storage, backup, and monitoring. Each lab builds on the last, each one teaches a specific Azure domain, and each one deploys real infrastructure you can inspect, test, and tear down.

This project grew out of [the original IaCbyMo repo](./STUDY_PLAN.md) -- a modular Terraform project that had good intentions but real problems: duplicated code blocks, a committed SSH private key, NSG rules open to the entire internet, and a governance policy that silently did nothing. The study plan documents every issue and what we learned. These labs apply those lessons.

## The Labs

| Lab | Domain | What You Build | Cost/Day |
|-----|--------|---------------|----------|
| [01 - Identity](labs/lab01-identity/) | Identities & Governance | Entra ID users, security groups, group memberships | $0 |
| [02a - RBAC](labs/lab02a-rbac/) | Identities & Governance | Role assignments (Contributor, Reader), custom role definitions | $0 |
| [02b - Policy](labs/lab02b-policy/) | Identities & Governance | Custom policies, initiatives, assignments (fixes the original tag bug) | $0 |
| [03 - Resource Management](labs/lab03-resource-management/) | Identities & Governance | Resource groups, tags, locks, naming conventions (the template lab) | ~$0.50 |
| [04 - Virtual Networking](labs/lab04-virtual-networking/) | Virtual Networking | VNet, subnets, NSGs, private DNS, NIC | ~$0.50 |
| [05 - Intersite Connectivity](labs/lab05-intersite-connectivity/) | Virtual Networking | Hub-spoke topology, VNet peering, optional VPN Gateway | ~$1.50 |
| [06 - Traffic Management](labs/lab06-traffic-management/) | Virtual Networking | Load Balancer (L4), Application Gateway (L7), Traffic Manager (DNS) | ~$4.00 |
| [07 - Storage](labs/lab07-storage/) | Storage | Blob containers, Azure Files, lifecycle policies, SAS tokens | ~$0.50 |
| [08 - Virtual Machines](labs/lab08-virtual-machines/) | Compute | Linux VM (SSH), Windows VM (password), availability sets, data disks, extensions | ~$2.50 |
| [09a - Web Apps](labs/lab09a-web-apps/) | Compute | App Service plan, web app, deployment slots, managed identity | ~$1.50 |
| [09b - Container Instances](labs/lab09b-container-instances/) | Compute | Container groups, env vars (secure), Azure Files volume mount | ~$1.20 |
| [09c - Container Apps](labs/lab09c-container-apps/) | Compute | Container Apps environment, scale-to-zero, HTTP auto-scaling | ~$0.50 |
| [10 - Data Protection](labs/lab10-data-protection/) | Monitor & Maintain | Recovery Services Vault, backup policies, VM backup registration | ~$1.50 |
| [11 - Monitoring](labs/lab11-monitoring/) | Monitor & Maintain | Log Analytics, diagnostic settings, metric alerts, activity log alerts | ~$2.00 |

## Prerequisites

- An Azure subscription (free tier works for most labs)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- Azure CLI, authenticated (`az login`)
- An SSH keypair for labs that deploy VMs

## Quick Start

```bash
# Pick a lab
cd labs/lab03-resource-management

# Configure your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy
terraform init
terraform plan
terraform apply

# When done
terraform destroy
```

## Design Decisions

**Each lab is independent.** No shared state, no remote backends, no cross-lab dependencies. You can deploy Lab 11 without ever touching Lab 01. This is intentional -- labs that depend on each other create ordering headaches and make cleanup fragile.

**No default for SSH CIDRs.** Any lab that opens an SSH port requires you to explicitly set `allowed_ssh_cidr`. There is no `"*"` default. This forces a conscious security decision every time.

**Consistent tagging everywhere.** Every resource carries `local.common_tags` with Project, Lab, Environment, Owner, and ManagedBy. These tags enable the policy enforcement from Lab 02b and make cost tracking possible.

**Azure CAF naming conventions.** Resources follow Microsoft's Cloud Adoption Framework abbreviations: `rg-` for resource groups, `vnet-` for VNets, `snet-` for subnets, `vm-` for VMs, `pip-` for public IPs, `nsg-` for NSGs, `st` for storage accounts.

## What Changed From the Original

The [STUDY_PLAN.md](./STUDY_PLAN.md) documents every issue found in the original IaCbyMo project. The key fixes applied across all labs:

1. **No duplicated code** -- every file validates cleanly
2. **No committed secrets** -- SSH keys are variables, passwords are `sensitive = true`, `.gitignore` covers private keys
3. **No open SSH** -- `allowed_ssh_cidr` has no default; you must choose who gets access
4. **Working governance policies** -- tag policies check `tags['Environment']` (specific keys), not `tags` (always exists)
5. **Validated examples** -- every lab runs `terraform validate` in CI

## CI/CD

GitHub Actions runs `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate` on every lab for each push and PR. See [`.github/workflows/validate.yml`](.github/workflows/validate.yml).

## Original Project

The original modular project (networking, compute, governance modules) remains in the root directory for reference. The `STUDY_PLAN.md` walks through every issue and what each one teaches. The `labs/` directory is the corrected, expanded replacement.
