#!/bin/bash

# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install Apache (httpd equivalent in Ubuntu is apache2)
sudo apt install -y apache2

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Add test HTML file
echo '<center><h1>Welcome to New Stack to build and host database into EC2 instance!</h1></center>' | sudo tee /var/www/html/index.html

# Install Docker (for Coolify)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu

# Install Coolify
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | sudo bash

# Restart EC2 to apply changes
sudo reboot
