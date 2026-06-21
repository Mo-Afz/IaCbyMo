# Lab 09a -- Web Apps

## AZ-104 Domain

Deploy and Manage Azure Compute Resources (20--25%)

## Objective

Deploy an Azure App Service web app with a staging deployment slot using Terraform, covering the App Service features tested on the AZ-104 exam.

## What You Will Learn

- **App Service plans** -- creating a Linux B1 plan that defines the compute resources for your web apps.
- **Web apps** -- deploying a Linux web app with a Node.js 18 LTS application stack.
- **Deployment slots** -- provisioning a staging slot for safe deployments alongside the production slot.
- **Slot swap concept** -- understanding how slot swaps enable zero-downtime deployments by routing traffic between staging and production.
- **Managed identity** -- enabling a system-assigned managed identity for secure access to other Azure resources without storing credentials.

## Key Concepts

| Concept | Detail |
|---|---|
| App Service plan | Defines the VM size, OS, and pricing tier; multiple apps can share one plan. |
| Deployment slots | Separate instances of the same app with their own hostnames and settings; available on Standard tier and above. |
| Slot swap | Swaps the staging slot into production atomically; the platform warms up the staging app before switching traffic. |
| System-assigned identity | An Azure AD identity tied to the app lifecycle; deleted when the app is deleted. |
| App settings | Environment variables injected into the runtime; slot-specific settings can be configured as "sticky." |

## Usage

```bash
cd labs/lab09a-web-apps
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

- **Cost:** ~$1.50/day (B1 App Service plan)
- **Time:** ~5 minutes to deploy
