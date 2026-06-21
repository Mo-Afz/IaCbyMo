# IaCbyMo Study Plan: What Went Wrong and Why

## What You Were Building

A modular Terraform project to deploy an Azure landing zone with three layers:
- **Networking**: VNet, subnet, NSG
- **Compute**: Linux VM Scale Set across availability zones
- **Governance**: Azure Policy definitions and assignments

The architecture idea was solid. The issues were in execution and security awareness.

---

## Lesson 1: The Duplication Bug (Every File)

### What you thought was happening
You had a working Terraform project with modules wired together.

### What was actually happening
**Every single `.tf` file** had its entire content pasted twice. Terraform treats each
file as a flat list of blocks — when it sees `variable "location"` declared twice in
`variables.tf`, or `resource "azurerm_resource_group" "main"` twice in `main.tf`, it
fails immediately:

```
Error: Duplicate resource "azurerm_resource_group" "main" configuration
```

This means **none of your code ever ran**. `terraform init` might succeed (it just
downloads providers), but `terraform validate` or `terraform plan` would fail on
every file.

### How this probably happened
- Copy-pasting file contents in the GitHub web editor and accidentally appending
  instead of replacing
- A bad merge/rebase that concatenated both sides
- Editing in an IDE with a "paste" that went to the end of the file unnoticed

### The takeaway
- Always run `terraform validate` locally before committing
- Use `terraform fmt` — it won't catch duplicates, but it enforces consistent
  formatting so visual inspection is easier
- Set up a CI pipeline (GitHub Actions) that runs `terraform fmt -check` and
  `terraform validate` on every PR — that catches this instantly
- Consider using pre-commit hooks: https://github.com/antonbabenko/pre-commit-terraform

### Study topics
- How Terraform parses `.tf` files (all files in a directory are merged into one config)
- `terraform validate` vs `terraform plan` — what each checks
- Pre-commit hooks for Terraform

---

## Lesson 2: SSH Private Key Committed to the Repo

### What you thought was happening
You probably created an SSH keypair (`ssh-keygen`) and got two files:
- `pub` — you might have thought this was the public key (the name suggests it)
- `pub.pub` — maybe you thought this was a backup or duplicate

### What was actually happening
- `pub` was your **private key** (the secret half)
- `pub.pub` was the **public key** (the safe-to-share half)

When you run `ssh-keygen -f pub`, it creates:
- `pub` — private key (NEVER share this)
- `pub.pub` — public key (safe to share, put on servers)

By committing `pub` to a public GitHub repo, you gave **anyone on the internet** your
private key. They could use it to SSH into any server where `pub.pub` was authorized.

### Why this is critical (CVE-level serious)
- **Even after deleting the file**, it remains in git history forever
- Bots actively scan GitHub for committed secrets (private keys, API tokens, passwords)
- Within minutes of pushing, automated scanners may have already harvested the key
- GitHub even has "secret scanning" that should have flagged this

### The vulnerability chain
```
Private key in repo
    → Attacker clones repo
    → Attacker has your SSH private key
    → Attacker can SSH into any VM where this key is authorized
    → Full server compromise (data theft, lateral movement, ransomware)
```

### What you should do RIGHT NOW
1. **Rotate the key**: Generate a brand new keypair, replace the public key on
   any server/VM that had the old one authorized
2. **Scrub git history**: Use `git filter-repo` or BFG Repo Cleaner to remove
   the key from all historical commits
3. **Force-push** the cleaned history
4. **Assume the key is compromised** — even if the repo was private, treat it as leaked

### Best practices going forward
- **Never commit secrets to git** — no private keys, passwords, API tokens, .env files
- Name private keys clearly: `id_rsa`, `mykey`, `vmss_key` (not `pub`)
- Add private key patterns to `.gitignore` BEFORE generating keys:
  ```
  *.pem
  id_rsa
  id_ed25519
  ```
- Use Azure Key Vault to store secrets, reference them via `data "azurerm_key_vault_secret"`
- Use `ssh_public_key = file("~/.ssh/id_rsa.pub")` — read the public key from a
  local path that's never committed
