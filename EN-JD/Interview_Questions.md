Azure + DevOps + Kubernetes Interview Questions for Evernorth JD

These questions are based directly on:

Your Terraform Azure architecture
AKS
CI/CD
Python
Kubernetes
Monitoring
Platform engineering
Production troubleshooting
1. Explain This Architecture End-to-End ⭐⭐⭐
Question

Explain your Azure infrastructure architecture.

Answer Flow
Internet
 ↓
Azure DNS
 ↓
Application Gateway + WAF
 ↓
AKS Cluster
 ↓
Microservices Pods
 ↓
PostgreSQL Flexible Server

Also mention:

ACR stores Docker images
Key Vault stores secrets
Log Analytics + App Insights for monitoring
NSGs for security
VNet isolation
Terraform for IaC
2. Why Separate Subnets?
Question

Why did you create separate subnets for AKS, App Gateway, and DB?

Answer

For:

security isolation
traffic control
subnet-level NSGs
better routing
Azure requirement for Application Gateway

Example:

DB subnet private only
App Gateway public-facing
AKS internal workload subnet
3. Why Use Application Gateway Instead of Load Balancer?
Answer

Application Gateway is Layer 7.

Supports:

path-based routing
SSL termination
WAF
host-based routing
URL rewrite

Azure Load Balancer is Layer 4 only.

4. What is WAF?
Answer

Web Application Firewall protects applications from:

SQL injection
XSS attacks
OWASP vulnerabilities

In this Terraform:

tier = "WAF_v2"
5. Explain AKS Networking
Question

What networking model are you using in AKS?

Answer

Azure CNI:

network_plugin = "azure"

Each pod gets VNet IP address directly.

Benefits:

easier communication
enterprise networking
private connectivity
6. Why Use Managed Identity?
Answer

Avoid storing credentials inside code/pods.

AKS securely accesses:

Key Vault
Storage
Azure APIs

Equivalent to IAM role in AWS.

7. Scenario — Pod Restarting Continuously ⭐⭐⭐
Question

A pod is continuously restarting. How will you debug?

Answer

Steps:

kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>

Check:

CrashLoopBackOff
memory issue
probes
environment variables
DB connectivity
image issue

Also:

kubectl top pod

to verify resource usage.

8. Scenario — App Not Accessible Externally
Answer Flow

Check:

Ingress
Service type
App Gateway backend health
NSG rules
DNS mapping
Pod readiness
Listener/routing rules
9. Why Use Log Analytics Workspace?
Answer

Centralized logging and monitoring.

Stores:

AKS logs
container logs
metrics
diagnostics

Used for troubleshooting and observability.

10. Difference Between App Insights and Log Analytics
App Insights	Log Analytics
Application monitoring	Central log storage
API latency	Infrastructure logs
Exceptions	Kusto queries
Request tracing	AKS diagnostics
11. Scenario — High CPU in AKS
Answer

Check:

kubectl top pod
kubectl top node

Then:

identify offending pod
check memory leak
scale deployment
verify HPA
analyze logs
optimize application
12. Explain HPA
Answer

Horizontal Pod Autoscaler scales pods automatically based on:

CPU
memory
custom metrics

Example:

CPU > 70% → add more pods
13. Why Use ACR?
Answer

Azure Container Registry stores Docker images securely.

AKS pulls images from ACR.

Benefits:

private registry
Azure integration
RBAC
secure image storage
14. Scenario — AKS Cannot Pull Docker Image
Answer

Check:

image tag
ACR permissions
Managed Identity
image existence
network connectivity

Commands:

kubectl describe pod

Look for:

ImagePullBackOff
15. Explain CI/CD Flow
Strong Answer
Developer Commit
   ↓
GitHub/Jenkins Trigger
   ↓
Build Application
   ↓
Run Tests
   ↓
Build Docker Image
   ↓
Push to ACR
   ↓
Deploy to AKS using Helm/Kubectl
   ↓
Monitor Deployment
16. Why Terraform?
Answer

Infrastructure as Code benefits:

reusable
version controlled
automated
consistent environments
easy rollback
scalable
17. What is Terraform State?
Answer

Terraform state tracks deployed infrastructure.

