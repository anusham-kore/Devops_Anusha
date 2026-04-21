User (Internet)
      │
      ▼
Route53 (DNS)
      │
      ▼
NLB (Public Subnets, Multi-AZ)
      │
      ▼
Target Group (Port 80 / TCP)
      │
      ▼
EKS Nodes (Private Subnets)
      │
      ▼
Pods (Application)


🔥 Component Breakdown
🌍 1. Route53
Maps domain → NLB DNS
app-services.kore.ai → NLB DNS
⚡ 2. Network Load Balancer (NLB)

👉 Key properties:

Layer 4 (TCP/UDP) load balancer
High performance + low latency
Static IP per AZ

👉 In your Terraform:

aws_lb (type = "network")
🌐 3. Subnets (VERY IMPORTANT)
NLB is placed in:
Public subnets (multi-AZ)

👉 Why?

Needs internet-facing access
🎯 4. Target Group
aws_lb_target_group
Defines:
Port (80)
Protocol (TCP)
VPC

👉 Targets:

EKS worker nodes OR pods (via NodePort)
🔊 5. Listener
aws_lb_listener
Listens on:
Port 80
Forwards traffic → Target Group
☸️ 6. EKS Integration

Two modes:

Option 1: NodePort (common)
NLB → Node → Pod
Option 2: AWS Load Balancer Controller
NLB → Pod directly

👉 Your current setup = NodePort style

🔄 End-to-End Flow
User → Route53 → NLB → Target Group → Node → Pod
🔥 Important Behavior
✅ Health Checks
NLB checks:
Node health
Port availability
✅ Cross-AZ Load Balancing
Traffic distributed across:
multiple AZs
✅ Static IP
Each AZ gets fixed IP
⚠️ Common Mistakes (Interview Traps)

❌ Using private subnets for NLB
❌ Wrong target port
❌ Missing health check
❌ Not exposing NodePort

🔥 NLB vs ALB (Must Know)
Feature	NLB	ALB
Layer	L4	L7
Protocol	TCP/UDP	HTTP/HTTPS
Speed	Very high	Moderate
Use case	EKS, high throughput	Web apps
🎯 Interview Answer (Perfect)

👉
“I used an internet-facing NLB deployed across public subnets.
Route53 points to the NLB, which forwards TCP traffic to a target group.
Targets are EKS worker nodes running in private subnets, and traffic is routed to pods via NodePort.”

✅ Your Understanding Check

👉 Answer this:

Why NLB is used instead of ALB in your setup?