# Complete Setup Guide

This comprehensive guide provides all the end-to-end steps to build and deploy the Azure DevOps microservices project from scratch.

## Prerequisites

Before starting, ensure you have the following tools and accounts set up:

### Required Tools
1. **Azure CLI**: Installed and logged in (`az login`)
2. **kubectl**: Kubernetes command-line tool (`kubectl version --client`)
3. **Terraform**: Infrastructure as Code tool (`terraform version`)
4. **Docker**: Container runtime for local testing
5. **Node.js**: For Node.js services (`node --version`)
6. **Python**: For Python services (`python --version`)
7. **GitHub Account**: For CI/CD pipelines and Actions

### Required Accounts & Permissions
- **Azure Account**: Active subscription with appropriate permissions for creating resources
- **GitHub Account**: With CI/CD secrets configured for automated deployments

## Terraform Configuration Updates

### NAT Gateway Implementation Fix

**Issue Fixed**: Terraform plan was failing with error about invalid `next_hop_type` value.

**Root Cause**: Attempted to use `NatGateway` as a route table next hop type, which is not valid in Azure.

**Solution Implemented**:
- ✅ Use `azurerm_subnet_nat_gateway_association` to directly associate NAT Gateway with private subnets
- ✅ This is the correct Azure pattern for enabling outbound internet access
- ✅ Route table remains available for future custom routing rules

**What This Means**:
- Private subnets (AKS and Database) now have direct NAT Gateway association
- All outbound traffic flows through the NAT Gateway via a single public IP
- More secure than individual public IPs for each resource
- Simplifies network management and cost optimization

Navigate to the terraform directory and initialize the infrastructure. This step creates all the required Azure resources.

```bash
cd terraform

# Initialize Terraform (downloads required providers)
terraform init

# Validate configuration syntax
terraform validate

# Plan infrastructure (preview changes)
terraform plan -out=tfplan

# Apply infrastructure (this will take 15-20 minutes)
terraform apply tfplan

# Save outputs for reference
terraform output -json > outputs.json
```

### Troubleshooting Terraform Issues

If you encounter provider-related errors during `terraform init`:

```bash
# Upgrade to latest provider versions
terraform init -upgrade

# Then validate again
terraform validate
```

If you get errors about missing providers or cached packages, the `-upgrade` flag will download the latest compatible versions.

### Common Terraform Errors & Solutions

**Error: "expected route.0.next_hop_type to be one of..."**
- **Cause**: Incorrect NAT Gateway routing configuration
- **Solution**: Use `azurerm_subnet_nat_gateway_association` instead of route table entries
- **Fix Applied**: NAT Gateway is now directly associated with subnets for outbound internet access

**Authentication Errors**
```bash
# If you get Azure authentication errors
az login
az account set --subscription <subscription-id>
terraform plan
```

**Plan Generation Issues**
```bash
# Remove cached plan and regenerate
rm tfplan
terraform plan -out=tfplan
```

### What Gets Created:
- AKS cluster with 3 availability zones
- Azure Container Registry (ACR)
- Application Gateway with WAF
- PostgreSQL databases (private)
- Key Vault for secrets
- Monitoring infrastructure
- **Networking**: Virtual Network with public/private subnets, Network Security Groups, and routing infrastructure

### Important Outputs:
- `aks_cluster_name`: Kubernetes cluster name
- `acr_login_server`: Docker registry URL
- `appgw_public_ip`: Application Gateway IP
- `user_db_host`, `order_db_host`, `payment_db_host`: Database hostnames
- `keyvault_uri`: Key Vault endpoint

## Step 2: Configure kubectl

Connect to your AKS cluster and verify the connection.

```bash
# Get AKS credentials
az aks get-credentials \
    --resource-group anusha-prod-rg-ci \
    --name anusha-aks-ci \
    --admin \
    --overwrite-existing

az aks install-cli
kubelogin --version
kubelogin convert-kubeconfig -l azurecli

 az aks get-credentials \
    --resource-group anusha-prod-rg-ci \
    --name anusha-aks-ci \
    --admin \
    --overwrite-existing

# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Make executable
chmod +x kubectl
# Move to PATH
sudo mv kubectl /usr/local/bin/
# Verify
kubectl version --client

# Verify connection
kubectl cluster-info
kubectl get nodes
```

## Step 3: Build and Push Docker Images

Build all microservice Docker images and push them to Azure Container Registry.

**Note**: This step is required for initial setup. The CI/CD pipeline (`.github/workflows/ci-cd.yml`) will handle building and pushing images for subsequent deployments when code is pushed to the main branch.

