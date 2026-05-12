# Docker & Kubernetes

Focus: Containerization, orchestration.

## Key Concepts
- **Docker**: Build, ship, run containers. Dockerfile, images, containers.
- **Kubernetes**: Orchestrate containers. Pods, deployments, services.

## Commands/Examples
Docker: `docker build -t image .`, `docker run -p 8080:80 image`
K8s: `kubectl apply -f deployment.yaml`, `kubectl get pods`

Deployment YAML:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: app:latest
        ports:
        - containerPort: 80
```

## Real-Time Scenarios
- **Scenario 1**: Scale app. Use HPA for auto-scaling.
- **Scenario 2**: Persistent storage. PVC for DB data.
- **Scenario 3**: Networking. Services for internal/external access.
- **Scenario 4**: Troubleshooting. Check pod logs, describe for issues.