- Use tools like `git-secrets`, `gitleaks`, or `trufflehog` to scan for secrets pre-commit

### Study topics
- How SSH key authentication works (public key cryptography)
- GitHub secret scanning
- `git filter-repo` for history rewriting
- Azure Key Vault for secret management in Terraform
- Pre-commit secret scanners (gitleaks, trufflehog)

---

## Lesson 3: NSG Rule — SSH Open to the Entire Internet

### What you thought was happening
You created an NSG rule to allow SSH access to your VMs — standard practice for
administration.

### What was actually happening
```hcl
source_address_prefix = "*"   # <-- This means ANY IP address on earth
```

This rule says: "Allow TCP port 22 from **every IP address on the internet** to
**every resource** in this subnet." That's ~4.3 billion potential source addresses.

### The vulnerability
```
NSG allows SSH from 0.0.0.0/0 (the whole internet)
    → Bots discover port 22 is open (they scan constantly)
    → Brute-force attacks begin within minutes
    → If password auth is on, or a weak key is used: full compromise
    → Even with key-only auth, you're exposing attack surface unnecessarily
```

Port 22 scanners are **relentless**. A newly opened SSH port gets probed within
5-15 minutes of going live. Even with key-only auth, you're exposed to:
- Zero-day SSH vulnerabilities
- Key theft (like Lesson 2 above)
- Denial-of-service on the SSH daemon

### What you should do instead
**Option A: Restrict to your IP** (simplest)
```hcl
source_address_prefix = "203.0.113.50/32"  # Your office/home IP only
```

**Option B: Use Azure Bastion** (best practice)
- No public SSH at all
- Connect through Azure portal or native SSH client via Bastion
- All access is logged and auditable
- No NSG rule for port 22 needed

**Option C: Use a VPN Gateway**
- SSH only from within the Azure VNet
- Connect via Site-to-Site VPN or Point-to-Site VPN first

