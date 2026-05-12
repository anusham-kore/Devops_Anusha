# Kubernetes + Docker

Most important. Prepare these thoroughly.

## Kubernetes Concepts

### Pod Lifecycle
- **Stages**: Pending → Running → Succeeded/Failed.
- **Explanation**: Pods are the smallest deployable units. Lifecycle managed by kubelet.
- **Real-Time Scenario**: Pod stuck in Pending due to insufficient resources. Check with `kubectl describe pod` for events like "Insufficient CPU."

### Deployment
- **Explanation**: Manages replica sets for rolling updates and rollbacks.
- **Commands**: `kubectl create deployment`, `kubectl rollout status`.
- **Real-Time Scenario**: Update app version without downtime. Use `kubectl set image deployment/app container=new-image` and monitor rollout.

### Service Types
- **ClusterIP**: Internal access.
- **NodePort**: External via node IP.
- **LoadBalancer**: Cloud provider LB.
- **Real-Time Scenario**: Expose app externally. Use LoadBalancer service; in AWS, it provisions an ELB.

### Ingress
- **Explanation**: Manages external access to services, with routing rules.
- **Real-Time Scenario**: Route traffic based on paths. Configure Ingress with annotations for SSL termination.

### ConfigMap vs Secret
- **ConfigMap**: Non-sensitive config data (e.g., env vars).
- **Secret**: Sensitive data (e.g., passwords), base64 encoded.
- **Real-Time Scenario**: Store DB credentials in Secret; mount ConfigMap for app config.

### HPA (Horizontal Pod Autoscaler)
- **Explanation**: Scales pods based on CPU/memory metrics.
- **Real-Time Scenario**: Traffic spike during sale. HPA scales from 3 to 10 pods automatically.

### Liveness vs Readiness Probes
- **Liveness**: Restarts container if unhealthy.
- **Readiness**: Removes from service if not ready.
- **Real-Time Scenario**: App slow to start. Use Readiness probe to delay traffic until ready.

### StatefulSet
- **Explanation**: For stateful apps needing persistent identity (e.g., databases).
- **Real-Time Scenario**: Deploy MySQL cluster with persistent volumes.

### PV/PVC
- **PV**: Persistent storage.
- **PVC**: Request for storage.
- **Real-Time Scenario**: App needs persistent data. Create PVC; Kubernetes binds to PV.

## Troubleshooting

- **CrashLoopBackOff**: Container exits repeatedly. Check logs: `kubectl logs pod-name`.
- **OOMKilled**: Out of memory. Increase limits in deployment YAML.
- **Pending Pod**: Resource issues. Check node capacity.
- **ImagePullBackOff**: Image not found. Verify registry access.
- **Node Not Ready**: Node issues. Check `kubectl get nodes`.

## Commands

- `kubectl get pods`: List pods.
- `kubectl describe pod`: Detailed info.
- `kubectl logs`: View logs.
- `kubectl exec -it`: Shell into pod.
- `kubectl top pod`: Resource usage.

## Docker Integration
- **Real-Time Scenario**: Build and push image: `docker build -t app . && docker push registry/app`.
- Use in Kubernetes: Reference image in deployment YAML.