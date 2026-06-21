# Lab 06 -- Traffic Management

**AZ-104 Domain:** Implement and Manage Virtual Networking (15--20%)

## What You Will Learn

This lab deploys three Azure traffic-management tools side by side so you can compare them directly:

- **Azure Load Balancer (Layer 4)** -- distributes TCP/UDP traffic by IP and port. No HTTP awareness.
- **Application Gateway (Layer 7)** -- HTTP-aware load balancer with URL-based routing, cookie affinity, and WAF support.
- **Traffic Manager (DNS layer)** -- DNS-based global traffic routing. Returns an IP via DNS; never touches the data path.

Two nginx backend VMs serve as the shared backend pool for all three.

### Key Exam Topics

- When to use Load Balancer vs Application Gateway vs Traffic Manager.
- How health probes differ at each layer (TCP/HTTP probe on LB, HTTP probe on App Gateway, HTTP/HTTPS/TCP monitor on Traffic Manager).
- Traffic Manager routing methods (this lab uses Priority; the exam also covers Weighted, Performance, and Geographic).
- Application Gateway components: listeners, rules, backend pools, HTTP settings.

## IMPORTANT -- Destroy When Done

Application Gateway costs approximately $4/day even when idle. Run `terraform destroy` as soon as you finish exploring.

## Prerequisites

- Azure CLI authenticated (`az login`)
- Terraform >= 1.6.0
- An SSH key pair

## Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

After apply completes (approximately 12 minutes), test each endpoint:

```bash
# Load Balancer (Layer 4)
curl http://$(terraform output -raw lb_public_ip)

# Application Gateway (Layer 7)
curl http://$(terraform output -raw appgw_public_ip)

# Traffic Manager (DNS)
curl http://$(terraform output -raw traffic_manager_fqdn)
```

Refresh each curl several times to observe which backend VM responds.

## What Gets Deployed

| Resource | Purpose |
|---|---|
| Resource Group | rg-az104-lab06 |
| VNet + 2 Subnets | Backend subnet + dedicated App Gateway subnet |
| 2 Linux VMs (nginx) | Shared backend pool |
| NSG | Allows HTTP (any) and SSH (restricted CIDR) |
| Load Balancer (Standard SKU) | Layer 4 balancing with HTTP health probe |
| Application Gateway (Standard_v2) | Layer 7 balancing with routing rules |
| Traffic Manager (Priority routing) | DNS-level failover between VM public IPs |

## Estimated Cost

Approximately $4/day, driven primarily by the Application Gateway. Destroy promptly.

## Clean Up

```bash
terraform destroy
```
