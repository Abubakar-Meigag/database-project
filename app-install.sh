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

# Install Apache Web Server for a Basic Web Interface
# sudo yum install -y httpd
# sudo systemctl enable httpd
# sudo systemctl start httpd

# Allow HTTP traffic in the OS firewall
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Create a simple HTML page
# echo 'Welcome to New Stack to build and host database into EC2 instance' | sudo tee /var/www/html/index.html
# sudo mkdir -p /var/www/html/app1

# Ensure correct ownership and permissions for Apache web root
# sudo chown -R apache:apache /var/www/html
# sudo chmod -R 755 /var/www/html

# Indicate script completion
echo "User data script completed successfully. Welcome to New Stack to build and host database into EC2 instance"