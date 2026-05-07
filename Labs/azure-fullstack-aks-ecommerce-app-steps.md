# CloudShop Ecommerce App on AKS - Frontend, Backend, Worker, DNS, and LoadBalancer

This file deploys a small ecommerce-style demo app to the AKS cluster created in `azure-fullstack-aks-cli-steps.md`.

It creates:

- Frontend pod: displays product data in a browser
- Backend API pod: returns product and order JSON
- Middle-tier worker pod: simulates order processing
- LoadBalancer service: exposes the frontend publicly
- DNS URL: uses the public IP with `nip.io`

This is a lightweight learning app. It acts like a 3-tier ecommerce app without needing to build Docker images first.

Important: in this no-build demo, the displayed product and order data is stored in Kubernetes ConfigMaps and served by the backend nginx pod. Azure SQL is still part of the full CloudShop architecture, but this specific demo does not read from SQL because it uses only ready-made container images.

To make the app truly SQL-backed, replace the nginx backend with a real API container such as Node.js, .NET, Java, or Python. That API should read from Azure SQL using the `SqlConnectionString` secret stored in Key Vault or Kubernetes Secret.

## Architecture

```text
Browser
  |
  v
Azure LoadBalancer public IP / nip.io DNS
  |
  v
cloudshop-frontend service
  |
  v
Frontend nginx pod
  |
  +--> /api/products -> cloudshop-api service
  +--> /api/orders   -> cloudshop-api service

cloudshop-api pod
  |
  v
Returns ecommerce JSON data from ConfigMap in this no-build demo

Azure SQL Database
  |
  v
Stores real CloudShop tables and data from the infrastructure runbook

cloudshop-worker pod
  |
  v
Simulates processing orders from a middle tier
```

## 1. Confirm AKS Access

```powershell
az aks get-credentials `
  --resource-group $RG `
  --name $AKS `
  --overwrite-existing
```

```powershell
kubectl get nodes
```

## 2. Create Namespace

```powershell
kubectl create namespace cloudshop-dev
```

If the namespace already exists, that is fine.

## 3. Remove Old Test nginx App

Run this only if you already deployed the earlier `cloudshop-test` app.

```powershell
kubectl delete deployment cloudshop-test -n cloudshop-dev --ignore-not-found
kubectl delete service cloudshop-test -n cloudshop-dev --ignore-not-found
```

## 4. Create Backend API Data

This ConfigMap stores ecommerce data that the backend API will display.

This is demo-only storage. The data is inside Kubernetes, not Azure SQL.

```powershell
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudshop-api-data
  namespace: cloudshop-dev
data:
  products.json: |
    {
      "products": [
        {
          "id": 1,
          "name": "Developer Laptop",
          "description": "Laptop for Azure, Docker, Kubernetes, and DevOps labs",
          "price": 75000,
          "stock": 10,
          "image": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80"
        },
        {
          "id": 2,
          "name": "Wireless Mouse",
          "description": "Comfortable mouse for daily cloud engineering work",
          "price": 800,
          "stock": 50,
          "image": "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=900&q=80"
        },
        {
          "id": 3,
          "name": "Mechanical Keyboard",
          "description": "Keyboard for writing scripts, YAML, and Terraform",
          "price": 2500,
          "stock": 25,
          "image": "https://images.unsplash.com/photo-1541140532154-b024d705b90a?auto=format&fit=crop&w=900&q=80"
        },
        {
          "id": 4,
          "name": "Laptop Backpack",
          "description": "Backpack for carrying your cloud lab setup",
          "price": 1800,
          "stock": 15,
          "image": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=900&q=80"
        }
      ]
    }
  orders.json: |
    {
      "orders": [
        {
          "id": 101,
          "customer": "Anusha Maddela",
          "status": "Pending",
          "total": 75800,
          "items": ["Developer Laptop", "Wireless Mouse"]
        },
        {
          "id": 102,
          "customer": "Demo Customer",
          "status": "Processing",
          "total": 4300,
          "items": ["Mechanical Keyboard", "Laptop Backpack"]
        }
      ]
    }
