#!/usr/bin/env bash

echo "add vagrant to sudo group"
usermod -a -G www-data vagrant

echo "disable eth0 port(nat port)"

apt install net-tools
sudo ifconfig eth0 down


echo "update the system"
apt update && apt upgrade -y

echo "installing apache2"
apt install apache2 -y

echo "enable apache"
sudo systemctl stop apache2.service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service


echo "curl localhost"

curl localhost

echo "install mysql"
apt install mysql-server -y

echo "create new user in db"

mysql -u root -e "\
	CREATE DATABASE snipeit; \
	CREATE USER 'snipeit'@'localhost' IDENTIFIED BY 'P@$$w0rd';\
	GRANT ALL ON snipeit.* TO 'snipeituser'@'localhost' WITH GRANT OPTION;\
	FLUSH PRIVILEGES;"


echo "Install php 7.4"
apt install php7.4 libapache2-mod-php7.4 php7.4-common php7.4-gmp php7.4-curl php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-mysql php7.4-gd php7.4-bcmath php7.4-xml php7.4-cli php7.4-zip php7.4-sqlite3 php7.4-ldap -y

echo "purge cache"
apt autoremove -y


echo "installing composer "
sudo apt install curl git
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "clone snipeit"
cd /var/www/
rm -rf snipeit
sudo git clone https://github.com/snipe/snipe-it snipeit
sudo cp /var/www/snipeit/.env.example /var/www/snipeit/.env

echo "updating environment(env)"
sed -i "s/DB_DATABASE=null/DB_DATABASE=snipeit/g" /var/www/snipeit/.env
sed -i "s/DB_USERNAME=null/DB_USERNAME=snipeituser/g" /var/www/snipeit/.env
sed -i "s/DB_PASSWORD=null/DB_PASSWORD=P@$$w0rd/g" /var/www/snipeit/.env
sed -i "s/APP_URL=null/APP_URL=snipe-it.local/g" /var/www/snipeit/.env

echo "composer install"
cd /var/www/snipeit
sudo composer install --no-dev --prefer-source
sudo php artisan key:generate -y


echo "setup permission"
chown -R www-data:www-data /var/www/snipeit/
chmod -R 755 /var/www/snipeit

echo "setup apache2 conf"
cp /opt/snipeit.conf /etc/apache2/sites-available/snipeit.conf

# ln -s /etc/apache2/sites-available/snipeit.conf /etc/apache2/sites-enabled/

sudo a2ensite snipeit.conf
sudo a2enmod rewrite
sudo systemctl restart apache2




