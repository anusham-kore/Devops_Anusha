# Azure Full-Stack AKS Project

This lab is a high-level project blueprint that connects all Azure interview topics into one realistic application. The project has a frontend, backend API, middle tier worker, database, storage, identity, networking, monitoring, security, DevOps pipeline, Infrastructure as Code, Helm deployment, and K9s operational practice.

## Project Name

CloudShop: Full-Stack E-Commerce Order Platform

## Project Goal

Build and deploy a small e-commerce style application on Azure where users can browse products, place orders, upload receipts, and track order status.

The purpose is not to build a large production system. The purpose is to understand how Azure services work together in a real project and to explain the architecture confidently in interviews.

## High-Level Architecture

```text
User
  |
  v
Azure Application Gateway / Ingress Controller
  |
  v
Frontend Web App
  |
  v
Backend API
  |
  +--> Azure SQL Database
  +--> Azure Storage Account
  +--> Azure Service Bus / Queue
  +--> Azure Key Vault
  |
  v
Middle Tier Worker
  |
  +--> Processes queue messages
  +--> Updates order status
  +--> Writes logs and metrics

Platform:
AKS + ACR + Helm + Azure Monitor + Log Analytics + Azure DevOps + Terraform/Bicep
```

## Application Components

| Layer | Component | Example Technology | Purpose |
| --- | --- | --- | --- |
| Frontend | Web UI | React, Angular, or simple HTML app | Product list, cart, order status |
| Backend | REST API | Node.js, .NET, Java, or Python | Handles user requests and business logic |
| Middle tier | Worker service | Background worker container | Processes orders asynchronously |
| Database | Azure SQL Database | Managed SQL | Stores users, products, and orders |
| Storage | Azure Blob Storage | Storage account | Stores product images and receipt files |
| Messaging | Azure Service Bus or Storage Queue | Queue | Decouples API from background processing |
| Identity | Microsoft Entra ID | App registration / managed identity | Authentication and service access |
| Secrets | Azure Key Vault | Secrets and keys | Stores connection strings and credentials |
| Platform | AKS | Kubernetes | Runs frontend, API, and worker containers |
| Packaging | Helm | Helm chart | Deploys Kubernetes resources consistently |
| Operations | K9s | Kubernetes terminal UI | Views pods, logs, services, and events |

## Azure Topics Covered

| README Topic | How This Project Covers It |
| --- | --- |
| Azure Fundamentals | Resource groups, regions, subscriptions, ARM deployment flow |
| Identity and Access Management | Entra ID, RBAC, managed identities, service principals |
| Compute Services | AKS, container workloads, optional App Service comparison |
| Storage | Blob containers, access tiers, SAS, private access |
| Networking | VNet, subnets, NSG, private endpoints, ingress, DNS |
| Databases | Azure SQL Database, backups, firewall/private access |
| Monitoring and Management | Azure Monitor, Log Analytics, alerts, Application Insights |
| Backup, DR, and HA | SQL backups, zone-aware design, RPO/RTO discussion |
| Security | Key Vault, Defender for Cloud, private endpoints, least privilege |
| Governance | Tags, locks, budgets, policy, naming standards |
| Infrastructure as Code | Bicep or Terraform for Azure resources |
| Azure DevOps | CI/CD pipeline, service connection, build and deploy stages |
| Containers and Kubernetes | Docker, ACR, AKS, Helm, pods, services, ingress, scaling |

## Suggested Azure Resource Design

### Resource Groups

| Resource Group | Purpose |
| --- | --- |
| `rg-cloudshop-dev-core` | Networking, Key Vault, Log Analytics |
| `rg-cloudshop-dev-aks` | AKS and related resources |
| `rg-cloudshop-dev-data` | Azure SQL and Storage Account |

For beginner practice, you can also keep everything in one resource group:

```text
rg-cloudshop-dev
```

## Naming Standard

