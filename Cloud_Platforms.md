# Cloud Platforms

Focus: AWS or Azure, hands-on experience.

## Key Concepts
- **AWS Services**: EC2 (compute), S3 (storage), Lambda (serverless), RDS (DB), VPC (networking).
- **Azure Services**: VMs, Blob Storage, Functions, SQL DB, VNet.
- **Best Practices**: Security (IAM), scalability, cost optimization.

## Commands/Examples
AWS CLI: `aws s3 cp file s3://bucket/`
Azure CLI: `az storage blob upload --file file --container container`

## Real-Time Scenarios
- **Scenario 1**: Deploy app on EC2. Use user data for setup, ELB for load balancing.
- **Scenario 2**: Serverless function. Lambda for API backend, triggered by API Gateway.
- **Scenario 3**: Secure access. IAM roles, least privilege.
- **Scenario 4**: Cost monitoring. Use CloudWatch for alerts on spending.