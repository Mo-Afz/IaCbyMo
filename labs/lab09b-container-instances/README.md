# Lab 09b -- Container Instances

## AZ-104 Domain

Deploy and Manage Azure Compute Resources (20--25%)

## Objective

Deploy an Azure Container Instances (ACI) container group using Terraform, covering container configuration, environment variables, and persistent storage with Azure Files.

## What You Will Learn

- **Container groups** -- deploying a Linux container group with a public IP and DNS label.
- **Environment variables** -- passing configuration via regular and secure (secret) environment variables.
- **Volume mounts** -- attaching an Azure Files share to a container for persistent storage.
- **DNS labels** -- assigning a human-readable FQDN to a container group.
- **ACI vs App Service vs AKS** -- understanding when to use each container hosting option.

## Key Concepts

| Concept | Detail |
|---|---|
| Container group | The top-level ACI resource; containers in the same group share networking and storage. Analogous to a Kubernetes pod. |
| Environment variables | Injected at container start; secure variables are not visible in Azure portal or CLI output. |
| Azure Files volume | An SMB file share mounted into the container filesystem; data persists across container restarts. |
| DNS name label | Combined with the Azure region to form an FQDN (e.g., `aci-lab09b-abc12345.eastus.azurecontainer.io`). |
| When to use ACI | Best for short-lived tasks, burst workloads, or simple single-container apps. Use App Service for managed web hosting with deployment slots. Use AKS for complex multi-service architectures requiring orchestration. |

## Usage

```bash
cd labs/lab09b-container-instances
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

- **Cost:** ~$1.20/day (1 vCPU, 1 GB memory Linux container)
- **Time:** ~3 minutes to deploy
