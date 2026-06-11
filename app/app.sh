#!/bin/sh
sudo yum update -y
sudo yum install -y 
sudo chmod -R 777 /var/www/html
sudo echo "Welcome to besimple - WebVM  - VM Hostname: $(hostname)" > /var/www/html/index.html
