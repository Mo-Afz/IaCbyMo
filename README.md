# 🚀 IaCbyMo: Terraform-Powered Azure Landing Zone

Modular, secure, and production-ready cloud architecture for Azure — built with best-practice Terraform modules and recruiter-ready documentation.

## 📦 Modules Included
- ✅ `networking`: vNet, subnets, NSGs
- ✅ `compute`: VMSS clusters with autoscaling
- ✅ `governance`: policy enforcement, tagging, locks

## 🧪 Example Scenarios
Explore real-world configs:
- `examples/sample-vmss.tf`: Scalable compute with VMSS
- `examples/simple-networking/`: Basic networking module use
- More coming soon...

## 📐 Architecture Diagram
Visual breakdown of module interaction — see [`diagrams/`](diagrams/) for full topology.

## 🔧 Requirements
- Terraform >= 1.6
- Azure Provider >= 3.x
- Azure CLI configured

## 🚀 Quickstart
```bash
cd examples/sample-vmss
terraform init
terraform apply
