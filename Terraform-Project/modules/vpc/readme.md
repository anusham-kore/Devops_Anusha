                        🌍 Internet
                             │
                    ┌────────▼────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
   🌐 Public Subnet A  🌐 Public Subnet B  🌐 Public Subnet C
          │                  │                  │
          │            (NLB lives here)         │
          │                  │                  │
          ▼                  ▼                  ▼
     NAT Gateway        NAT Gateway        NAT Gateway
          │                  │                  │
   ┌──────┴──────┐    ┌──────┴──────┐    ┌──────┴──────┐
   │ Private Sub │    │ Private Sub │    │ Private Sub │
   │     A       │    │     B       │    │     C       │
   │ (EKS Nodes) │    │ (EKS Nodes) │    │ (EKS Nodes) │
   └─────────────┘    └─────────────┘    └─────────────┘

   ┘
🔥 Component Breakdown
🟢 1. VPC
CIDR: 10.10.0.0/16
Acts as isolated network
🌐 2. Public Subnets
3 AZs (us-east-1a/b/c)
Contains:
NAT Gateway
Load Balancer (NLB)

👉 Route:

0.0.0.0/0 → IGW
🔒 3. Private Subnets
3 AZs
Contains:
EKS Worker Nodes

👉 Route:

0.0.0.0/0 → NAT Gateway
🌍 4. Internet Gateway (IGW)
Entry/exit point to internet
Attached to VPC
🔥 5. NAT Gateway
Placed in public subnet
Allows:
Private subnet → Internet (outbound only)
🔁 6. Route Tables
Public Route Table
0.0.0.0/0 → IGW
Private Route Table
0.0.0.0/0 → NAT
⚡ 7. Load Balancer (NLB)
Lives in public subnet
Receives traffic from:
Route53
🌍 8. Route53
app-services.kore.ai → NLB DNS
☸️ 9. EKS Cluster
Control plane → AWS managed
Worker nodes → private subnets
🔄 End-to-End Flow
User → Route53 → NLB → EKS Ingress → Pods
                        ↓
                  Private Subnets
                        ↓
                  NAT → IGW → Internet
🎯 Interview Explanation (Short & Strong)

👉
“I designed a multi-AZ VPC with public and private subnets.
Public subnets host load balancers and NAT gateways with IGW access.
Private subnets host EKS worker nodes and route outbound traffic via NAT.
DNS is handled via Route53 pointing to NLB.”