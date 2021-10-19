#!/bin/sh
#The purpose of this script is to assist in expiditing the installation of LibreSpeed to external entities.
echo "Beginning the installation process"
sleep 2s
echo "Installing prequeqets..."
sleep 2s
apt install -y apache2 php php-pear php-cgi php-common php-curl php-mbstring php-gd php-mysql php-bcmath php-imap php-json php-xml php-snmp php-fpm php-zip mysql-server
echo "cloning LibreSpeed Repository"
sleep 2s
git clone https://github.com/adolfintel/speedtest.git
rm /var/www/html/index.html
cp -R speedtest/backend/ speedtest/results/ speedtest/example-singleServer-pretty.html speedtest/*.js /var/www/html/
mv /var/www/html/example-singleServer-pretty.html /var/www/html/index.html
chown -R www-data /var/www/html/
echo "Configuring MySQL"
sleep 2s
#MySQL Configuration
mysql -u root << EOF
alter user 'root'@'localhost' identified with mysql_native_password by 'P@ssw0rd';
flush privileges;
CREATE DATABASE speedtest;
EOF
mysql -u root -p speedtest < speedtest/results/telemetry_mysql.sql
echo "Now updating telemetry settings."
sleep 2s
echo "Please enter the status page password"
stty -echo
read statpass
stty echo
echo "If set to true, test IDs will be obfuscated to prevent users from guessing URLs of other tests. Please enter True or False."
read obfus
echo "If set to true, IP addresses will be redacted from IP and ISP info fields, as well as the log. Please enter True or False."
read ipfield

sed -i -e "s/\(stats_password = '\).*/\1$statpass';/" \
-e "s/\(enable_id_obfuscation = \).*/\1$obfus;/" \
-e "s/\(redact_ip_addresses = \).*/\1$ipfield;/" \
-e "s/\(MySql_username = '\).*/\1root';/" \
-e "s/\(MySql_password = '\).*/\1P@ssw0rd';/" \
-e "s/\(MySql_hostname = '\).*/\1localhost';/" \
-e "s/\(MySql_databasename = '\).*/\1speedtest';/" /var/www/html/results/telemetry_settings.php

cp speedtest/example-singleServer-full.html /var/www/html/index.html
chown -R www-data /var/www/html/

echo "The password for your status page is: "$statpass ". you can access it at http://localhost/results/stats.php"
sleep 5s
echo "Your temporary password for MySQL root user is 'P@ssw0rd', this can be changed by running the following command in MySQL: alter user 'root'@'localhost' identified with mysql_native_password by 'PASSWORD'; "
sleep 2s
echo "Please ensure that you update this password in /var/www/html/results/telemetry_settings.php. This is also where you can change the password for the status page."
