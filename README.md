# Azure Interview Preparation Guide

This README is a focused roadmap for preparing for Azure interviews at around the 2-year experience level. It covers the prerequisites you should know first, the Azure topics most commonly asked in interviews, and the supporting DevOps and troubleshooting areas that recruiters and technical panels expect.

## Target Profile

This guide is best for:
- Engineers with around 2 years of experience
- Candidates preparing for Azure Administrator, Azure DevOps, Cloud Engineer, or Support Engineer interviews
- Learners who want both theory and practical interview readiness

## Prerequisites

Before going deep into Azure, build comfort in these basics:

### 1. Networking Fundamentals
- IP addressing
- Subnets and CIDR
- DNS
- NAT
- Load balancing basics
- Firewalls and ports
- VPN and private connectivity basics
- HTTP vs HTTPS
- TCP vs UDP

### 2. Operating Systems
- Linux basics
- Windows Server basics
- File system navigation
- Process and service management
- User and group management
- Permissions and access control
- Logs and troubleshooting

### 3. Scripting and Automation
- PowerShell basics
- Bash basics
- Variables, loops, conditions, functions
- Writing small automation scripts
- Basic JSON and YAML understanding

### 4. DevOps Basics
- CI/CD concepts
- Version control with Git
- Build and release pipelines
- Infrastructure as Code basics
- Monitoring and alerting basics

### 5. Security Basics
- Authentication vs authorization
- RBAC concepts
- Secret management
- Encryption at rest and in transit
- Least privilege principle

## Azure Interview Topics

### 1. Azure Fundamentals
- What is Azure
- Regions, region pairs, and availability zones
- Resource groups
- Subscriptions and management groups
- Azure portal, CLI, and PowerShell
- ARM basics
- Shared responsibility model

### 2. Azure Identity and Access Management
- Microsoft Entra ID (Azure AD)
- Users, groups, and roles
- Role-Based Access Control (RBAC)
- Conditional access basics
- Managed identities
- Service principals
- Multi-factor authentication
- Privileged Identity Management basics

### 3. Azure Compute Services
- Virtual Machines
- VM sizes and pricing basics
- Availability sets vs availability zones
- Scale sets
- App Service
- Azure Functions
- Container Instances
- AKS basics
- When to choose VM vs App Service vs AKS vs Functions

### 4. Azure Storage
- Storage accounts
- Blob storage
- File storage
- Queue storage
- Table storage
- Access tiers: hot, cool, archive
- Redundancy options: LRS, GRS, ZRS
- Shared access signatures
- Storage security and firewall rules

### 5. Azure Networking
- Virtual networks
- Subnets
- Network Security Groups
- Application Security Groups
- Azure Firewall
- Load Balancer
- Application Gateway
- VPN Gateway
- ExpressRoute basics
- Private Endpoint and Service Endpoint
- DNS in Azure
- VNet peering

### 6. Azure Databases
- Azure SQL Database
- Managed Instance basics
- Cosmos DB basics
- Database backup and restore concepts
- High availability basics
- Choosing the right database service

### 7. Azure Monitoring and Management
- Azure Monitor
- Log Analytics Workspace
- Application Insights
- Alerts and action groups
- Metrics vs logs
- Diagnostic settings
- Azure Service Health
- Azure Advisor

### 8. Backup, Disaster Recovery, and High Availability
- Azure Backup
- Recovery Services Vault
- Site Recovery basics
- RPO and RTO
- Business continuity concepts
- Zone redundancy
- Geo-redundancy

### 9. Azure Security
- Microsoft Defender for Cloud basics
- Key Vault
- Disk encryption basics
- Network security controls
- Identity security
- Secure score basics
- Governance and compliance basics

### 10. Azure Governance
- Azure Policy
- Resource locks
- Tags
- Management groups
- Cost management basics
- Budgets and alerts
- Naming standards

### 11. Infrastructure as Code
- ARM templates basics
- Bicep basics
- Terraform basics for Azure
- Parameter files
- Reusable modules
- Environment-based deployments

