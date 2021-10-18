#!/bin/sh
#The purpose of this script is to assist in expiditing the installation of LibreSpeed to external entities.
echo "Beginning the installation process"
echo "what is the username that will be responisble for the installation of all dependancies and the application? Please note this user must have ROOT privileges."
read uname
echo "what is the username's password? This will only temporarily be stored and will be removed from memory once installation completes."
read -s upass
sudo su
echo $upass
echo "Installing prequeqets..."
apt install -y apahce2 php php-{pear,cgi,common,curl,mbstring,gd,mysql,bcmath,imap,json,xml,snmp,fpm,zip} mysql-server phpmyadmin
echo "cloning LibreSpeed Repository"
git clone https://github.com/adolfintel/speedtest.git
cp -R ~/speedtest/backend/ ~/speedtest/results/ example-singleServer-pretty.html *.js /var/www/html/
mv /var/www/html/example-singleServer-pretty index.html
chown -R www-data /var/www/html/
mysql -u root
cp ~/speedtest/example-singleServer-full.html /var/www/html/index.html
#MySQL Configuration
alter user 'root'@'localhost' identified with mysql_native_password by 'PASSWORD';
flush privileges;
Create database;
CREATE DATABASE speedtest;
mysql -u root -p speedtest < ~/speedtest/results/telemetry_mysql.sql
echo "Now updating telemetry settings."
echo "Please enter the status page password"
read -s statpass
echo "If set to true, test IDs will be obfuscated to prevent users from guessing URLs of other tests. Please enter True or False."
read obfus
echo "If set to true, IP addresses will be redacted from IP and ISP info fields, as well as the log. Please enter True or False."
read ipfield
echo "Please enter MySQL username"
read msqlunam
echo "Please enter MySQL Password"
read -s msqlpass
hname = localhost
dbname = speedtest

sed -i -e "s/\(stats_password = '\).*/\1$statpass/" \
-e "s/\(enable_id_obfuscation = \).*/\1$obfus/" \
-e "s/\(redact_ip_addresses = \).*/\1$ipfield/" \
-e "s/\(MySql_username = '\).*/\1$msqlunam/" \
-e "s/\(MySql_password = '\).*/\1$msqlpass/" \
-e "s/\(MySql_hostname = '\).*/\1$hname/" \
-e "s/\(MySql_databasename = '\).*/\1$dbname/" /var/www/html/results/telemetry_settings.php