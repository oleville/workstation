#!/usr/bin/env bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=oleville
DBUSER=oleville
DBPASSWD=sga123

echo -e "======================================"
echo -e "=== Beginning Bootstrap Process... ==="
echo -e "======================================"

echo -e "--- Updating packages list ---"
echo -e "apt-get update"
apt-get -qq update

echo -e "--- Installing Base Packages ---"
echo -e "apt-get -y install vim curl build-essential python-software-properties git"
apt-get -y install vim curl build-essential python-software-properties git > /dev/null 2>&1

echo -e "--- Adding Repositories to Ubuntu ---"
echo -e "add-apt-repository ppa:ondrej/php5"
add-apt-repository ppa:ondrej/php5 > /dev/null 2>&1
echo -e "curl -sL https://deb.nodesource.com/setup_0.12 | bash -"
curl -sL https://deb.nodesource.com/setup_0.12 | bash - > /dev/null 2>&1

echo -e "--- Updating packages list ---"
echo -e "apt-get update"
apt-get -qq update

echo -e "--- Installing MySQL Server & phpMyAdmin ---"
echo -e "Setting Installation and Configuration Selections..."
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
echo -e "apt-get -y install mysql-server phpmyadmin"
apt-get -y install mysql-server phpmyadmin > /dev/null 2>&1

echo -e "--- Setting up MySQL users and db ---"
echo -e "CREATE DATABASE IF NOT EXISTS $DBNAME"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE IF NOT EXISTS $DBNAME"
echo -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost' IDENTIFIED BY '\$DBPASSWD'"
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD'"
echo -e "GRANT SUPER ON *.* TO '$DBUSER'@'localhost' IDENTIFIED BY '\$DBPASSWD'"
mysql -uroot -p$DBPASSWD -e "GRANT SUPER ON *.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD'"

echo -e "--- Installing Apache and PHP Packages ---"
echo -e "apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc"
apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc > /dev/null 2>&1

echo -e "--- Enabling mod-rewrite ---"
echo -e "a2enmod rewrite"
a2enmod rewrite > /dev/null 2>&1

echo -e "--- Setting DocumentRoot to www/ ---"
echo -e "rm -rf /var/www"
rm -rf /var/www
echo -e "ln -fs /srv/www /var/www"
ln -fs /srv/www /var/www

echo -e "--- Enabling PHP Errors ---"
echo -e "sed -i ... /etc/php5/apache2/php.ini"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo -e "--- Configuring Apache and phpMyAdmin ---"
echo -e "Listening to port 81..."
echo -e "\n\nListen 81\n" >> /etc/apache2/ports.conf
echo -e "Configuring Apache settings..."
cat > /etc/apache2/conf-available/phpmyadmin.conf << "EOF"
<VirtualHost *:81>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/phpmyadmin
    DirectoryIndex index.php
    ErrorLog ${APACHE_LOG_DIR}/phpmyadmin-error.log
    CustomLog ${APACHE_LOG_DIR}/phpmyadmin-access.log combined
</VirtualHost>
EOF
echo -e "a2enconf phpmyadmin"
a2enconf phpmyadmin > /dev/null 2>&1

echo -e "--- Setting Apache environment variables ---"
cat > /etc/apache2/sites-enabled/000-default.conf <<EOF
<VirtualHost *:80>
    ServerAdmin oleville@oleville.local
    ServerName oleville.local

    DocumentRoot /var/www
    <Directory /var/www>
        Options FollowSymLinks
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SetEnv APP_ENV $APPENV
    SetEnv DB_HOST $DBHOST
    SetEnv DB_NAME $DBNAME
    SetEnv DB_USER $DBUSER
    SetEnv DB_PASS $DBPASSWD
</VirtualHost>
EOF

echo -e "--- Installing Composer ---"
echo -e "curl -sS https://getcomposer.org/installer"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
echo -e "chmod +x composer.phar"
chmod +x composer.phar
echo -e "mv composer.phar /usr/local/bin/composer"
mv composer.phar /usr/local/bin/composer

echo -e "--- Installing Sendmail ---"
echo -e "(This may take a few minutes)"
echo -e "apt-get -y install sendmail"
apt-get -y install sendmail > /dev/null 2>&1

echo -e "--- Installing NodeJS and NPM ---"
echo -e "apt-get -y install nodejs"
apt-get -y install nodejs > /dev/null 2>&1