| Resource | Example Name |
| --- | --- |
| Resource group | `rg-cloudshop-dev` |
| VNet | `vnet-cloudshop-dev-cin` |
| AKS | `aks-cloudshop-dev-cin` |
| ACR | `acrcloudshopdevcin001` |
| Key Vault | `kv-cloudshop-dev-cin` |
| Storage Account | `stcloudshopdevcin001` |
| SQL Server | `sql-cloudshop-dev-cin` |
| SQL Database | `sqldb-cloudshop-dev` |
| Log Analytics | `law-cloudshop-dev-cin` |

## Portal-First 1-Hour Lab Using One Resource Group

Use this section when you want to create the project from the Azure Portal UI first. This is the recommended first attempt if you are using free Azure credits and want to delete everything after about 1 hour.

### Cost-Saving Choices

| Area | Lab Choice |
| --- | --- |
| Resource group | Use only `rg-cloudshop-dev` |
| Region | `Central India` |
| AKS tier | Free tier |
| AKS node count | 1 node |
| AKS VM size | `Standard_B2s` or the smallest available B-series size |
| Container registry | Basic SKU |
| SQL Database | Basic tier |
| Queue | Storage Queue instead of Service Bus |
| Ingress | Simple LoadBalancer service first |
| Application Gateway | Skip for the 1-hour lab |
| Defender paid plans | Do not enable for this lab |
| Monitoring | Keep basic monitoring only, delete after practice |

### Step 1: Create Resource Group

1. Open the Azure Portal.
2. Search for `Resource groups`.
3. Select **Create**.
4. Select your subscription.
5. Enter resource group name: `rg-cloudshop-dev`.
6. Select region: `Central India`.
7. Open the **Tags** tab and add:
   - `Environment = Dev`
   - `Project = CloudShop`
   - `Owner = YourName`
   - `CostCenter = Learning`
8. Select **Review + create**.
9. Select **Create**.

### Step 2: Create Virtual Network

1. Search for `Virtual networks`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter name: `vnet-cloudshop-dev-cin`.
5. Select region: `Central India`.
6. On the IP addresses tab, use address space: `10.40.0.0/16`.
7. Create this subnet:

| Subnet | Address Range |
| --- | --- |
| `snet-aks` | `10.40.1.0/24` |

8. Select **Review + create**.
9. Select **Create**.

For the first UI-only lab, skip private endpoint and Application Gateway subnets. Add them later when you practice production-style networking.

### Step 3: Create Azure Container Registry

1. Search for `Container registries`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter registry name: `acrcloudshopdevcin001`.
5. Select region: `Central India`.
6. Select SKU: **Basic**.
7. Select **Review + create**.
8. Select **Create**.

### Step 4: Create AKS Cluster

1. Search for `Kubernetes services`.
2. Select **Create** > **Create a Kubernetes cluster**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter cluster name: `aks-cloudshop-dev-cin`.
5. Select region: `Central India`.
6. For pricing tier, choose **Free**.
7. For node pool, use:

| Setting | Value |
| --- | --- |
| Node pool name | `agentpool` |
| Mode | System |
| Node count | `1` |
| VM size | `Standard_B2s` or smallest available B-series size |
| Autoscaling | Disabled for the first lab |

8. On the networking tab, keep the default/simple networking option if you are new.
9. If the portal asks for container registry integration, attach `acrcloudshopdevcin001`.
10. Keep monitoring basic. If Log Analytics is enabled, create or select `law-cloudshop-dev-cin`.
11. Select **Review + create**.
12. Select **Create**.

AKS creation can take several minutes. After creation, open the AKS resource and check that the node status becomes ready.

### Step 5: Create Storage Account

1. Search for `Storage accounts`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter storage account name: `stcloudshopdevcin001`.
5. Select region: `Central India`.
6. Select performance: **Standard**.
7. Select redundancy: **Locally-redundant storage (LRS)**.
8. Select **Review + create**.
9. Select **Create**.

After the storage account is created:

1. Open `stcloudshopdevcin001`.
2. Go to **Data storage** > **Containers**.
3. Create containers:

| Container | Public Access |
| --- | --- |
| `product-images` | Private |
| `receipts` | Private |
| `logs-archive` | Private |