**Tech Stack Overview:**
- **Python Services**: api-gateway, product-service, order-service, payment-service (Flask/FastAPI)
- **Node.js Services**: user-service, notification-service (Express.js)

```bash
# Login to ACR
az acr login --name anushaproductacrci

# Build and push all services
for service in api-gateway user-service product-service order-service payment-service notification-service; do
  cd services/$service
  docker build -t devopsproductcrci.azurecr.io/$service:v1.0.0 .
  docker push devopsproductcrci.azurecr.io/$service:v1.0.0
  cd ../..
done
```

## Step 4: Configure Databases

Set up the database schemas by running migrations on each PostgreSQL database.

```bash
# Get database passwords from Key Vault
az keyvault secret show --vault-name devops-prod-kv-ci-anusha --name db-password

# Connect to PostgreSQL and run migrations
psql -h prod-user-db.postgres.database.azure.com -U psqladmin -d users < db/migrations/001_init_schema.sql
psql -h prod-order-db.postgres.database.azure.com -U psqladmin -d orders < db/migrations/001_init_schema.sql
psql -h prod-payment-db.postgres.database.azure.com -U psqladmin -d payments < db/migrations/001_init_schema.sql
```

## Step 5: Deploy to Kubernetes

Apply all Kubernetes manifests to deploy the microservices.

```bash
# Create namespace
kubectl create namespace microservices

# Apply all manifests in order
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/hpa/
kubectl apply -f k8s/policies/
kubectl apply -f k8s/monitoring/
kubectl apply -f k8s/rbac/

# Verify deployments
kubectl get pods -n microservices
kubectl get svc -n microservices
kubectl get hpa -n microservices
```

## Step 6: Configure Application Gateway Backend

Configure the Application Gateway to route traffic to your Kubernetes services.

```bash
# Get service IPs (internal)
kubectl get svc -n microservices

# Update Application Gateway backend pool with internal IPs
# (Done manually in Azure Portal or via Terraform)
```

## Step 7: Configure DNS

Point your domain DNS records to the Application Gateway public IP for production access.

```
api.example.com  A  <APPLICATION_GATEWAY_IP>
```

## Verification & Testing

### Health Checks
Verify that all components are running correctly:

```bash
# Check pod status
kubectl get pods -n microservices

# Check service endpoints
kubectl get endpoints -n microservices

# Check ingress
kubectl get ingress -n microservices

# View logs
kubectl logs -n microservices -l app=api-gateway
```

### API Testing

Test the deployed APIs to ensure everything is working:

```bash
# Method 1: Port forward for local testing
kubectl port-forward -n microservices svc/api-gateway 5000:80

# Health check
curl http://localhost:5000/health

# Get products (public endpoint)
curl http://localhost:5000/api/products

# Method 2: Test via Application Gateway (production)
# Get API Gateway IP
API_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Health check
curl http://$API_IP/health

# Get users (requires authentication)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://$API_IP/api/users

# Get products
curl http://$API_IP/api/products
```

## Tech Stack Diversity

This project demonstrates microservices using multiple technology stacks:

### Python Services (Flask/FastAPI)
- **api-gateway**: Flask - API routing and authentication
- **product-service**: FastAPI - Product catalog with auto-generated OpenAPI docs
- **order-service**: Flask - Order management with PostgreSQL
- **payment-service**: FastAPI - Payment processing with PostgreSQL

### Node.js Services (Express.js)
- **user-service**: Express.js - User management with REST APIs
- **notification-service**: Express.js - Event-driven notifications with RabbitMQ

### Why Multiple Stacks?
- **Real-world relevance**: Enterprise applications often use diverse tech stacks
- **Skill demonstration**: Shows proficiency across different frameworks
- **Best tool for job**: Each service uses the most appropriate technology
- **Interview advantage**: Demonstrates adaptability and broad knowledge

Each service maintains the same API contracts and Kubernetes deployment patterns, proving that technology diversity doesn't compromise system consistency.

## Next Steps

Once deployed, you can:

1. **Monitor the application** using the included Prometheus and Application Insights setup
2. **Scale services** using the Horizontal Pod Autoscalers (HPA)
3. **Update deployments** using the CI/CD pipeline in `.github/workflows/ci-cd.yml`
4. **Review architecture** details in `ARCHITECTURE.md`
5. **Prepare for interviews** using `INTERVIEW_GUIDE.md`

## Troubleshooting

If you encounter issues:

- Check pod logs: `kubectl logs -n microservices <pod-name>`
- Verify services: `kubectl describe svc -n microservices`
- Check resource status: `kubectl get all -n microservices`
- Review Terraform state: `terraform show` in the terraform directory

The project is now fully deployed and ready for use! 🚀