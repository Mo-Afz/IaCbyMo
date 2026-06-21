# Lab 09c -- Container Apps

## AZ-104 Domain

Deploy and Manage Azure Compute Resources (20--25%)

## Objective

Deploy an Azure Container App with HTTP-based autoscaling using Terraform, covering the Container Apps platform features tested on the AZ-104 exam.

## What You Will Learn

- **Container Apps environments** -- creating a managed environment backed by Log Analytics for centralized logging.
- **Ingress** -- configuring external (internet-facing) and internal (VNet-only) ingress with automatic HTTPS.
- **Scale-to-zero** -- setting minimum replicas to zero so the app consumes no compute when idle, with HTTP scaling rules to add replicas under load.
- **Revisions and traffic splitting** -- understanding single vs. multiple revision mode, and how traffic weight controls gradual rollouts.
- **Log Analytics integration** -- connecting the environment to a Log Analytics workspace for container logs and metrics.

## Key Concepts

| Concept | Detail |
|---|---|
| Container Apps environment | A secure boundary around one or more container apps; provides a shared Log Analytics workspace, networking, and Dapr integration. |
| Ingress | Routes external or internal traffic to the app; TLS termination is handled automatically. Target port maps to the container's listening port. |
| Scale-to-zero | With `min_replicas = 0`, the platform removes all instances when there is no traffic, eliminating idle cost. |
| HTTP scale rule | Adds replicas when concurrent HTTP requests per instance exceed the threshold (10 in this lab). |
| Revision mode | "Single" replaces the active revision on each deploy. "Multiple" keeps old revisions alive so you can split traffic between them. |
| Traffic weight | Controls what percentage of traffic goes to each revision; `latest_revision = true` always points to the newest deploy. |

## Usage

```bash
cd labs/lab09c-container-apps
cp terraform.tfvars.example terraform.tfvars   # edit with your values
terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```

## Estimated Cost and Time

- **Cost:** ~$0.50/day (near-zero when idle due to scale-to-zero)
- **Time:** ~5 minutes to deploy
