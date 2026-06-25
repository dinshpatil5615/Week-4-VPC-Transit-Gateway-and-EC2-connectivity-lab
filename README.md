# Week 4 — VPC Design, Transit Gateway & PrivateLink

## What this demonstrates
Two different VPC-to-VPC connectivity models built side by side:
- **Transit Gateway** between App VPC and Data VPC: full network-level
  routing, used when services in different VPCs need broad reachability.
- **PrivateLink** between App VPC and Shared VPC: a single service exposed
  through an NLB and an interface endpoint, with no network-level routing
  at all — App VPC never gains visibility into Shared VPC's CIDR.

## Architecture
screenshots/Screenshot 2026-06-25 165503.jpg
screenshots/Screenshot 2026-06-25 165611.jpg
screenshots/Screenshot 2026-06-25 165713.jpg

## How to deploy
\`\`\`bash
cd terraform
terraform init
terraform apply -var="my_ip=YOUR_IP/32"
\`\`\`

## How to test
[Insert the two curl tests from the lab]

## How to destroy
\`\`\`bash
terraform destroy -var="my_ip=YOUR_IP/32"
\`\`\`

## Cost
Approx. $0.10–0.15/hr while running (2 TGW attachments, 1 NLB, 1 interface
endpoint, 3x t3.micro). Always destroy after use.
