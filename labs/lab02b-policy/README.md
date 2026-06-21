# Lab 02b -- Azure Policy

AZ-104 Domain: Manage Azure Identities and Governance (15-20%)

## What You Will Learn

- How to author custom Azure Policy definitions using Terraform
- The difference between policy effects: Audit (log violations) vs Deny (block them) vs Disabled
- How to bundle multiple policies into a policy initiative (set definition)
- How to assign a policy initiative to a resource group scope
- The correct way to check for individual tag keys in policy rules

### Bug Fix Note

The original IaCbyMo project used `field = "tags"` in its tag policy rule, which does
not work as expected in Azure Policy. Azure Policy cannot evaluate the entire `tags`
object for the presence of specific keys using that syntax. This lab corrects the
approach by checking individual tag keys explicitly (e.g., `tags['Environment']` and
`tags['Owner']`), which is the supported pattern for tag enforcement policies.

## Prerequisites

- Terraform >= 1.6.0
- Azure CLI authenticated (`az login`)
- An active Azure subscription
- Contributor or Owner role on the subscription (required for policy definitions)

## Quick Start

```bash
cd labs/lab02b-policy
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set lab_owner to your name or email
terraform init
terraform plan
terraform apply
```

## What Gets Deployed

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | rg-az104-lab02b | Scoping target for the policy assignment |
| Policy Definition | az104-require-tags | Audits/denies resources missing Environment or Owner tags |
| Policy Definition | az104-allowed-locations | Denies resources deployed outside allowed US regions |
| Policy Set Definition | az104-governance-baseline | Initiative bundling both policies |
| Policy Assignment | az104-governance-assignment | Assigns the initiative to the resource group |

## Key Concepts

**Policy Rule Structure** -- Every policy definition contains a policy rule with an
`if` condition and a `then` block specifying the effect. The `if` block evaluates
resource properties (fields) using conditions like `exists`, `equals`, `in`, `not`,
`anyOf`, and `allOf`.

**Effects** -- `Audit` logs non-compliant resources without blocking them (good for
testing). `Deny` actively prevents non-compliant resource creation or updates. `Disabled`
turns the policy off entirely.

**Initiatives vs Individual Policies** -- An initiative (policy set definition) groups
related policies together for easier assignment and management. Instead of creating
separate assignments for each policy, you assign the initiative once and all member
policies take effect.

**Parameters** -- Policy definitions accept parameters so that the same definition can
be reused with different configurations (e.g., different allowed locations or different
effects) without duplicating the definition.

## Clean Up

```bash
terraform destroy
```

## Cost

$0 -- Azure Policy is a free governance service. No billable resources are created.

## Estimated Time

~3 minutes to deploy and review.
