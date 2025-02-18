#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo '<center><h1>Welcome to New Stack to build and host database into EC2 instance by Coolify!</h1></center>' | sudo tee /var/www/html/index.html