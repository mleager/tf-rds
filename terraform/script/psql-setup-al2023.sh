#!/usr/bin/env bash

sudo dnf -y update
sudo dnf install -y postgresql17 jq awscli

mkdir -p "$HOME/rds_info"

aws rds describe-db-instances \
  --query "DBInstances[0].Endpoint.Address" \
  --output text > "$HOME/rds_info/endpoint.txt"

aws rds describe-db-instances \
  --query "DBInstances[0].DBName" \
  --output text > "$HOME/rds_info/dbname.txt"

cat <<'EOF' > "$HOME/rds_info/connect.sh"
#!/usr/bin/env bash

ENDPOINT=$(cat "$HOME/rds_info/endpoint.txt")
DBNAME=$(cat "$HOME/rds_info/dbname.txt")

# Securely fetch password and write to .pgpass
aws ssm get-parameter \
  --name "some-test-name" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > "$HOME/.pgpass"

# Format required by .pgpass: host:port:database:username:password
sed -i "s|^|$ENDPOINT:5432:$DBNAME:postgres:|" "$HOME/.pgpass"
chmod 600 "$HOME/.pgpass"

# Run psql (reads password from .pgpass)
psql -h "$ENDPOINT" -U postgres -d "$DBNAME"

rm -f "$HOME/.pgpass"
EOF

chmod +x "$HOME/rds_info/connect.sh"

# Install starship (a cross-shell prompt)
cat <<EOF > starship.sh
curl -sS https://starship.rs/install.sh | sh
starship preset catppuccin-powerline -o ~/.config/starship.toml
EOF

chmod +x starship.sh

