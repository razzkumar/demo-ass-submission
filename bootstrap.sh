#!/usr/bin/env bash

echo "Update the system"
apt update -y

echo "Installing nginx"
apt install nginx -y

echo "enable nginx"
systemctl enable nginx --now

echo "curl localhost"
curl localhost

# echo "Install php 7.4"
# apt install php7.4-fpm php7.4-common php7.4 -y

echo "Purge cache"
apt autoremove -y

echo "Setup dirs and permission"
mkdir -p /var/www/test-app
chown -R www-data:www-data /var/www/test-app/
chmod -R 755 /var/www/test-app/
usermod -a -G www-data vagrant

# echo "Setting up app"
# echo "Hello world">/var/www/test-app/index.html

echo "Setup nginx conf"

cp /opt/nginx-test.local /etc/nginx/sites-available/nginx-test.local

ln -s /etc/nginx/sites-available/nginx-test.local /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default
systemctl restart nginx.service
