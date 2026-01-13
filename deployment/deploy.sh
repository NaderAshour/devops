#!/bin/bash
# Simple deployment script for Voting App
# Usage:
#   Database:  ./deploy.sh database
#   Backend:   ./deploy.sh backend <DATABASE_IP>
#   Frontend:  ./deploy.sh frontend <BACKEND_IP> <DATABASE_IP>

set -e

ROLE="$1"
DB_NAME="votingdb"
DB_USER="voteapp"
DB_PASS="VoteApp123!"

case "$ROLE" in

database)
    echo "=== Deploying PostgreSQL ==="
    sudo dnf install -y postgresql-server postgresql-contrib
    sudo postgresql-setup --initdb 2>/dev/null || true
    
    # Configure for remote access
    sudo sed -i "s/^#listen_addresses.*/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
    
    sudo systemctl enable --now postgresql
    
    # Create database and user
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
    sudo -u postgres psql -d $DB_NAME -c "CREATE TABLE IF NOT EXISTS votes (id VARCHAR(255) NOT NULL UNIQUE, vote VARCHAR(255) NOT NULL);"
    sudo -u postgres psql -c "GRANT ALL ON DATABASE $DB_NAME TO $DB_USER;"
    
    sudo firewall-cmd --permanent --add-port=5432/tcp 2>/dev/null || true
    sudo firewall-cmd --reload 2>/dev/null || true
    
    echo "=== PostgreSQL Ready ==="
    ;;

backend)
    DATABASE_IP="$2"
    [ -z "$DATABASE_IP" ] && echo "Usage: $0 backend <DATABASE_IP>" && exit 1
    
    echo "=== Deploying Redis + Worker ==="
    
    # Redis
    sudo dnf install -y redis
    sudo sed -i 's/^bind.*/bind 0.0.0.0/' /etc/redis.conf
    sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis.conf
    sudo systemctl enable --now redis
    
    # .NET
    sudo dnf install -y dotnet-sdk-7.0
    
    # Deploy Worker (copy files to /opt/voting-app/worker first)
    sudo mkdir -p /opt/voting-app/worker
    [ -d "./worker" ] && sudo cp -r ./worker/* /opt/voting-app/worker/
    
    if [ -f "/opt/voting-app/worker/Worker.csproj" ]; then
        cd /opt/voting-app/worker
        sudo dotnet publish -c Release -o /opt/voting-app/worker/publish
    fi
    
    # Create service
    sudo tee /etc/systemd/system/voting-worker.service > /dev/null <<EOF
[Unit]
Description=Voting Worker
After=network.target

[Service]
WorkingDirectory=/opt/voting-app/worker/publish
ExecStart=/usr/bin/dotnet /opt/voting-app/worker/publish/Worker.dll
Environment="REDIS_HOST=localhost"
Environment="REDIS_PORT=6379"
Environment="POSTGRES_HOST=$DATABASE_IP"
Environment="POSTGRES_PORT=5432"
Environment="POSTGRES_USER=$DB_USER"
Environment="POSTGRES_PASSWORD=$DB_PASS"
Environment="POSTGRES_DB=$DB_NAME"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now voting-worker
    
    sudo firewall-cmd --permanent --add-port=6379/tcp 2>/dev/null || true
    sudo firewall-cmd --reload 2>/dev/null || true
    
    echo "=== Backend Ready ==="
    ;;

frontend)
    BACKEND_IP="$2"
    DATABASE_IP="$3"
    [ -z "$BACKEND_IP" ] || [ -z "$DATABASE_IP" ] && echo "Usage: $0 frontend <BACKEND_IP> <DATABASE_IP>" && exit 1
    
    echo "=== Deploying Vote + Result ==="
    
    # Python + Node
    sudo dnf install -y python3 python3-pip nodejs npm
    sudo pip3 install flask redis gunicorn
    
    # Deploy apps (copy files to /opt/voting-app first)
    sudo mkdir -p /opt/voting-app/{vote,result}
    [ -d "./vote" ] && sudo cp -r ./vote/* /opt/voting-app/vote/
    [ -d "./result" ] && sudo cp -r ./result/* /opt/voting-app/result/
    
    [ -f "/opt/voting-app/result/package.json" ] && cd /opt/voting-app/result && sudo npm install
    
    # Vote service
    sudo tee /etc/systemd/system/voting-vote.service > /dev/null <<EOF
[Unit]
Description=Voting Vote Service
After=network.target

[Service]
WorkingDirectory=/opt/voting-app/vote
ExecStart=/usr/bin/python3 app.py
Environment="REDIS_HOST=$BACKEND_IP"
Environment="REDIS_PORT=6379"
Environment="VOTE_PORT=8080"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Result service
    sudo tee /etc/systemd/system/voting-result.service > /dev/null <<EOF
[Unit]
Description=Voting Result Service
After=network.target

[Service]
WorkingDirectory=/opt/voting-app/result
ExecStart=/usr/bin/node server.js
Environment="PORT=8081"
Environment="POSTGRES_HOST=$DATABASE_IP"
Environment="POSTGRES_PORT=5432"
Environment="POSTGRES_USER=$DB_USER"
Environment="POSTGRES_PASSWORD=$DB_PASS"
Environment="POSTGRES_DB=$DB_NAME"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now voting-vote voting-result
    
    sudo firewall-cmd --permanent --add-port=8080/tcp --add-port=8081/tcp 2>/dev/null || true
    sudo firewall-cmd --reload 2>/dev/null || true
    
    echo "=== Frontend Ready ==="
    ;;

*)
    echo "Usage:"
    echo "  Database:  $0 database"
    echo "  Backend:   $0 backend <DATABASE_IP>"
    echo "  Frontend:  $0 frontend <BACKEND_IP> <DATABASE_IP>"
    exit 1
    ;;
esac
