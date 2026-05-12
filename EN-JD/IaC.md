# Infrastructure as Code

Focus: Versioned, repeatable environments.

## Key Concepts
- **Tools**: Terraform, CloudFormation (AWS), ARM (Azure).
- **Principles**: Declarative configs, version control.

## Terraform Example
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}
```

Commands: `terraform init`, `terraform plan`, `terraform apply`

## Real-Time Scenarios
- **Scenario 1**: Provision infra. Define resources in code, apply.
- **Scenario 2**: Environment parity. Use same config for dev/prod.
- **Scenario 3**: Changes. Plan before apply to review.
- **Scenario 4**: State management. Store state in S3 for team access.