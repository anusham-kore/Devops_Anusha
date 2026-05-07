# Deployment Guide

## Prerequisites

1. Azure CLI installed and logged in: `az login`
2. kubectl installed: `kubectl version --client`
3. Terraform installed: `terraform version`
4. Docker installed for local testing
5. GitHub account with CI/CD secrets configured

## Step 1: Set Up Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure
terraform plan -out=tfplan

# Apply infrastructure (this will take 15-20 minutes)
terraform apply tfplan

# Save outputs for reference
terraform output -json > outputs.json
```

### Important Outputs:
- `aks_cluster_name`: Kubernetes cluster name
- `acr_login_server`: Docker registry URL
- `appgw_public_ip`: Application Gateway IP
- `user_db_host`, `order_db_host`, `payment_db_host`: Database hostnames
- `keyvault_uri`: Key Vault endpoint

## Step 2: Configure kubectl

```bash
# Get AKS credentials
az aks get-credentials --resource-group devops-prod-rg --name devops-prod-aks

# Verify connection
kubectl cluster-info
kubectl get nodes
```

## Step 3: Build and Push Docker Images

```bash
# Login to ACR
az acr login --name devopsproducr

# Build and push all services
for service in api-gateway user-service product-service order-service payment-service notification-service; do
  cd services/$service
  docker build -t devopsproducr.azurecr.io/$service:v1.0.0 .
  docker push devopsproducr.azurecr.io/$service:v1.0.0
  cd ../..
done
```

## Step 4: Configure Databases

```bash
# Get database passwords from Key Vault
az keyvault secret show --vault-name devops-prod-kv --name db-password

# Connect to PostgreSQL and run migrations
psql -h prod-user-db.postgres.database.azure.com -U psqladmin -d users < db/migrations/001_init_schema.sql
psql -h prod-order-db.postgres.database.azure.com -U psqladmin -d orders < db/migrations/001_init_schema.sql
psql -h prod-payment-db.postgres.database.azure.com -U psqladmin -d payments < db/migrations/001_init_schema.sql
```

## Step 5: Deploy to Kubernetes

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

```bash
# Get service IPs (internal)
kubectl get svc -n microservices

# Update Application Gateway backend pool with internal IPs
# (Done manually in Azure Portal or via Terraform)
```

## Step 7: Configure DNS

Point your domain DNS records to the Application Gateway public IP:

```
api.example.com  A  <APPLICATION_GATEWAY_IP>
```

## Verification

### Health Checks
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
```bash
# Get API Gateway IP
API_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Health check
curl http://$API_IP/health

# Get users (requires authentication)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://$API_IP/api/users

# Get products
curl http://$API_IP/api/products
```

## Monitoring

### Azure Monitor
1. Navigate to Application Insights in Azure Portal
2. View metrics, logs, and traces
3. Set up alerts for critical metrics

### Prometheus (In-Cluster)
```bash
# Access Prometheus dashboard
kubectl port-forward -n microservices svc/prometheus 9090:9090

# Visit http://localhost:9090
```

## Scaling

### Manual Scaling
```bash
# Scale deployment
kubectl scale deployment api-gateway -n microservices --replicas=5

# Check HPA
kubectl get hpa -n microservices
```

### Automatic Scaling
HPA is configured in `k8s/hpa/hpa.yaml`. Monitor with:
```bash
kubectl get hpa -n microservices -w
```

## Troubleshooting

### Pod Not Starting
```bash
# Describe pod for events
kubectl describe pod <pod-name> -n microservices

# Check logs
kubectl logs <pod-name> -n microservices

# Check resource availability
kubectl top nodes
kubectl top pods -n microservices
```

### Service Unavailable
```bash
# Check service endpoints
kubectl get endpoints <service-name> -n microservices

# Check network policies
kubectl get networkpolicies -n microservices
```

### Database Connection Issues
```bash
# Verify firewall rules allow pods
az postgres flexible-server firewall-rule list --resource-group devops-prod-rg --server-name prod-user-db

# Test connectivity from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# nslookup prod-user-db.postgres.database.azure.com
# nc -zv prod-user-db.postgres.database.azure.com 5432
```

## Updating Services

### Rolling Update
```bash
# Update image
kubectl set image deployment/api-gateway api-gateway=devopsproducr.azurecr.io/api-gateway:v1.1.0 -n microservices

# Check rollout status
kubectl rollout status deployment/api-gateway -n microservices

# Rollback if needed
kubectl rollout undo deployment/api-gateway -n microservices
```

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete namespace microservices

# Delete Azure infrastructure
cd terraform
terraform destroy
```