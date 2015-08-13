#!/usr/bin/env bash

# This provisioning script will download the latest version of WordPress and
# install it for the user.

# Variables
APPENV=local
DBHOST=localhost
DBNAME=oleville
DBUSER=oleville
DBPASSWD=sga123

# Set up commands so that they are run as 'vagrant' instead of 'root'
if (( $EUID == 0 )); then
    wp() { sudo -EH -u vagrant -- wp "$@"; }
    tar() { sudo -EH -u vagrant -- tar "$@"; }
fi

echo -e "--- Installing WordPress CLI ---"
echo -e "cd ~"
cd ~
echo -e "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null 2>&1
echo -e "chmod +x wp-cli.phar"
chmod +x wp-cli.phar
echo -e "mv wp-cli.phar /usr/local/bin/wp"
mv wp-cli.phar /usr/local/bin/wp
echo -e "curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash"
curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash > /dev/null 2>&1
echo -e "mv wp-completion.bash /usr/local/etc/"
mv wp-completion.bash /usr/local/etc/
echo -e "echo '. /usr/local/etc/wp-completion.bash' >> /home/vagrant/.bashrc"
echo '' >> /home/vagrant/.bashrc
echo '# enable completion of the wp command (manually added)' >> /home/vagrant/.bashrc
echo '. /usr/local/etc/wp-completion.bash' >> /home/vagrant/.bashrc

echo -e "--- Installing WordPress ---"
echo -e "cd /srv/www"
cd /srv/www
echo -e "curl -L -O https://wordpress.org/latest.tar.gz"
curl -L -O https://wordpress.org/latest.tar.gz > /dev/null 2>&1
echo -e "tar -xzf latest.tar.gz"
tar -xzf latest.tar.gz > /dev/null 2>&1
echo -e "mv wordpress/* ."
mv wordpress/* .
echo -e "rm -rf wordpress/ latest.tar.gz"
rm -rf wordpress/ latest.tar.gz

echo -e "--- Configuring WordPress ---"
echo -e "wp core config"
wp core config --dbname=$DBNAME --dbuser=$DBUSER --dbpass=$DBPASSWD --quiet --extra-php <<PHP
define('WP_DEBUG', true );
define('WP_DEBUG_LOG', true );

define('WP_ALLOW_MULTISITE', true );

define('MULTISITE', true );
define('SUBDOMAIN_INSTALL', false );
define('DOMAIN_CURRENT_SITE', 'oleville.local');
define('PATH_CURRENT_SITE', '/');
define('SITE_ID_CURRENT_SITE', 1);
define('BLOG_ID_CURRENT_SITE', 1);
PHP
echo -e "cp /srv/config/.htaccess /srv/www/"
cp /srv/config/.htaccess /srv/www/

echo -e "--- Importing Data into Oleville ---"
echo "wp db import"
wp db import /srv/database/backups/oleville.sql --allow-root
echo "wp --url=oleville.com search-replace oleville.com oleville.local --network"
wp --url=oleville.com --quiet search-replace oleville.com oleville.local --network

echo -e "--- Creating WordPress User ---"
echo -e "wp user create $DBUSER oleville@oleville.local --user_pass=\$DBPASSWD"
wp user create $DBUSER oleville@oleville.local --user_pass=$DBPASSWD
echo -e "wp super-admin add $DBUSER"
wp super-admin add $DBUSER

echo -e "--- Installing Oleville Theme ---"
echo -e "cd /srv/www/wp-content/themes"
cd /srv/www/wp-content/themes
echo -e "git clone https://github.com/oleville/oleville-theme-2015.git oleville-live"
git clone https://github.com/oleville/oleville-theme-2015.git oleville-live >  /dev/null 2>&1

echo -e "--- Removing MySQL Super Privileges From User ---"
echo -e "REVOKE SUPER ON *.* FROM '$DBUSER'@'localhost' IDENTIFIED BY '\$DBPASSWD'"
mysql -uroot -p$DBPASSWD -e "REVOKE SUPER ON *.* FROM '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD'"
