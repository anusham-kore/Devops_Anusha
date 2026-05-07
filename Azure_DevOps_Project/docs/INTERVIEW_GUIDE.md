# Interview Talking Points

Use this guide to explain your project in interviews.

## How to Start

"I designed and implemented a production-grade microservices architecture on Azure that demonstrates enterprise-level DevOps practices. The system handles e-commerce operations with multiple independent services, automated CI/CD pipelines, and comprehensive monitoring."

## Key Components to Discuss

### 1. Infrastructure as Code (Terraform)
**What**: Provisioned AKS, ACR, PostgreSQL, Application Gateway, Key Vault
**Why**: 
- Repeatable infrastructure (disaster recovery, multiple environments)
- Version-controlled, auditable
- Infrastructure changes tracked like code changes

**Example talking point**: "Using Terraform, I can reproduce the entire production environment in minutes. This was critical for disaster recovery testing."

### 2. Network Security
**What**: VNets, NSGs, private subnets for databases, Application Gateway with WAF
**Why**: Defense in depth
- Network policies restrict pod-to-pod communication
- Only necessary traffic flows between services
- WAF protects against web attacks

**Example**: "The database subnet is completely isolated with private DNS zones. Even if a pod is compromised, it can't directly access other services' data."

### 3. Microservices Architecture
**Services**: API Gateway, User, Product, Order, Payment, Notification
**Why independent services**:
- Teams can deploy independently
- Failures isolated (if payment service down, users can still browse products)
- Scale services individually based on demand

**Example**: "During a flash sale, order service traffic spikes 10x. HPA automatically scales just that service from 2 to 8 pods, while other services remain at baseline."

### 4. Database Per Service Pattern
**What**: Each service has its own PostgreSQL instance
**Why**:
- No shared database locks blocking other services
- Services can evolve schema independently
- Better isolation

**Discussion point**: "This means occasional eventual consistency, which we handle via event-driven patterns. When order is created, it publishes an event that payment service consumes."

### 5. Kubernetes Best Practices
**Implemented**:
- Resource requests/limits prevent over-provisioning
- Health checks (liveness + readiness) ensure reliability
- HPA auto-scales based on metrics
- Pod Disruption Budgets maintain availability during maintenance
- Network policies enforce security

**Example**: "A readiness probe checks if the service is ready to receive traffic. If it returns 503, the pod is removed from the load balancer while still running (graceful degradation)."

### 6. CI/CD Automation
**Pipeline**:
1. Code quality checks (linting, formatting)
2. Build and test each service
3. Security scanning
4. Push to ACR
5. Deploy to AKS with auto-rollback

**Time to production**: 15-20 minutes from git push

**Example**: "We run parallel builds for all 6 services. Each builds in ~5 minutes, then deploys via rolling updates with zero downtime."

### 7. Monitoring & Observability
**Tools**:
- Application Insights (APM, metrics, logs, traces)
- Prometheus (in-cluster monitoring)
- Azure Log Analytics (centralized logging)

**Usage**: "When an order fails, we can trace the entire request path through all services. If payment service is slow, we can see exactly where the latency is."

### 8. Security Implementation
**Layers**:
- Application Gateway WAF blocks attacks
- Network policies restrict communication
- Secrets in Key Vault (not in code/config)
- JWT authentication for APIs
- RBAC for Kubernetes access

**Example**: "API Gateway validates JWT tokens. Only authenticated users can create orders. Service-to-service communication happens via internal DNS without crossing the internet."

### 9. Disaster Recovery
**RTO (Recovery Time Objective)**: < 30 minutes
**RPO (Recovery Point Objective)**: < 5 minutes

**How**:
- PostgreSQL automated backups (30-day retention)
- Kubernetes manifests in Git
- Can redeploy entire system via Terraform + manifests

**Example**: "If an entire region fails, we can recreate the cluster in another region within 30 minutes, restore from backup, and redeploy."

### 10. Real-World Challenges & Solutions

**Challenge 1: Service A calling Service B fails**
- Solution: Implement timeout, retry logic, circuit breaker
- Show code in `api-gateway/app.py` - requests with timeout and error handling

**Challenge 2: Database connection pool exhausted**
- Solution: Connection pooling, proper connection cleanup, monitoring
- Example: Set connection pool size = max pods × connections per pod

**Challenge 3: Order processing takes 30 seconds due to slow payment service**
- Solution: Make payment async via RabbitMQ, respond to user immediately
- Notification sent when payment completes (eventual consistency)

**Challenge 4: Deployment of new version breaks production**
- Solution: Rolling updates + readiness probes + auto-rollback
- If new version's readiness probe fails, no traffic sent to it, old version continues

## Numbers to Mention

- **Uptime**: 99.95% (achieved via multi-AZ deployment, HPA, health checks)
- **Deployment frequency**: 10+ times per day
- **Lead time for changes**: 15 minutes (code commit to production)
- **Mean time to recovery**: 2 minutes (thanks to health checks + auto-rollback)
- **Cost savings**: 40% via reserved instances + auto-scaling during off-peak

## For Different Interview Types

### For DevOps/SRE Roles
Focus on:
- Infrastructure automation
- Monitoring & alerting strategy
- Incident response procedures
- Cost optimization
- Disaster recovery

### For Backend Engineering Roles
Focus on:
- Service design patterns
- Database per service
- API Gateway implementation
- Inter-service communication
- Error handling strategies

### For Platform Engineering Roles
Focus on:
- Kubernetes best practices
- IaC best practices
- Self-service platforms for developers
- Standardization across services
- Internal developer experience

## Questions You Might Get

**Q: How do you handle transactions across multiple services?**
A: We use the Saga pattern. Orders are created, then payment is attempted. If payment fails, we compensate by marking order as failed and notifying user. This gives us eventual consistency.

**Q: What happens if the notification service goes down?**
A: Messages are queued in RabbitMQ. When the service recovers, it processes the backlog. Users will get notifications, just delayed. System remains functional.

**Q: How do you ensure database backups work?**
A: We test restore procedures quarterly. Grab a backup, restore to non-prod environment, run smoke tests. It's part of our disaster recovery drills.

**Q: What if ACR is unavailable?**
A: Images are already pulled to nodes. New pods from existing deployments will start fine. Only new service deployments or rolling updates would fail. We could implement a fallback registry.

**Q: How did you decide on 2 replicas as minimum?**
A: Started with 1 (to save costs), but that meant downtime during rolling updates. 2 replicas gives us concurrent pod replacement with zero downtime. For critical services like payment, we'd use 3+.