4. Go to **Data storage** > **Queues**.
5. Create queue: `orders-to-process`.

### Step 6: Create Azure SQL Database

1. Search for `SQL databases`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter database name: `sqldb-cloudshop-dev`.
5. Under server, select **Create new**.
6. Enter server name: `sql-cloudshop-dev-cin`.
7. Select location: `Central India`.
8. Enter SQL admin login: `sqladminuser`.
9. Enter a strong password and save it for the lab.
10. For compute + storage, select the smallest/cheapest option available, such as **Basic**.
11. For networking, choose public endpoint for the first lab.
12. Add your current client IP if the portal offers that option.
13. Select **Review + create**.
14. Select **Create**.

For interview practice, understand that production systems usually use private networking, tighter firewall rules, managed identity, and stronger secret handling.

### Step 7: Create Key Vault

1. Search for `Key vaults`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter key vault name: `kv-cloudshop-dev-cin`.
5. Select region: `Central India`.
6. Keep pricing tier as **Standard**.
7. Select **Review + create**.
8. Select **Create**.

After the key vault is created:

1. Open `kv-cloudshop-dev-cin`.
2. Go to **Objects** > **Secrets**.
3. Select **Generate/Import**.
4. Create a secret:

| Field | Value |
| --- | --- |
| Name | `SqlConnectionString` |
| Value | SQL connection string for `sqldb-cloudshop-dev` |

Example value:

```text
Server=tcp:sql-cloudshop-dev-cin.database.windows.net,1433;Database=sqldb-cloudshop-dev;User ID=sqladminuser;Password=YourPasswordHere;Encrypt=true;
```

### Step 8: Create Log Analytics Workspace

1. Search for `Log Analytics workspaces`.
2. Select **Create**.
3. Select resource group: `rg-cloudshop-dev`.
4. Enter name: `law-cloudshop-dev-cin`.
5. Select region: `Central India`.
6. Select **Review + create**.
7. Select **Create**.

For a 1-hour lab, keep logging light. Logs are useful for learning, but they can add cost if you generate a lot of data.

### Step 9: Deploy a Simple Test App from AKS UI

Use this step only to confirm that AKS is working before building the real CloudShop app.

1. Open `aks-cloudshop-dev-cin`.
2. Go to **Kubernetes resources** > **Workloads**.
3. Select **Create** if available in your portal experience.
4. Choose a simple deployment.
5. Use image: `nginx`.
6. Set namespace: `cloudshop-dev` if the UI allows creating/selecting a namespace. Otherwise use `default` for this quick test.
7. Create a service with type **LoadBalancer** and port `80`.
8. Wait for an external IP.
9. Open the external IP in a browser.

If your portal does not show a simple workload creation option, use **Cloud Shell** from the portal later for only the Kubernetes deployment commands. The Azure resources themselves can still be created fully from UI.

### Step 10: Verify Everything in the Resource Group

1. Open resource group `rg-cloudshop-dev`.
2. Confirm you can see:
   - AKS cluster
   - ACR
   - VNet
   - Storage account
   - SQL server
   - SQL database
   - Key Vault
   - Log Analytics workspace if enabled
   - Public IP and load balancer if you exposed the test app
3. Open **Cost Management** for the resource group or subscription.
4. Check estimated cost after the lab.

### Step 11: Delete Everything After Practice

For this 1-hour practice, delete the single resource group:

1. Open resource group `rg-cloudshop-dev`.
2. Select **Delete resource group**.
3. Type `rg-cloudshop-dev` to confirm.
4. Select **Delete**.
5. Wait for deletion to finish.
6. Refresh resource groups and confirm `rg-cloudshop-dev` is gone.

This removes the AKS nodes, SQL, storage, ACR, Key Vault, public IPs, load balancer, and monitoring resources created inside the lab resource group.

## Azure CLI 1-Hour Lab Using One Resource Group

Use this section when you want to create the same practice environment from Azure CLI. This is the repeatable command-line version of the portal-first lab above.