### 12. Azure DevOps
- Azure Repos
- Azure Pipelines
- Build pipeline vs release pipeline
- YAML pipelines
- Self-hosted vs Microsoft-hosted agents
- Variable groups
- Service connections
- Artifacts
- Deployment strategies

### 13. Containers and Kubernetes
- Docker basics
- Container registry basics
- Azure Container Registry
- AKS architecture basics
- Pods, deployments, services
- Ingress basics
- Scaling and upgrades
- Secrets and config maps basics

## Must-Know DevOps Topics for Azure Interviews

- Git branching strategies
- CI/CD pipeline stages
- Build, test, deploy lifecycle
- Blue-green deployment basics
- Canary deployment basics
- Rollback strategies
- Artifact management
- Release approvals and gates
- Environment promotion
- Secret handling in pipelines

## Scenario-Based Topics Frequently Asked in Interviews

Be ready to explain how you would handle scenarios like:

- A VM is not reachable
- A website is slow in Azure
- Storage access is failing
- A user cannot access a resource even though they are in the correct group
- An Azure pipeline is failing during deployment
- A production deployment needs rollback
- A public application needs to become private
- Costs have suddenly increased
- An application needs high availability across regions
- A team wants secure secret storage for pipelines

## Troubleshooting Topics

Interviewers often test practical thinking, not just definitions. Focus on:

- VM boot and connectivity issues
- NSG and firewall rule validation
- DNS troubleshooting
- Load balancer health probe issues
- App Service deployment failures
- Pipeline agent and permission issues
- RBAC access issues
- Storage firewall and networking issues
- Monitoring logs and metrics analysis

## Common Interview Questions to Prepare

### Azure Basics
- What is the difference between a region and an availability zone?
- What is the use of a resource group?
- What is the difference between Azure portal, Azure CLI, and PowerShell?

### Identity and Security
- What is RBAC?
- What is the difference between a service principal and managed identity?
- How does Key Vault help in Azure?
- What is the difference between authentication and authorization?

### Compute and Storage
- When would you choose App Service over Virtual Machines?
- What is a scale set?
- What are storage account redundancy options?
- What is the difference between Blob storage and File storage?

### Networking
- What is VNet peering?
- What is the difference between NSG and Azure Firewall?
- What is the use of Application Gateway?
- What is the difference between Private Endpoint and Service Endpoint?

### DevOps and Automation
- What is CI/CD?
- How do you create a YAML pipeline in Azure DevOps?
- What are service connections in Azure DevOps?
- What is Infrastructure as Code?
- What is the difference between ARM, Bicep, and Terraform?

### Monitoring and Operations
- What is Azure Monitor?
- What is the difference between metrics and logs?
- How do you monitor an application in Azure?
- How do you plan backup and disaster recovery in Azure?

## Hands-On Practice Checklist

To be interview-ready, try to practice these tasks:

- Create a resource group
- Deploy a virtual machine
- Configure NSG rules
- Create a storage account and upload blobs
- Create an App Service
- Configure Azure Monitor alerts
- Store secrets in Key Vault
- Create a basic Azure DevOps pipeline
- Deploy infrastructure using Bicep or Terraform
- Configure a simple AKS cluster or study the deployment flow

## Suggested Learning Order

1. Azure fundamentals
2. Networking and identity
3. Compute and storage
4. Monitoring and security
5. Governance and backup
6. Azure DevOps and CI/CD
7. Infrastructure as Code
8. Containers and AKS
9. Scenario-based troubleshooting
10. Mock interviews and revision

## Interview Preparation Tips

- Learn concepts and also practice in the Azure portal
- Prepare short answers for common questions
- Use real project examples from your experience
- Be clear about what you did personally in projects
- Practice troubleshooting answers step by step
- Revise important Azure services with use cases
- Focus on confidence, clarity, and structured explanations

## Final Goal

By covering the topics in this README, you should be able to:
- Explain core Azure services confidently
- Answer scenario-based interview questions
- Discuss Azure DevOps and automation clearly
- Demonstrate practical understanding expected from a 2-year experienced candidate
