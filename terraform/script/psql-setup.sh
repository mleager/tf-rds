#!/usr/bin/env bash

# Install required packages
sudo dnf -y update
sudo dnf install -y postgresql17 jq awscli

# Create output files directory
mkdir -p $HOME/rds_info

# Get RDS info
aws rds describe-db-instances \
  --query "DBInstances[0].Endpoint.Address" \
  --output text > $HOME/rds_info/endpoint.txt

aws rds describe-db-instances \
  --query "DBInstances[0].DBName" \
  --output text > $HOME/rds_info/dbname.txt

PW=$(aws ssm get-parameter \
  --name "${db_password}" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

# Create a connection script to run manually
cat <<EOF > $HOME/rds_info/connect.sh
#!/usr/bin/env bash

ENDPOINT=\$(cat \$HOME/rds_info/endpoint.txt)
DBNAME=\$(cat \$HOME/rds_info/dbname.txt)

#psql -h \$ENDPOINT -U postgres -d \$DBNAME
PGPASSWORD=\$PW psql -h \$ENDPOINT -U postgres -d \$DBNAME
EOF

chmod +x $HOME/rds_info/connect.sh

