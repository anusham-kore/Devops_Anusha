# Production Architecture & Best Practices

## Infrastructure Architecture

### Network Architecture
```
Internet
  ↓
[Azure Application Gateway with WAF]
  ↓
[AKS Cluster - 3 Availability Zones]
  ├── API Gateway (entry point)
  ├── User Service (stateless)
  ├── Product Service (stateless)
  ├── Order Service (stateless, connected to PostgreSQL)
  ├── Payment Service (stateless, connected to PostgreSQL)
  ├── Notification Service (event-driven, connects to RabbitMQ)
  ├── Prometheus (monitoring)
  └── ConfigMaps & Secrets
```

### Database Architecture
- **Separate PostgreSQL instances** per service (loose coupling)
- **Private DNS zones** for internal communication
- **Private subnets** with restricted access
- **Automated backups** (30-day retention)

### Security Layers
1. **Network Level**: VNet, NSGs, Network Policies
2. **Container Level**: ImagePullPolicy, Resource Limits, Security Context
3. **Application Level**: JWT authentication, Authorization headers
4. **Data Level**: Encryption at rest/transit, Key Vault integration

## Microservices Design Patterns

### 1. API Gateway Pattern
- Single entry point for all clients
- Handles authentication, rate limiting, routing
- Located at `services/api-gateway`

### 2. Database per Service
- Each service has independent database
- Prevents tight coupling
- Enables independent scaling and updates

### 3. Eventual Consistency
- Services communicate asynchronously via RabbitMQ
- E.g., Order created → Payment processed → Notification sent
- Improves resilience (if one service is down, others continue)

### 4. Circuit Breaker
- Implemented in service clients
- Prevents cascading failures
- Fallback mechanisms in API Gateway

### 5. Health Checks
- **Liveness Probes**: Restart unhealthy pods
- **Readiness Probes**: Remove unhealthy pods from service
- Both implemented with 30s initial delay, 10s period

## Kubernetes Best Practices

### Resource Management
- **Requests**: Guaranteed minimum (scheduler uses this for placement)
- **Limits**: Maximum allowed (pod terminated if exceeded)
- Both set to prevent over-provisioning

### Scaling
- **HPA**: Auto-scales based on CPU/memory metrics
- **PDB**: Pod Disruption Budgets ensure minimum availability during node maintenance

### Rolling Updates
- `maxSurge: 1`: One extra pod during rollout
- `maxUnavailable: 0`: Zero downtime updates

### Network Policies
- Default deny ingress (pod isolation)
- Allow only necessary traffic between services
- Reduces attack surface

## Monitoring & Observability

### Application Insights
- Collects metrics, traces, logs
- Custom dashboards for business metrics
- Alerts on critical errors/anomalies

### Prometheus
- Scrapes metrics from Kubernetes and applications
- Integrated with Grafana for visualization
- Useful for historical analysis

### Logging
- Azure Log Analytics workspace
- All pod logs centralized
- Query with KQL for troubleshooting

## CI/CD Pipeline

### Code Quality
- Linting (flake8)
- Formatting (black)
- Security audit (safety)

### Build & Test
- Multi-service parallel builds
- Docker BuildKit for optimization
- Test execution before push

### Push & Deploy
- ACR image tagging with git SHA
- Automated image scanning
- Rolling deployment to AKS

### Rollback
- Automatic on deployment failure
- Manual rollback: `kubectl rollout undo deployment/name`

## Operational Procedures

### Adding a New Service
1. Create service in `services/new-service/`
2. Add Dockerfile
3. Create K8s deployment/service manifests
4. Update CI/CD workflow
5. Add to Terraform if new database needed

### Updating Dependencies
1. Modify `requirements.txt`
2. Rebuild Docker image
3. Test locally
4. Push to ACR
5. Rolling update in AKS

### Incident Response
1. **Detection**: Alert from Azure Monitor
2. **Investigation**: Check logs, metrics, pod status
3. **Mitigation**: Scale, rollback, or patch
4. **Resolution**: Fix root cause
5. **Post-Mortem**: Document and improve

### Backup & Disaster Recovery
- PostgreSQL: 30-day automated backups
- Point-in-time restore available
- Kubernetes manifests in Git (source of truth)
- Test recovery periodically

## Cost Optimization

### Reserved Instances
- Use for predictable baseline capacity
- Significant discounts (30-72% savings)

### Auto-Scaling
- Scale down during off-peak hours
- Reduces compute costs during low traffic

### Resource Right-Sizing
- Monitor actual usage
- Adjust requests/limits based on data
- Remove unnecessary services

## Security Checklist

- [ ] Network policies enabled
- [ ] Pod security policies enforced
- [ ] RBAC configured correctly
- [ ] Secrets in Key Vault (not in code)
- [ ] TLS enabled for all communications
- [ ] Image scanning in CI/CD
- [ ] Regular security audits
- [ ] Least privilege access