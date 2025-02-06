#!/bin/bash

# Redirect output to log file for debugging
exec > /var/log/user-data.log 2>&1

# Update system packages
sudo yum update -y

# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-contrib

# Initialize PostgreSQL database
sudo postgresql-setup initdb

# Enable PostgreSQL service to start on boot
sudo systemctl enable postgresql

# Start PostgreSQL service
sudo systemctl start postgresql

# Sleep to ensure services stabilize
sleep 30

# Configure PostgreSQL to allow password authentication
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/'" /var/lib/pgsql/data/postgresql.conf
sudo sed -i "s/^host.*all.*all.*127.0.0.1\/32.*ident/host all all 0.0.0.0\/0 md5/" /var/lib/pgsql/data/pg_hba.conf

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

# Retrieve the database password securely from AWS SSM Parameter Store
DB_PASSWORD=$(aws ssm get-parameter --name "/myapp/db_password" --with-decryption --query "Parameter.Value" --output text)

# Create a PostgreSQL user and database securely
sudo -u postgres psql <<EOF
CREATE USER myProjectData WITH PASSWORD '${DB_PASSWORD}';
CREATE DATABASE myDB;
GRANT ALL PRIVILEGES ON DATABASE myDB TO myProjectData;
EOF

# Install NGINX for reverse proxy
sudo yum install -y nginx

# Configure NGINX as a reverse proxy for PostgreSQL
sudo tee /etc/nginx/conf.d/postgres-proxy.conf <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5432;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Start and enable NGINX
sudo systemctl enable nginx
sudo systemctl start nginx

# Allow HTTP traffic in the OS firewall
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Install Apache Web Server for a Basic Web Interface
sudo yum install -y httpd

# Enable and start Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# Create a simple HTML page
echo 'Welcome to New Stack to build and host database into EC2 instance' | sudo tee /var/www/html/index.html

# Ensure correct ownership and permissions for Apache web root
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Indicate script completion
echo "User data script completed successfully. PostgreSQL, NGINX, and Apache are now running."