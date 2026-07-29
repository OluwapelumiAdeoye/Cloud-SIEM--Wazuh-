Cloud SIEM Lab on AWS

A fully operational cloud threat detection pipeline built from scratch using Wazuh, AWS CloudTrail, S3, SQS, EC2, and SNS entirely from the CLI.



What It Does

Monitors every API call in an AWS account, analyzes logs in real time, fires custom detection rules mapped to MITRE ATT&CK, and delivers email alerts via SNS.

```
CloudTrail → S3 → SQS → Wazuh (EC2) → Detection Rules → SNS → Email
```


Architecture

| Component | Role |
|-----------|------|
| AWS CloudTrail | Records every API call across all regions with log file validation |
| S3 Bucket | Stores compressed CloudTrail logs — public access blocked, CloudTrail-only bucket policy |
| SQS Queue | Queues S3 event notifications — Wazuh polls every 5 minutes |
| EC2 (Wazuh) | All-in-one SIEM — Manager, Indexer, Dashboard on Ubuntu 22.04 |
| IAM Role | Least privilege — read-only S3/SQS access, no hardcoded credentials |
| SSM Session Manager | Zero open ports EC2 access — all sessions audited |
| SNS Topic | Real-time email alerts for level 10+ rule triggers |


Detection Rules

| Rule ID | Description | Level | MITRE |
|---------|-------------|-------|-------|
| 100010 | AWS root account login detected | 12 — High | T1078 |
| 100011 | S3 bucket policy changed | 14 — Critical | T1530 |
| 100012 | IAM policy attached — privilege escalation risk | 10 — Medium | T1548 |

---

Security Design Decisions

- Least privilege IAM — Wazuh EC2 role has read-only access to S3 and SQS only
- No hardcoded credentials — EC2 instance role handles auth, temporary credentials auto-rotate
- Zero open ports — no SSH, no port 22. EC2 accessed exclusively via SSM Session Manager
- Log integrity — CloudTrail log file validation enabled, SHA-256 hash per file
- Event-driven architecture — S3 notifies SQS on new log arrival, Wazuh reacts rather than polls blindly
- Public access blocked — S3 bucket hardened at bucket level, not just policy level

---

Project Structure

```
siem_aws/
├── cloudtrail-bucket-policy.json   # S3 bucket policy — CloudTrail write only
├── sqs-policy.json                 # SQS policy — S3 bucket notifications only
├── ec2-trust-policy.json           # IAM trust policy — EC2 assume role
├── s3-notification.json            # S3 → SQS event notification config
├── vars.sh                         # Environment variables
├── screenshots/                    # Dashboard, alert, and CLI screenshots
└── docs/                           # Full project write-up
```

---

Build Phases

Phase 1 — AWS Infrastructure
- S3 bucket with public access block and CloudTrail-only bucket policy
- Multi-region CloudTrail with log file validation
- SQS queue wired to S3 event notifications
- IAM role with least-privilege permissions and EC2 instance profile

Phase 2 — EC2 & Wazuh Installation
- EC2 t3.medium, Ubuntu 22.04, 20GB EBS, 2GB swap
- Wazuh 4.7.5 all-in-one install (Manager + Indexer + Dashboard)
- SSM Session Manager for zero-port access

Phase 3 — CloudTrail Log Ingestion
- Configured Wazuh `aws-s3` wodle in `ossec.conf`
- 5-minute polling interval
- Verified end-to-end pipeline with live CloudTrail events

Phase 4 — Custom Detection Rules
- Three custom rules written in Wazuh XML
- Chained off base CloudTrail rule (SID 80202) for efficiency
- Mapped to MITRE ATT&CK framework
- Live tested — rule 100012 caught real IAM policy attachment

Phase 5 — SNS Email Alerting
- Custom integration script at `/var/ossec/integrations/custom-sns`
- Publishes to SNS topic via AWS CLI using EC2 instance role
- Triggers on level 10+ alerts
- Tested — live email received with full forensic details

---

Key Concepts

- Implicit deny — all AWS services deny by default, every permission is explicit
- Blast radius reduction — least privilege limits the damage if any component is compromised
- Event-driven architecture — react to events, doesn't poll blindly
- Detection engineering — custom rules targeting real-world attack techniques
- Alert fatigue prevention — threshold set to level 10+, low-severity events logged not emailed


Stack

`AWS CloudTrail` · `S3` · `SQS` · `EC2` · `IAM` · `SSM` · `SNS` · `Wazuh 4.7.5` · `Ubuntu 22.04` · `AWS CLI v2`


Author

Built by Oluwapelumi Adeoye — Personal Cloud Security Project.  
[LinkedIn](www.linkedin.com/in/oluwapelumiadeoyedavid/) · [Notion write-up](https://oluwapelumi-adeoye.notion.site/Cloud-Based-SIEM-Security-Information-and-Event-Management-System-hosted-on-AWS-36d282b9dd9180758c06c52851195c4f)
