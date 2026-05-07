# Devops_Anusha


Start with the highest probability topics first. Since the interview is tomorrow, don’t try to learn new deep concepts now — focus on interview-ready answers + production scenarios.

3–4 Hour Preparation Plan
Step 1 — “Tell Me About Yourself” (20 mins)

This decides interview momentum.

Practice until fluent.

Structure:

Experience
Current role
Technologies
Major responsibilities
Recent projects

Focus keywords:

Jenkins
Kubernetes
AWS
Docker
Python automation
CI/CD
Deployment automation
Microservices
Step 2 — Kubernetes + Docker (1 hour) 🔥

Most important.

Prepare these thoroughly:

Kubernetes
Pod lifecycle
Deployment
Service types
Ingress
ConfigMap vs Secret
HPA
Liveness vs Readiness
StatefulSet
PV/PVC
Troubleshooting
CrashLoopBackOff
OOMKilled
Pending pod
ImagePullBackOff
Node Not Ready
Commands
kubectl get pods
kubectl describe pod
kubectl logs
kubectl exec -it
kubectl top pod
Step 3 — Python + REST APIs (45 mins)

Very important for this JD.

Prepare:

What is REST API
HTTP methods
Status codes
Flask/FastAPI basics
requests module
JSON parsing
Exception handling

Example:

import requests
response = requests.get(url)
print(response.json())

Know:

GET vs POST
synchronous vs asynchronous
virtual environment
Step 4 — CI/CD + Jenkins (45 mins)

Your strongest section.

Prepare:

Pipeline stages
Shared libraries
Parallel execution
Artifact management
Rollback
Deployment automation
Git branching

Important scenarios:

Build failed
Deployment failed
Jenkins slave offline
Rollback strategy
Step 5 — AWS Basics (30 mins)

Prepare:

EC2
IAM
EKS
ECR
S3
Route53
ALB
ASG
CloudWatch

Scenario:
“How request reaches pod from browser?”

Answer flow:

Route53 → ALB → Ingress → Service → Pod
Step 6 — Observability + Linux (20 mins)

Prepare:

top
netstat
ps
df -h
free -m
journalctl

Observability:

Prometheus
Grafana
Logs
Metrics
Alerts
MOST IMPORTANT SCENARIOS

Practice these tonight:

1. Pod restarting continuously

How will you debug?

Expected flow:

kubectl get pods
kubectl describe pod
kubectl logs
Check probes
Check memory/cpu
Check env vars
2. Jenkins deployment failed

Explain rollback.

3. Application slow in Kubernetes

Explain debugging approach.

4. CI/CD pipeline design

Explain end-to-end flow.

Very Important Tip

If you don’t know something:

Don’t say “I don’t know.”
Say:

“I haven’t worked deeply on that yet, but my understanding is…”

This works very well.

Before Sleeping

Revise:

Kubernetes objects
Docker basics
Python basics
AWS architecture
Your own projects

Do NOT start Terraform or advanced backend topics now unless already familiar.

Tomorrow During Interview
Keep answers:
structured
production-oriented
concise

Use:

“In our environment…”
“In production…”
“We automated…”
“We scaled…”

That creates strong impact quickly.