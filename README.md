# 🌐 Multi-Region Disaster Recovery with AWS and Terraform
## Objective
To design and implement a multi-region disaster recovery solution using AWS services, where infrastructure is deployed in two AWS regions. The solution will replicate data across regions, ensure high availability, and implement a failover mechanism for disaster recovery. The project involves using Terraform to provision infrastructure.

## ⚙️ Technologies Used

- **Terraform** — IaC for provisioning infrastructure
- **Amazon EC2** — for hosting the web app
- **Amazon RDS** — primary DB in Region A, read replica in Region B
- **Amazon S3** — with cross-region replication
- **Amazon Route 53** — DNS + Failover routing
- **Elastic Load Balancer (ALB)** — distributes traffic to instances
- **Auto Scaling Groups** — for high availability

### 🏗️ Architectural Overview
![Disaster Recovery](images/disaster_recovery.png)

## 🔁 Failover and Recovery Strategy

- Primary region: `ap-south-1 (Mumbai)`
- Secondary/DR region: `ap-northeast-1 (Tokyo)`
- Route 53 failover routing detects unhealthy endpoints and redirects traffic
- RDS read replica in Tokyo keeps in sync with Mumbai
- S3 buckets with cross-region replication keep static data synchronized
  