'@ | kubectl apply -f -
```

## 5. Where Azure SQL Fits

In the full project, Azure SQL stores the real ecommerce data:

```text
Users
Products
Orders
OrderItems
```

Those tables and sample records are created in [azure-fullstack-aks-cli-steps.md](azure-fullstack-aks-cli-steps.md), section **9. Create Tables and Sample Data**.

This file uses ConfigMap data only so you can deploy frontend, backend, worker, LoadBalancer, and DNS without building custom Docker images.

For a production-style version:

1. Build a backend API image, for example `cloudshop-api`.
2. Push it to ACR.
3. Attach ACR to AKS.
4. Store the SQL connection string in Key Vault or a Kubernetes Secret.
5. Update the backend deployment to use the custom API image.
6. The frontend should call that backend API, and the backend should query Azure SQL.

Example backend behavior:

```text
GET /api/products -> SELECT ProductId, Name, Description, Price, Stock FROM Products
GET /api/orders   -> SELECT order data from Orders and OrderItems
POST /api/orders  -> INSERT order, then send message to queue
Worker            -> Reads queue message and updates Orders.OrderStatus
```

## 6. Create Backend API nginx Config

The backend uses nginx to serve JSON endpoints from the ConfigMap.

```powershell
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudshop-api-nginx
  namespace: cloudshop-dev
data:
  default.conf: |
    server {
      listen 8080;
      server_name _;

      add_header Access-Control-Allow-Origin "*" always;
      add_header Content-Type application/json;

      location /api/products {
        alias /usr/share/nginx/html/products.json;
      }

      location /api/orders {
        alias /usr/share/nginx/html/orders.json;
      }

      location /health {
        return 200 '{"status":"healthy","service":"cloudshop-api"}';
      }
    }
'@ | kubectl apply -f -
```

## 7. Deploy Backend API Pod

```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudshop-api
  namespace: cloudshop-dev
  labels:
    app: cloudshop-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudshop-api
  template:
    metadata:
      labels:
        app: cloudshop-api
        tier: backend
    spec:
      containers:
      - name: api
        image: nginx:1.27-alpine
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: api-nginx
          mountPath: /etc/nginx/conf.d
        - name: api-data
          mountPath: /usr/share/nginx/html
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 20
      volumes:
      - name: api-nginx
        configMap:
          name: cloudshop-api-nginx
      - name: api-data
        configMap:
          name: cloudshop-api-data
---
apiVersion: v1
kind: Service
metadata:
  name: cloudshop-api
  namespace: cloudshop-dev
spec:
  type: ClusterIP
  selector:
    app: cloudshop-api
  ports:
  - name: http
    port: 8080
    targetPort: 8080
'@ | kubectl apply -f -
```

## 8. Create Frontend App

The frontend displays product cards and recent orders. It calls the backend through `/api/products` and `/api/orders`.

```powershell
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudshop-frontend-html
  namespace: cloudshop-dev