Standalone CLI runbook: [azure-fullstack-aks-cli-steps.md](azure-fullstack-aks-cli-steps.md)

### Before Running Commands

Install or open one of these:

- Azure CLI on your laptop
- Azure Cloud Shell from the Azure Portal
- VS Code terminal with Azure CLI installed

Login and confirm your subscription:

```bash
az login
az account show --output table
```

If you have multiple subscriptions, select the correct one:

```bash
az account set --subscription "<subscription-id-or-name>"
```

### Set Variables

For Bash or Azure Cloud Shell:

```bash
RG="rg-cloudshop-dev"
LOC="centralindia"
VNET="vnet-cloudshop-dev-cin"
AKS_SUBNET="snet-aks"
ACR="acrcloudshopdevcin001"
AKS="aks-cloudshop-dev-cin"
STORAGE="stcloudshopdevcin001"
SQLSERVER="sql-cloudshop-dev-cin"
SQLDB="sqldb-cloudshop-dev"
KV="kv-cloudshop-dev-cin"
LAW="law-cloudshop-dev-cin"
```

For PowerShell:

```powershell
$RG="rg-cloudshop-dev"
$LOC="centralindia"
$VNET="vnet-cloudshop-dev-cin"
$AKS_SUBNET="snet-aks"
$ACR="acrcloudshopdevcin001"
$AKS="aks-cloudshop-dev-cin"
$STORAGE="stcloudshopdevcin001"
$SQLSERVER="sql-cloudshop-dev-cin"
$SQLDB="sqldb-cloudshop-dev"
$KV="kv-cloudshop-dev-cin"
$LAW="law-cloudshop-dev-cin"
```

### Step 1: Create Resource Group

```bash
az group create \
  --name "$RG" \
  --location "$LOC" \
  --tags Environment=Dev Project=CloudShop Owner=YourName CostCenter=Learning
```

PowerShell:

```powershell
az group create `
  --name $RG `
  --location $LOC `
  --tags Environment=Dev Project=CloudShop Owner=YourName CostCenter=Learning
```

### Step 2: Create Virtual Network

```bash
az network vnet create \
  --resource-group "$RG" \
  --name "$VNET" \
  --location "$LOC" \
  --address-prefix 10.40.0.0/16 \
  --subnet-name "$AKS_SUBNET" \
  --subnet-prefix 10.40.1.0/24
```

PowerShell:

```powershell
az network vnet create `
  --resource-group $RG `
  --name $VNET `
  --location $LOC `
  --address-prefix 10.40.0.0/16 `
  --subnet-name $AKS_SUBNET `
  --subnet-prefix 10.40.1.0/24
```

### Step 3: Create Azure Container Registry

```bash
az acr create \
  --resource-group "$RG" \
  --name "$ACR" \
  --location "$LOC" \
  --sku Basic
```

PowerShell:

```powershell
az acr create `
  --resource-group $RG `
  --name $ACR `
  --location $LOC `
  --sku Basic
```

### Step 4: Create AKS Cluster

Use 1 small node for the short free-credit lab.

```bash
az aks create \
  --resource-group "$RG" \
  --name "$AKS" \
  --location "$LOC" \
  --node-count 1 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --attach-acr "$ACR" \
  --generate-ssh-keys
```

PowerShell:

```powershell
az aks create `
  --resource-group $RG `
  --name $AKS `
  --location $LOC `
  --node-count 1 `
  --node-vm-size Standard_B2s `
  --enable-managed-identity `
  --attach-acr $ACR `
  --generate-ssh-keys
```

Get cluster credentials:

```bash
az aks get-credentials \
  --resource-group "$RG" \
  --name "$AKS"
```

PowerShell:

```powershell
az aks get-credentials `
  --resource-group $RG `
  --name $AKS
```

Verify node status:

```bash
kubectl get nodes
```

### Step 5: Create Storage Account

```bash
az storage account create \
  --resource-group "$RG" \
  --name "$STORAGE" \
  --location "$LOC" \
  --sku Standard_LRS \
  --kind StorageV2
