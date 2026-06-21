# Lab 11 -- Monitoring

**AZ-104 Domain:** Monitor and Maintain Azure Resources (10--15%)

This is the capstone lab in the series, tying together Azure Monitor's core components.

## What This Lab Teaches

- Creating a **Log Analytics workspace** as the central data sink for monitoring
- Configuring **diagnostic settings** to route resource metrics into Log Analytics -- the most common misconfiguration in Azure monitoring (without diagnostic settings, your Log Analytics workspace stays empty)
- Defining **metric alerts** that fire when a VM's CPU exceeds a threshold
- Defining **activity log alerts** that fire on control-plane operations (e.g., resource group deletion)
- Setting up **action groups** to deliver alert notifications via email

## Key Concepts

| Concept | Description |
|---|---|
| Azure Monitor | Platform service that collects metrics and logs from Azure resources, applications, and the OS |
| Log Analytics Workspace | Central repository where logs and metrics are stored and queried using KQL (Kusto Query Language) |
| Diagnostic Settings | The bridge between a resource and Log Analytics. Each resource needs its own diagnostic setting -- nothing flows automatically |
| Metric Alerts | Evaluate numeric resource metrics (CPU, memory, disk) on a schedule and fire when a condition is met |
| Activity Log Alerts | Monitor control-plane events: resource creation, deletion, role assignments, policy changes |
| Action Groups | Define who gets notified and how (email, SMS, webhook, Logic App, Azure Function) |

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

## Clean Up

```bash
terraform destroy
```

## Cost and Time

- **Cost:** ~$2/day (VM + Log Analytics ingestion; the free tier covers 5 GB/month of ingestion)
- **Time:** ~6 minutes to deploy