data:
  index.html: |
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>CloudShop</title>
      <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #f4f7fb; color: #172033; }
        header { background: #0f766e; color: white; padding: 22px 32px; }
        header h1 { margin: 0; font-size: 30px; }
        header p { margin: 6px 0 0; color: #d9fffb; }
        main { max-width: 1180px; margin: 0 auto; padding: 28px; }
        .status { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 24px; }
        .pill { background: white; border: 1px solid #d8e3ed; border-radius: 6px; padding: 10px 12px; font-weight: 700; }
        h2 { margin: 28px 0 14px; font-size: 22px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 16px; }
        .card { background: white; border: 1px solid #d8e3ed; border-radius: 8px; overflow: hidden; }
        .card img { width: 100%; height: 150px; object-fit: cover; display: block; }
        .card-body { padding: 14px; }
        .card h3 { margin: 0 0 8px; font-size: 18px; }
        .card p { margin: 0 0 12px; color: #4b5b70; line-height: 1.4; }
        .price { font-size: 20px; font-weight: 800; color: #0f766e; }
        .stock { color: #64748b; font-size: 14px; margin-top: 6px; }
        table { width: 100%; border-collapse: collapse; background: white; border: 1px solid #d8e3ed; border-radius: 8px; overflow: hidden; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #e6edf4; }
        th { background: #eef6f6; }
        .error { color: #b42318; background: #fff1f0; border: 1px solid #ffccc7; padding: 12px; border-radius: 6px; }
      </style>
    </head>
    <body>
      <header>
        <h1>CloudShop</h1>
        <p>AKS ecommerce demo with frontend, backend API, worker, LoadBalancer, and DNS</p>
      </header>
      <main>
        <section class="status">
          <div class="pill">Frontend: nginx pod</div>
          <div class="pill">Backend: cloudshop-api service</div>
          <div class="pill">Middle tier: cloudshop-worker pod</div>
        </section>

        <h2>Products</h2>
        <div id="products" class="grid"></div>

        <h2>Recent Orders</h2>
        <div id="orders"></div>
      </main>
      <script>
        const rupees = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' });

        async function loadProducts() {
          const response = await fetch('/api/products');
          const data = await response.json();
          document.getElementById('products').innerHTML = data.products.map(product => `
            <article class="card">
              <img src="${product.image}" alt="${product.name}">
              <div class="card-body">
                <h3>${product.name}</h3>
                <p>${product.description}</p>
                <div class="price">${rupees.format(product.price)}</div>
                <div class="stock">${product.stock} in stock</div>
              </div>
            </article>
          `).join('');
        }

        async function loadOrders() {
          const response = await fetch('/api/orders');
          const data = await response.json();
          document.getElementById('orders').innerHTML = `
            <table>
              <thead>
                <tr><th>Order</th><th>Customer</th><th>Status</th><th>Items</th><th>Total</th></tr>
              </thead>
              <tbody>
                ${data.orders.map(order => `
                  <tr>
                    <td>#${order.id}</td>
                    <td>${order.customer}</td>
                    <td>${order.status}</td>
                    <td>${order.items.join(', ')}</td>
                    <td>${rupees.format(order.total)}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          `;
        }

        Promise.all([loadProducts(), loadOrders()]).catch(error => {
          document.querySelector('main').insertAdjacentHTML('beforeend', `<p class="error">Could not load API data: ${error}</p>`);
        });
      </script>
    </body>
    </html>
'@ | kubectl apply -f -
```

## 9. Create Frontend nginx Reverse Proxy

The frontend proxies API calls to the backend service inside the cluster.

```powershell
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudshop-frontend-nginx
  namespace: cloudshop-dev
data:
  default.conf: |
    server {
      listen 80;
      server_name _;
      root /usr/share/nginx/html;
      index index.html;

      location / {
        try_files $uri $uri/ /index.html;
      }

      location /api/ {
        proxy_pass http://cloudshop-api:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      }
    }
'@ | kubectl apply -f -
```

## 10. Deploy Frontend Pod with Public LoadBalancer

```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudshop-frontend
  namespace: cloudshop-dev
  labels:
    app: cloudshop-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudshop-frontend
  template:
    metadata:
      labels:
        app: cloudshop-frontend
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: frontend-html
          mountPath: /usr/share/nginx/html
        - name: frontend-nginx
          mountPath: /etc/nginx/conf.d
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 20
      volumes:
      - name: frontend-html
        configMap:
          name: cloudshop-frontend-html
      - name: frontend-nginx
        configMap:
          name: cloudshop-frontend-nginx
---
apiVersion: v1
kind: Service
metadata:
  name: cloudshop-frontend
  namespace: cloudshop-dev
spec:
  type: LoadBalancer
  selector:
    app: cloudshop-frontend
  ports:
  - name: http
    port: 80
    targetPort: 80
'@ | kubectl apply -f -
```

## 11. Deploy Middle-Tier Worker Pod

The worker simulates background order processing.

```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudshop-worker
  namespace: cloudshop-dev
  labels:
    app: cloudshop-worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudshop-worker
  template:
    metadata:
      labels:
        app: cloudshop-worker
        tier: middle-tier
    spec:
      containers:
      - name: worker
        image: busybox:1.36
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            echo "$(date) CloudShop worker: checking orders-to-process queue";
            echo "$(date) CloudShop worker: processed pending ecommerce orders";
            sleep 20;
          done
'@ | kubectl apply -f -
```

## 12. Verify Pods and Services

```powershell
kubectl get pods -n cloudshop-dev -o wide
```

```powershell
kubectl get svc -n cloudshop-dev
```

Expected resources:

```text
cloudshop-frontend deployment and LoadBalancer service
cloudshop-api deployment and ClusterIP service
cloudshop-worker deployment
```

Check worker logs:

```powershell
kubectl logs deployment/cloudshop-worker -n cloudshop-dev
```

Test backend from inside the cluster:

```powershell
kubectl run api-test `
  --rm `
  -i `
  --restart=Never `
  --image=curlimages/curl `
  --namespace cloudshop-dev `
  -- http://cloudshop-api:8080/api/products
```

## 13. Get LoadBalancer IP and DNS URL

Wait for the public IP:

```powershell
kubectl get svc cloudshop-frontend -n cloudshop-dev
```

Store the IP:

```powershell
$APP_IP = kubectl get svc cloudshop-frontend -n cloudshop-dev -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
$APP_IP
```

Open the app using public IP:

```text
http://<APP_IP>
```

Use automatic DNS with `nip.io`:

```powershell
$APP_DNS = "$APP_IP.nip.io"
$APP_DNS
```

Open:

```text
http://<APP_IP>.nip.io
```

Example:

```text
http://20.219.241.104.nip.io
```

`nip.io` automatically maps the DNS name to the IP address. This is useful for learning DNS behavior without buying a domain.

## 14. Optional: Create Azure DNS Name Label for the LoadBalancer Public IP

Azure creates a public IP resource for the Kubernetes LoadBalancer service. You can add a DNS label to it.

Find the public IP resource:

```powershell
$NODE_RG = az aks show --resource-group $RG --name $AKS --query nodeResourceGroup -o tsv
$LB_IP = kubectl get svc cloudshop-frontend -n cloudshop-dev -o jsonpath="{.status.loadBalancer.ingress[0].ip}"

az network public-ip list `
  --resource-group $NODE_RG `
  --query "[?ipAddress=='$LB_IP'].[name, ipAddress, dnsSettings.fqdn]" `
  --output table
```

Set a DNS label. The label must be globally unique in the Azure region.

```powershell
$PUBLIC_IP_NAME = az network public-ip list `
  --resource-group $NODE_RG `
  --query "[?ipAddress=='$LB_IP'].name" `
  -o tsv

$DNS_LABEL = "cloudshop-anusha-demo"

az network public-ip update `
  --resource-group $NODE_RG `
  --name $PUBLIC_IP_NAME `
  --dns-name $DNS_LABEL
```

Get the Azure DNS name:

```powershell
az network public-ip show `
  --resource-group $NODE_RG `
  --name $PUBLIC_IP_NAME `
  --query dnsSettings.fqdn `
  -o tsv
```

The result will look similar to:

```text
cloudshop-anusha-demo.centralindia.cloudapp.azure.com
```

## 15. Browser Verification

Open the app and confirm:

- Product cards are displayed.
- Recent orders table is displayed.
- Page URL uses either the LoadBalancer IP, `nip.io`, or Azure DNS label.
- Browser may show `Not secure` because this lab uses HTTP.

## 16. Troubleshooting

Check all resources:

```powershell
kubectl get all -n cloudshop-dev
```

Check frontend logs:

```powershell
kubectl logs deployment/cloudshop-frontend -n cloudshop-dev
```

Check backend logs:

```powershell
kubectl logs deployment/cloudshop-api -n cloudshop-dev
```

Check backend API service:

```powershell
kubectl describe svc cloudshop-api -n cloudshop-dev
```

If the frontend page loads but product data does not appear, check that the backend pod is running:

```powershell
kubectl get pods -n cloudshop-dev -l app=cloudshop-api
```

## 17. Cleanup Only the App

Use this if you want to remove only the ecommerce app but keep AKS and Azure resources.

```powershell
kubectl delete namespace cloudshop-dev
```

## 18. Cleanup Full Azure Lab

Use this after practice to stop Azure charges.

```powershell
az group delete `
  --name $RG `
  --yes `
  --no-wait
```

Check deletion:

```powershell
az group exists --name $RG
```

If the output is `false`, the full lab resource group has been deleted.

## Interview Explanation

I deployed a 3-tier ecommerce-style application to AKS. The frontend was exposed publicly through an Azure LoadBalancer and accessed through a DNS name. The frontend called an internal backend API service, and a separate worker deployment simulated middle-tier background order processing. Product and order data were displayed in the browser, and Kubernetes services separated public access from internal service-to-service communication.