### What we fixed
We parameterized it so the CIDR is a variable:
```hcl
source_address_prefix = var.allowed_ssh_cidr
```
The default is still `"*"` (so existing deployments don't break), but the variable
description warns against it, and users can override it in their `.tfvars`.

### Study topics
- NSG rules: priority, direction, source/destination filtering
- Azure Bastion as a replacement for public SSH
- Defense in depth: why "key-only SSH" isn't enough
- How internet-wide port scanning works (Shodan, Masscan, ZMap)

---

## Lesson 4: `depends_on = [var.subnet_id]` — Invalid Dependency

### What you thought was happening
You added a `depends_on` to the VMSS to make sure the subnet existed before the
VM Scale Set was created.

### What was actually happening
`depends_on` expects a **resource reference**, not a variable. `var.subnet_id` is
a string variable — Terraform doesn't know what resource it came from.

```hcl
# WRONG — var.subnet_id is just a string, not a resource
depends_on = [var.subnet_id]

# RIGHT — Terraform already handles this automatically
# Because subnet_id is passed to the NIC's ip_configuration,
# Terraform builds an implicit dependency graph. No depends_on needed.
```

### The takeaway
Terraform automatically tracks dependencies through references. When you write:
```hcl
subnet_id = var.subnet_id  # which comes from module.networking.subnet_id
```
Terraform already knows the VMSS depends on the networking module. Explicit
`depends_on` is only needed when there's a **hidden dependency** that Terraform
can't infer from the configuration (e.g., a policy must exist before a resource
is created, but there's no direct reference between them).

### Study topics
- Terraform dependency graph (`terraform graph` command)
- Implicit vs explicit dependencies
- When `depends_on` is actually needed (rare cases)

---

## Lesson 5: The Example File That Never Worked

### What you thought was happening
`examples/sample-vmss.tf` showed how to use your modules.

### What was actually happening
The example referenced inputs that **don't exist** in the actual modules:

| Example used | Module actually accepts |
|---|---|
| `address_space = ["10.0.0.0/16"]` | Not a variable (hardcoded in module) |
| `subnet_prefixes = [...]` | Not a variable |
| `subnet_names = [...]` | Not a variable |
| `tags = {...}` | Not a variable |
| `vm_size = "Standard_DS2_v2"` | `sku = "..."` |
| `admin_password = var.admin_password` | `ssh_public_key = var.ssh_public_key` |
| `policy_definitions = [...]` | Not a variable |

If anyone tried `terraform plan` with this example, they'd get:
```
Error: Unsupported argument "address_space" for module "networking"
```

### Why this matters
- Examples are often the **first thing** someone reads when evaluating your module
- A broken example destroys trust in the whole project
- It suggests the code was written aspirationally (what you wanted) rather than
  tested against reality (what you built)

### The takeaway
- Always `terraform validate` your examples against the real modules
- Keep examples minimal — show the actual interface, not a wished-for one
- If the example has features the module doesn't support, either add those
  features to the module or remove them from the example

### Study topics
- Terraform module interface design (inputs, outputs, descriptions)
- How to write and test module examples
- `terraform-docs` for auto-generating module documentation

---

## Lesson 6: Governance Policy Bug (Bonus)

### What you wrote
```hcl
policy_rule = jsonencode({
  if = {
    field  = "tags"
    exists = false
  }
  then = {
    effect = "deny"
  }
})
```

### The problem
The Azure Policy engine doesn't evaluate `"tags"` as a top-level field this way for
enforcing required tags. The `exists: false` check on the `"tags"` field tests whether
the tags property itself is missing — but most resources always have a tags property
(it's just empty `{}`). This policy would likely never trigger.

### What a correct "require specific tags" policy looks like
```json
{
  "if": {
    "anyOf": [
      { "field": "tags['Environment']", "exists": "false" },
      { "field": "tags['Owner']", "exists": "false" }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```
This denies resources that are missing specific tags (`Environment`, `Owner`).

### Study topics
- Azure Policy rule structure and evaluation
- Built-in policy definitions vs custom
- Testing policies with `az policy state` commands

---

## Study Roadmap

### Week 1: Terraform Fundamentals
- [ ] Complete the official Terraform tutorials: https://developer.hashicorp.com/terraform/tutorials
- [ ] Understand the plan/apply lifecycle
- [ ] Learn `terraform fmt`, `terraform validate`, `terraform plan`
- [ ] Practice: deploy a simple resource group + storage account to Azure

### Week 2: Terraform Modules
- [ ] Understand module inputs (variables), outputs, and encapsulation
- [ ] Learn implicit vs explicit dependencies (`depends_on`)
- [ ] Practice: refactor Week 1's code into a reusable module
- [ ] Read: https://developer.hashicorp.com/terraform/language/modules/develop

### Week 3: Security in IaC
- [ ] Learn about secret management (Azure Key Vault + Terraform `data` sources)
- [ ] Set up `gitleaks` or `git-secrets` as a pre-commit hook
- [ ] Understand SSH key authentication end-to-end
- [ ] Study NSG best practices and Azure Bastion
- [ ] Read: OWASP Infrastructure as Code Security Cheatsheet

### Week 4: CI/CD and Testing
- [ ] Set up a GitHub Actions workflow that runs `terraform fmt -check` and `terraform validate`
- [ ] Add `pre-commit-terraform` hooks locally
- [ ] Learn about remote state (Azure Storage backend with state locking)
- [ ] Practice: create a working example and validate it in CI

### Week 5: Azure Landing Zone Patterns
- [ ] Study the Azure Cloud Adoption Framework (CAF) landing zone architecture
- [ ] Learn hub-spoke networking topology
- [ ] Understand Azure Policy at scale (management groups, initiatives)
- [ ] Read: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/

---

## Quick Reference: Commands You Should Run Before Every Commit

```bash
# Format all .tf files
terraform fmt -recursive

# Validate configuration
terraform init -backend=false
terraform validate

# Scan for secrets
gitleaks detect --source .

# Check your plan
terraform plan -var-file="terraform.tfvars"
```
