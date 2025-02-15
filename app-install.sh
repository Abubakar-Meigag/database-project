#!/bin/bash

sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo echo '<center><h1>Welcome to New Stack to build and host database into EC2 instance!</h1></center>' > /var/www/html/index.html