```

PowerShell:

```powershell
az storage account create `
  --resource-group $RG `
  --name $STORAGE `
  --location $LOC `
  --sku Standard_LRS `
  --kind StorageV2
```

Create Blob containers:

```bash
az storage container create --account-name "$STORAGE" --name product-images --auth-mode login
az storage container create --account-name "$STORAGE" --name receipts --auth-mode login
az storage container create --account-name "$STORAGE" --name logs-archive --auth-mode login
```

PowerShell:

```powershell
az storage container create --account-name $STORAGE --name product-images --auth-mode login
az storage container create --account-name $STORAGE --name receipts --auth-mode login
az storage container create --account-name $STORAGE --name logs-archive --auth-mode login
```

Create Storage Queue:

```bash
az storage queue create \
  --account-name "$STORAGE" \
  --name orders-to-process \
  --auth-mode login
```

PowerShell:

```powershell
az storage queue create `
  --account-name $STORAGE `
  --name orders-to-process `
  --auth-mode login
```

### Step 6: Create Azure SQL Database

Choose your own strong password before running this step.

Bash or Azure Cloud Shell:

```bash
SQL_ADMIN="sqladminuser"
SQL_PASSWORD="UseYourStrongPassword@123"
```

PowerShell:

```powershell
$SQL_ADMIN="sqladminuser"
$SQL_PASSWORD="UseYourStrongPassword@123"
```

Create SQL server:

```bash
az sql server create \
  --resource-group "$RG" \
  --name "$SQLSERVER" \
  --location "$LOC" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD"
```

PowerShell:

```powershell
az sql server create `
  --resource-group $RG `
  --name $SQLSERVER `
  --location $LOC `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD
```

Allow Azure services for quick lab connectivity:

```bash
az sql server firewall-rule create \
  --resource-group "$RG" \
  --server "$SQLSERVER" \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

PowerShell:

```powershell
az sql server firewall-rule create `
  --resource-group $RG `
  --server $SQLSERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

Create a Basic SQL database:

```bash
az sql db create \
  --resource-group "$RG" \
  --server "$SQLSERVER" \
  --name "$SQLDB" \
  --service-objective Basic
```

PowerShell:

```powershell
az sql db create `
  --resource-group $RG `
  --server $SQLSERVER `
  --name $SQLDB `
  --service-objective Basic
```

### Step 7: Create Key Vault

```bash
az keyvault create \
  --resource-group "$RG" \
  --name "$KV" \
  --location "$LOC"
```

PowerShell:

```powershell
az keyvault create `
  --resource-group $RG `
  --name $KV `
  --location $LOC
```

Store SQL connection string:

```bash
az keyvault secret set \
  --vault-name "$KV" \
  --name SqlConnectionString \
  --value "Server=tcp:$SQLSERVER.database.windows.net,1433;Database=$SQLDB;User ID=$SQL_ADMIN;Password=$SQL_PASSWORD;Encrypt=true;"
```

PowerShell:

```powershell
az keyvault secret set `
  --vault-name $KV `
  --name SqlConnectionString `
  --value "Server=tcp:$SQLSERVER.database.windows.net,1433;Database=$SQLDB;User ID=$SQL_ADMIN;Password=$SQL_PASSWORD;Encrypt=true;"
```

### Step 8: Create Log Analytics Workspace

```bash
az monitor log-analytics workspace create \
  --resource-group "$RG" \
  --workspace-name "$LAW" \
  --location "$LOC"
```

PowerShell:

```powershell
az monitor log-analytics workspace create `
  --resource-group $RG `
  --workspace-name $LAW `
  --location $LOC
```

### Step 9: Deploy a Simple Test App

Create namespace:

```bash
kubectl create namespace cloudshop-dev
```

Deploy `nginx` as a test app:

```bash
kubectl create deployment cloudshop-test \
  --image=nginx \
  --namespace cloudshop-dev
```

Expose it using a public load balancer:

```bash
kubectl expose deployment cloudshop-test \
  --type=LoadBalancer \
  --port=80 \
  --namespace cloudshop-dev
```

PowerShell:

