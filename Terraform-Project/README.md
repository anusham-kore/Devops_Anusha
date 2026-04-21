# Terraform Project

This project provisions a modular AWS platform using Terraform.

## Modules

- `vpc`: VPC, public/private subnets, internet gateway, NAT gateway, and route tables
- `nlb`: Network Load Balancer, target group, and listener
- `route53`: DNS record pointing to the load balancer
- `eks`: EKS cluster and managed node group

## Files

- `main.tf`: root module wiring
- `variables.tf`: configurable inputs
- `outputs.tf`: important outputs
- `backend.tf`: remote backend definition
- `versions.tf`: Terraform and provider version constraints
- `terraform.tfvars.example`: sample input values

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values.
2. Configure the backend during init, for example:
   `terraform init -backend-config="bucket=<bucket>" -backend-config="key=envs/prod/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="dynamodb_table=<lock-table>"`
3. Run:
   `terraform fmt`
   `terraform validate`
   `terraform plan`
   `terraform apply`

## Notes

- The NLB module creates the load balancer resources but does not yet attach application targets.
- For production, consider one NAT gateway per AZ for higher availability.
- You can extend this project with environment-specific tfvars files and CI/CD automation.
