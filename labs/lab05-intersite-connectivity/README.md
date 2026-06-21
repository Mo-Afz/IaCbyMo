# Lab 05 -- Intersite Connectivity

AZ-104 Domain: Implement and Manage Virtual Networking (15--20%)

## Objective

Build a hub-spoke network topology using Azure VNet peering and verify connectivity between spoke virtual machines. Optionally deploy a VPN Gateway in the hub to explore gateway transit.

## What You Will Learn

- Hub-spoke virtual network architecture
- VNet peering in bilateral pairs (both directions must be configured independently)
- The role of `allow_forwarded_traffic` and `allow_gateway_transit` / `use_remote_gateways`
- Network Security Groups for controlling traffic between peered VNets
- (Optional) VPN Gateway deployment and gateway transit through the hub

## Key Concept

VNet peering is NOT transitive. If Spoke 1 is peered with the Hub, and Spoke 2 is peered with the Hub, Spoke 1 and Spoke 2 cannot communicate directly through the Hub unless `allow_forwarded_traffic` is enabled on the peering links and a routing appliance (NVA or VPN Gateway with BGP) forwards traffic between spokes.

## What Gets Deployed

- 1 Resource Group
- 3 Virtual Networks (hub, spoke1, spoke2) each with a default subnet
- 4 VNet peering links (hub-to-spoke1, spoke1-to-hub, hub-to-spoke2, spoke2-to-hub)
- 1 Network Security Group (shared by both spoke VMs, allows SSH and ICMP)
- 2 Linux VMs (one per spoke) with public IPs for SSH access
- (Optional) 1 VPN Gateway with a GatewaySubnet and public IP in the hub

## Prerequisites

- Azure subscription with Contributor access
- Terraform >= 1.6.0 installed
- Azure CLI authenticated (`az login`)
- An SSH key pair (`ssh-keygen -t rsa -b 4096`)

## Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

## Testing Connectivity

1. SSH into the Spoke 1 VM using its public IP:

```bash
ssh azureuser@$(terraform output -raw spoke1_vm_public_ip)
```

2. From Spoke 1, ping Spoke 2 using its private IP to verify peering:

```bash
ping $(terraform output -raw spoke2_vm_private_ip)
```

If ICMP replies come back, hub-spoke peering with forwarded traffic is working.

## Estimated Cost and Time

| Configuration        | Cost       | Deploy Time |
|----------------------|------------|-------------|
| Default (no VPN GW)  | ~$1.50/day | ~8 min      |
| With VPN Gateway     | ~$26/day   | ~45 min     |

The VPN Gateway is disabled by default. Set `deploy_vpn_gateway = true` in your tfvars to enable it.

## Cleanup

```bash
terraform destroy
```