```powershell
kubectl create namespace cloudshop-dev

kubectl create deployment cloudshop-test `
  --image=nginx `
  --namespace cloudshop-dev

kubectl expose deployment cloudshop-test `
  --type=LoadBalancer `
  --port=80 `
  --namespace cloudshop-dev
```

Check the external IP:

```bash
kubectl get svc -n cloudshop-dev
```

Open the `EXTERNAL-IP` in a browser after it appears.

### Step 10: Verify Resources

```bash
az resource list \
  --resource-group "$RG" \
  --output table
```

PowerShell:

```powershell
az resource list `
  --resource-group $RG `
  --output table
```

Verify Kubernetes resources:

```bash
kubectl get all -n cloudshop-dev
```

### Step 11: Delete Everything After 1 Hour

Delete the full resource group to stop charges:

```bash
az group delete \
  --name "$RG" \
  --yes \
  --no-wait
```

PowerShell:

```powershell
az group delete `
  --name $RG `
  --yes `
  --no-wait
```

Check whether the resource group is gone:

```bash
az group exists --name "$RG"
```

PowerShell:

```powershell
az group exists --name $RG
```

If the output is `false`, the resource group has been deleted.

## Phase 1: Azure Foundation

### Create the Resource Group

```bash
az group create --name rg-cloudshop-dev --location centralindia
```

### Apply Tags

Tags:
- `Environment = Dev`
- `Project = CloudShop`
- `Owner = YourName`
- `CostCenter = Learning`

### What to learn
- Resource groups are logical containers
- Region choice affects latency, availability, and cost
- Tags help with governance and cost tracking

## Phase 2: Networking

### Create Network Design

Recommended CIDR:

```text
VNet: 10.40.0.0/16
AKS subnet: 10.40.1.0/24
Private endpoint subnet: 10.40.2.0/24
Application Gateway subnet: 10.40.3.0/24
```

### Services to configure
- Virtual Network
- Subnets
- Network Security Groups
- Private DNS zones
- Optional Application Gateway or NGINX Ingress Controller

### What to learn
- Subnets divide the VNet address space
- NSGs filter traffic
- Private endpoints need private DNS
- Ingress controls external access to services inside AKS

## Phase 3: Identity and Security

### Configure Identity

Use:
- Microsoft Entra ID for users and groups
- Azure RBAC for resource access
- Managed identity for AKS workload access where possible
- Service principal or workload identity federation for pipelines

### Configure Key Vault

Store:
- SQL connection string
- Storage connection information
- Application secret values

### What to learn
- Authentication happens through Entra ID
- Authorization happens through RBAC
- Managed identity avoids hardcoded secrets
- Key Vault stores sensitive configuration

## Phase 4: Database and Storage

### Azure SQL Database

Tables:
- `Products`
- `Orders`
- `OrderItems`
- `Users`

### Blob Storage

Containers:
- `product-images`
- `receipts`
- `logs-archive`

### Queue

Queue name:

```text
orders-to-process
```

### What to learn
- SQL Database stores relational application data
- Blob Storage stores unstructured files
- Queue decouples API from background processing
- Backups and restore options matter for production systems

## Phase 5: Container Build and Registry

### Container Images

| Image | Purpose |
| --- | --- |
| `cloudshop-frontend` | Web UI |
| `cloudshop-api` | Backend REST API |
| `cloudshop-worker` | Middle tier queue processor |

### Build and Push

```bash
az acr login --name acrcloudshopdevcin001
docker build -t acrcloudshopdevcin001.azurecr.io/cloudshop-frontend:1.0.0 ./frontend
docker build -t acrcloudshopdevcin001.azurecr.io/cloudshop-api:1.0.0 ./api
docker build -t acrcloudshopdevcin001.azurecr.io/cloudshop-worker:1.0.0 ./worker
docker push acrcloudshopdevcin001.azurecr.io/cloudshop-frontend:1.0.0
docker push acrcloudshopdevcin001.azurecr.io/cloudshop-api:1.0.0
docker push acrcloudshopdevcin001.azurecr.io/cloudshop-worker:1.0.0
```

