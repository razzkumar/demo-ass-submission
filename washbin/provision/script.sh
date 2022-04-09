export MESSAGE="I am provisioned"
echo $MESSAGE > check.txt

echo "Updating..."
sudo apt update

echo "Installing apache2..."
sudo apt install apache2 -y

echo "Installing php and extensions..."
sudo apt install php7.4 \
	php7.4-common \
	php7.4-cli \
	libapache2-mod-php7.4 \
	php7.4-gmp \
	php7.4-curl \
	php7.4-intl \
	php7.4-mbstring \
	php7.4-xmlrpc \
	php7.4-mysql \
	php7.4-gd \
	php7.4-bcmath \
	php7.4-xml \
	php7.4-zip \
	php7.4-sqlite3 \
	php7.4-ldap -y

sudo echo "
file_uploads = On
allow_url_fopen = On
short_open_tag = On
memory_limit = 256M
upload_max_filesize = 100M
max_execution_time = 360
max_input_vars = 1500
date.timezone = Asia/Kathamdu" >> /etc/php/7.4/apache2/php.ini

sudo echo "<?php phpinfo(); ?>" >> /var/www/html/info.php


echo "Installing mysql..."
# echo "mysql-server-5.6 mysql-server/root_password password root" | sudo debconf-set-selections
# echo "mysql-server-5.6 mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt install mariadb-server \
	mariadb-client -y
sudo echo -e "root\n\nY\nY\nY\nY\n" | sudo mysql_secure_installation

echo "Setting up mysql..."
# sudo mysql -u root -p
# CREATE DATABAE snipeit;
# CREATE USER `snipeituser`@`localhost` INDENTIFIED BY `password`;
# GRANT ALL ON snipeit.* TO `snipeituser`@`localhost` WITH GRANT OPTION;
# FLUSH PRIVILIEGES;
# EXIT;
mysql -uroot -p -e "CREATE DATABASE snipeit;
CREATE USER 'snipeituser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON snipeit.* TO 'snipeituser'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

echo "Restarting mysql..."
sudo systemctl restart mysql


echo "Installing composer..."
mkdir ~/composer/
cd ~/composer/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

echo "Downloading snipeit..."
cd /var/www/
sudo git clone https://github.com/snipe/snipe-it snipeit

echo "Setting up env file..."
sudo cp /var/www/snipeit/.env.example /var/www/snipeit/.env

echo "App realted env's..."
sed -i 's/APP_ENV=.*/APP_ENV=production/g' /var/www/snipeit/.env
sed -i 's/APP_DEBUG=.*/APP_DEBUG=false/g' /var/www/snipeit/.env
sed -i 's/APP_URL=.*/APP_URL=snipe-it.local/g' /var/www/snipeit/.env
sed -i 's/APP_TIMEZONE=.*/APP_TIMEZONE=Asia\/Kathmandu/g' /var/www/snipeit/.env
sed -i 's/APP_LOCALE=.*/APP_LOCALE=en/g' /var/www/snipeit/.env

echo "Database related env's..."
sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=mysql/g' /var/www/snipeit/.env
sed -i 's/DB_HOST=.*/DB_HOST=localhost/g' /var/www/snipeit/.env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=snipeit/g' /var/www/snipeit/.env
sed -i 's/DB_USERNAME=.*/DB_USERNAME=snipeituser/g' /var/www/snipeit/.env
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=password/g' /var/www/snipeit/.env
sed -i 's/DB_PREFIX=.*/DB_PREFIX=null/g' /var/www/snipeit/.env
sed -i "s/DB_DUMP_PATH=.*/DB_DUMP_PATH=\'\/usr\/bin\'/g" /var/www/snipeit/.env
sed -i 's/DB_CHARSET=.*/DB_CHARSET=utf8mb4/g' /var/www/snipeit/.env
sed -i 's/DB_COLLATION=.*/DB_COLLATION=utf8mb4_unicode_ci/g' /var/www/snipeit/.env


echo "Installing composer dependencies..."
cd /var/www/snipeit
composer install --no-dev --prefer-source

echo "Generating Secret Key..."
php artisan key:generate --force

echo "Setting up for new files to be owned by www-data group..."
sudo chown -R www-data:www-data /var/www/snipeit/
sudo chmod -R 775 /var/www/snipeit/


echo "Setting up apache2 config..."
echo "
<VirtualHost *:80>
	ServerAdmin admin@example.com
	DocumentRoot /var/www/snipeit/public
	ServerName snipe-it.local
	ServerAlias www.snipe-it.local
	<Directory /var/www/snipeit/public/>
		Options +FollowSymlinks
		AllowOverride All
		Require all granted
	</Directory>
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/snipeit.conf

echo "Restarting apache2..."
sudo a2ensite snipeit.conf
sudo a2enmod rewrite
sudo systemctl restart apache2.service
