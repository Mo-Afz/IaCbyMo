# 🚀 IaCbyMo: Terraform-Powered Azure Landing Zone
NOTE: To deploy your own infrastructure as code you will only need the " Terraform.tfvars" file where you declare what each of the variables are called
in each of your modules. This approach makes these template reusable and modular. terraform apply -var-file="terraform.tfvars" -- Use this command --
this will laod up and override any hard coded variables and load all the variables from the Terraform.tfvars files.

Modular, secure, and production-ready cloud architecture for Azure — built with best-practice Terraform modules.

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
terraform apply -var-file="terraform.tfvars"