### What to learn
- Docker image is the package
- Container is the running instance
- ACR stores private images
- AKS needs permission to pull images from ACR

## Phase 6: AKS Deployment

### Kubernetes Objects

| Object | Project Usage |
| --- | --- |
| Namespace | `cloudshop-dev` |
| Deployment | Frontend, API, worker |
| Service | Internal access to frontend/API pods |
| Ingress | External HTTP/HTTPS routing |
| ConfigMap | Non-secret configuration |
| Secret | Temporary practice secrets only |
| HPA | Autoscale frontend and API pods |
| ServiceAccount | Workload identity integration |

### Namespace

```bash
kubectl create namespace cloudshop-dev
```

### What to learn
- Pods run containers
- Deployments manage replicas and rolling updates
- Services provide stable access to pods
- Ingress exposes HTTP/HTTPS routes
- ConfigMaps and Secrets separate config from image

## Phase 7: Helm Chart

Create a Helm chart for all application components.

### Suggested Structure

```text
Labs/cloudshop-helm/
  Chart.yaml
  values.yaml
  values-dev.yaml
  values-prod.yaml
  templates/
    namespace.yaml
    frontend-deployment.yaml
    frontend-service.yaml
    api-deployment.yaml
    api-service.yaml
    worker-deployment.yaml
    ingress.yaml
    configmap.yaml
    secretproviderclass.yaml
    hpa.yaml
```

### Example Helm Commands

```bash
helm lint Labs/cloudshop-helm
helm template cloudshop Labs/cloudshop-helm --values Labs/cloudshop-helm/values-dev.yaml
helm upgrade --install cloudshop Labs/cloudshop-helm --namespace cloudshop-dev --create-namespace --values Labs/cloudshop-helm/values-dev.yaml
helm list --namespace cloudshop-dev
helm rollback cloudshop 1 --namespace cloudshop-dev
helm uninstall cloudshop --namespace cloudshop-dev
```

### High-Level Helm Topics

- Chart:
  Package of Kubernetes manifests
- Values:
  Environment-specific configuration
- Template:
  Manifest with variables
- Release:
  Installed instance of a chart
- Upgrade:
  Apply a new version
- Rollback:
  Return to a previous release
- Lint:
  Validate chart quality

### What to learn
- Helm avoids repeating raw YAML for each environment
- `values-dev.yaml` and `values-prod.yaml` separate environment settings
- Helm release history supports rollback
- Helm works well in CI/CD pipelines

## Phase 8: Azure DevOps Pipeline

### Pipeline Stages

```text
1. Validate
2. Build frontend image
3. Build API image
4. Build worker image
5. Push images to ACR
6. Scan or validate images
7. Helm lint
8. Deploy to AKS dev
9. Run smoke tests
10. Approval
11. Deploy to production
```

### Pipeline Concepts

- Azure Repos stores source code
- Azure Pipelines builds and deploys
- Service connection authenticates to Azure
- Variable groups store common settings
- Key Vault integration stores secrets
- Environments can enforce approvals

### What to learn
- CI validates code and builds images
- CD deploys images using Helm
- Approvals protect production
- Rollback should use previous Helm release or previous image tag

## Phase 9: Monitoring and Logging

### Configure

- Azure Monitor for containers
- Log Analytics Workspace
- Application Insights for API
- Diagnostic settings for AKS, Key Vault, Storage, and SQL
- Alerts for CPU, pod restarts, failed requests, and SQL DTU/vCore usage

### Useful KQL Queries

```kusto
ContainerLogV2
| where PodNamespace == "cloudshop-dev"
| take 20
```

```kusto
KubePodInventory
| where Namespace == "cloudshop-dev"
| summarize count() by PodStatus
```

### What to learn
- Metrics show what changed
- Logs help explain why it changed
- Alerts notify teams before users report issues
- Diagnostic settings must be enabled for many logs

## Phase 10: K9s Operations

K9s is a terminal UI for Kubernetes operations. Use it to inspect the AKS cluster faster than typing many `kubectl` commands.

