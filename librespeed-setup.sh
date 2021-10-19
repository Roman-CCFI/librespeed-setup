#!/bin/sh
#The purpose of this script is to assist in expiditing the installation of LibreSpeed to external entities.
RED='\033[0;31m'
BLUE='\033[0;34m'
LCYAN='\033[0;36m'
NC='\033[0m'


echo "${LCYAN}Beginning the installation process${NC}"
sleep 1s
echo "${LCYAN}Installing prerequisites...${NC}"
sleep 1s
apt install -y apache2 php php-pear php-cgi php-common php-curl php-mbstring php-gd php-mysql php-bcmath php-imap php-json php-xml php-snmp php-fpm php-zip mysql-server
echo "${LCYAN}Cloning LibreSpeed Repository${NC}"
sleep 1s
git clone https://github.com/adolfintel/speedtest.git
rm /var/www/html/index.html
cp -R speedtest/backend/ speedtest/results/ speedtest/example-singleServer-pretty.html speedtest/*.js /var/www/html/
mv /var/www/html/example-singleServer-pretty.html /var/www/html/index.html
chown -R www-data /var/www/html/
echo "${LCYAN}Configuring MySQL${NC}"
sleep 1s
echo "${LCYAN}Please enter desired password for MySQL root user.${NC}"
stty -echo
read mypass
stty echo
#MySQL Configuration
mysql -u root << EOF
alter user 'root'@'localhost' identified with mysql_native_password by '$mypass';
flush privileges;
CREATE DATABASE speedtest;
EOF
mysql -u root-p$mypass speedtest < speedtest/results/telemetry_mysql.sql
echo "${LCYAN}Now updating telemetry settings.${NC}"
sleep 1s
echo "${LCYAN}Please enter the status page password${NC}"
stty -echo
read statpass
stty echo
echo "${LCYAN}If set to true, test IDs will be obfuscated to prevent users from guessing URLs of other tests. Please enter True or False.${NC}"
read obfus
echo "${LCYAN}If set to true, IP addresses will be redacted from IP and ISP info fields, as well as the log. Please enter True or False.${NC}"
read ipfield
sed -i -e "s/\(stats_password = '\).*/\1$statpass';/" \
-e "s/\(enable_id_obfuscation = \).*/\1$obfus;/" \
-e "s/\(redact_ip_addresses = \).*/\1$ipfield;/" \
-e "s/\(MySql_username = '\).*/\1root';/" \
-e "s/\(MySql_password = '\).*/\1$mypass';/" \
-e "s/\(MySql_hostname = '\).*/\1localhost';/" \
-e "s/\(MySql_databasename = '\).*/\1speedtest';/" /var/www/html/results/telemetry_settings.php

cp speedtest/example-singleServer-full.html /var/www/html/index.html
chown -R www-data /var/www/html/

echo "${LCYAN}The password for your status page is:${RED}$statpass${NC}${LCYAN}. you can access it at ${BLUE}http://localhost/results/stats.php${NC}"
sleep 5s
echo "${LCYAN}Your temporary password for MySQL root user is '${RED}$mypass${NC}${LCYAN}', this can be changed by running the following command in MySQL: alter user 'root'@'localhost' identified with mysql_native_password by 'PASSWORD'; "
sleep 2s
echo "${LCYAN}Please ensure that you update this password in ${BLUE}/var/www/html/results/telemetry_settings.php${NC}${LCYAN}. This is also where you can change the password for the status page.${NC}"