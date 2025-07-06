#!/usr/bin/env bash

# Install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Postgres 17 Prereq
sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
. /etc/os-release
sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"

sudo apt update
sudo apt install -y postgresql-client-17

# Setup PSQL Connection
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
echo 'eval "$(starship init bash)"' >> ~/.bashrc
starship preset catppuccin-powerline -o ~/.config/starship.toml
EOF

chmod +x starship.sh