### High-Level K9s Topics

| K9s Topic | What to Practice |
| --- | --- |
| Contexts | Switch between clusters |
| Namespaces | Filter to `cloudshop-dev` |
| Pods | View pod status, restarts, age |
| Logs | Stream frontend, API, and worker logs |
| Describe | Inspect events and scheduling issues |
| Services | Check ClusterIP and LoadBalancer services |
| Ingress | Confirm host and routing rules |
| Deployments | Check replicas and rollout status |
| Secrets and ConfigMaps | Verify names and mounted config |
| Port forward | Test internal services locally |
| Resource usage | Check CPU and memory if metrics server is enabled |
| Delete and restart | Delete a pod and watch deployment recreate it |

### Common K9s Shortcuts

| Action | Shortcut |
| --- | --- |
| Show pods | `:pods` |
| Show deployments | `:deploy` |
| Show services | `:svc` |
| Show ingress | `:ing` |
| Show namespaces | `:ns` |
| View logs | Select pod, press `l` |
| Describe resource | Select resource, press `d` |
| Delete resource | Select resource, press `ctrl-d` |
| Port forward | Select pod, press `shift-f` |
| Change namespace | `:ns`, then select namespace |

### What to learn
- K9s is useful for real-time troubleshooting
- Pod events often explain image pull, scheduling, or probe failures
- Logs help identify application issues
- Restarting a pod is not a root cause fix; it is only a recovery action

## Phase 11: Backup, DR, and High Availability

### High Availability Design

- Use multiple replicas for frontend and API
- Use readiness and liveness probes
- Use zone-aware AKS node pools where available
- Use Azure SQL backup and optional geo-replication
- Store images in ACR
- Keep IaC and Helm charts in Git

### RPO and RTO Example

| Area | Example Target |
| --- | --- |
| SQL data RPO | 15 minutes |
| Application restore RTO | 1 hour |
| AKS redeploy RTO | 30-60 minutes using IaC and Helm |
| Blob restore RPO | Based on storage redundancy and backup strategy |

### What to learn
- Backup and DR are not the same
- RPO means acceptable data loss
- RTO means acceptable downtime
- Runbooks and restore testing are required

## Phase 12: Governance and Cost Control

### Configure

- Tags on all resources
- Budget alerts
- Azure Policy for required tags
- Resource locks for shared resources
- Naming standards
- Defender for Cloud recommendations

### What to learn
- Governance keeps cloud usage controlled
- Budgets alert but do not automatically stop spending
- Policy can audit or deny non-compliant resources
- Locks protect important resources from accidental deletion

## Project Interview Explanation

Use this short explanation in interviews:

```text
I worked on a full-stack Azure project with a frontend, backend API, and worker service deployed to AKS. Images were stored in Azure Container Registry and deployed using Helm. The API used Azure SQL Database for relational data, Blob Storage for files, and a queue for asynchronous order processing. Secrets were stored in Key Vault and accessed using managed identity. The environment was provisioned using IaC, deployed through Azure DevOps pipelines, monitored with Azure Monitor and Log Analytics, and operated using kubectl and K9s.
```

## Suggested Folder Structure for a Real Implementation

```text
cloudshop/
  frontend/
    Dockerfile
    src/
  api/
    Dockerfile
    src/
  worker/
    Dockerfile
    src/
  infra/
    bicep/
    terraform/
  helm/
    cloudshop/
      Chart.yaml
      values.yaml
      values-dev.yaml
      templates/
  pipelines/
    azure-pipelines.yml
  docs/
    architecture.md
    runbook.md
```

## Final Cleanup Checklist

- Delete AKS cluster
- Delete ACR if created only for practice
- Delete SQL Database and SQL Server
- Delete Storage Account
- Delete Key Vault
- Delete Log Analytics Workspace if not needed
- Delete public IPs and load balancers
- Delete resource groups
- Check Cost Management after cleanup

## Final Tip

This project is strong for interviews because it lets you explain the full cloud lifecycle: design, deploy, secure, monitor, troubleshoot, scale, backup, and clean up.