Usually stored remotely:

Azure Storage Account

Benefits:

collaboration
locking
consistency
18. Scenario — Terraform Apply Failed Midway
Answer
Check error logs
Verify state consistency
Run:
terraform plan
Import manually created resources if needed
Fix dependency issues
19. Explain NSG
Answer

Network Security Group acts as subnet firewall.

Controls:

inbound traffic
outbound traffic

Example:

Allow 443 from internet
20. Why Private PostgreSQL?
Answer

Security.

Database accessible only inside VNet.

No public exposure.

Implemented using:

delegated subnet
private DNS zone
21. Scenario — Database Connection Failure
Answer

Check:

NSG
DNS resolution
DB firewall
subnet routing
secrets
pod connectivity

Commands:

nslookup
telnet
nc
22. What is Azure Policy?
Answer

Governance and compliance service.

Can enforce:

no public IPs
tagging
approved VM sizes
security policies
23. Scenario — Node Not Ready
Answer

Check:

kubectl get nodes
kubectl describe node

Possible causes:

kubelet failure
network issue
disk pressure
memory pressure
VM unhealthy
24. Explain Rolling Updates
Answer

New pods deployed gradually while old pods terminate slowly.

Benefits:

zero downtime
safer deployments
25. Difference Between Liveness and Readiness Probe
Liveness	Readiness
Checks app alive	Checks app ready
Restarts pod	Removes from traffic
26. Scenario — Memory Leak in Production
Answer

Steps:

Analyze metrics
Check pod memory growth
Inspect logs
Heap dump if needed
Increase limits temporarily
Deploy optimized version
27. What Happens When User Hits URL?
Strong Flow
DNS resolves domain
 ↓
Application Gateway receives request
 ↓
WAF inspection
 ↓
Routes to AKS service
 ↓
Service routes to pod
 ↓
Pod connects DB
 ↓
Response returned
28. Explain Observability
Answer

Observability means understanding system behavior using:

logs
metrics
traces

Used for:

debugging
monitoring
reliability
29. Difference Between Monitoring and Observability
Monitoring	Observability
Detect issue	Understand why
Metrics focused	Deep visibility
Alerts	Root cause analysis
30. Scenario — Production Deployment Failed
Answer

Steps:

stop rollout
rollback deployment
analyze logs
compare image/config changes
validate health probes
verify secrets/configmaps
31. Explain Microservices Architecture
Answer

Application split into independent services:

user-service
order-service
payment-service

Each has:

own deployment
own scaling
own database
32. Why Separate Databases Per Service?
Answer

Microservice isolation.

Benefits:

independent scaling
fault isolation
schema flexibility
better ownership
33. Explain Azure Availability Zones
Answer

Physical datacenter separation.

Used for:

high availability
disaster resilience

AKS nodes spread across:

zones = [1,2,3]
34. Scenario — One AZ Fails
Answer

Traffic shifts to healthy nodes in remaining zones.

Cluster continues running.

This improves HA.

35. Security Best Practices Used Here
Answer
Private DB
NSGs
WAF
Managed Identity
Key Vault
HTTPS
Azure Policy
No hardcoded secrets
36. Why Key Vault?
Answer

Secure secret management.

Stores:

DB passwords
API keys
certificates

Avoids hardcoding secrets.

37. Explain Autoscaling
Answer

Two types:

Pod autoscaling (HPA)
Node autoscaling (Cluster Autoscaler)

This Terraform uses node autoscaling.

38. Scenario — Cluster Running Out of Capacity
Answer

Cluster Autoscaler adds more nodes automatically.

Configured:

min_count = 3
max_count = 10
39. What Would You Improve in This Architecture?

Excellent interview question.

Good Answer
Add private AKS cluster
Add Redis cache
Add CI/CD with GitHub Actions
Add backup strategy
Add Azure Front Door
Add canary deployments
Add centralized secrets CSI driver
40. Most Important Final Question
“What Was Your Role?”

Strong answer:

I worked on deployment automation, Kubernetes operations, CI/CD pipeline implementation, infrastructure provisioning using Terraform, troubleshooting production issues, monitoring integration, and managing scalable cloud-native deployments on Azure/AWS environments.