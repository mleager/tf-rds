# RDS (Postgres) with a Bastion Host

Deploy RDS database (Postgres) to a Private Subnet

DB should only be accessible from a Bastion Host

Requirements:

- DB access needs to be tightly controlled
- DB Password management (locally with Vault or Secrets Manager)
- can only be accessed by Bastion Host


Bastion Host:

- access Bastion Host via local machine (SSH or SSM)
- Bastion Host needs to be ephemeral (delete when not in use, re-launch when required)

Github Actions:

- allow for manual apply/destroy for bastion host


## Bastion Connection

Bastion will be connected through SSM only

This allows the Security Group to not allow any incoming traffic

Only traffic allowed is egress to RDS and 443 for SSM communication

Requires:

- awscli and session-manager-plugin on the local machine
- SSM IAM permissions

SSM from local machine to Bastion:
```bash
aws ssm start-session --target <bastion_id>
```

The launch template for the Bastion will upload a very small script to connect  
to the Postgres RDS

May add scripts and parameters for other databases later


## Destroying & Re-Creating Bastion

**Current Setup**

- use Guthub Actions to manually destroy and re=create Bastion


**Possible Changes**

- Lambda function to delete Bastions based on tag age
- Enforce some kind of TTL


## Security Groups

**Bastion:**

Ingress: None

Egress: To RDS & HTTPS


**RDS:**

Ingress: From Bastion

Egress: All


## IAM

**SSM:**

Allow SSM connection to the Bastion

**RDS:**

To easily get the RDS info like username, dbname, etc. allow the SSM agent to  
call 'aws rds describe*'


## RDS


