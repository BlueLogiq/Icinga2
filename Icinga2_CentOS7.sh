#!/bin/bash
clear
echo -e "\e[1;34mInstall Icinga 2 & Icinga Web 2\e[0m"
echo " "
read -p "Enter desired database name and press [ENTER]: " var_db
read -p "Enter desired database username and press [ENTER]: " var_un
read -p "Enter desired database username password and press [ENTER]: " var_up
read -p "Enter your Country and press [Enter]: " var_tzc
read -p "Enter your State and press [ENTER]: " var_tzs
var_ip=$(hostname -I)
echo
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
yum install httpd-devel wget -y
sudo rpm --import http://packages.icinga.org/icinga.key
sudo wget http://packages.icinga.org/epel/ICINGA-release.repo -O /etc/yum.repos.d/ICINGA-release.repo
sudo yum makecache
sudo yum install icinga2 -y
sudo systemctl enable icinga2 && sudo systemctl start icinga2
sudo yum install icinga2-ido-mysql epel-release nagios-plugins-all mariadb-server mariadb -y
sudo systemctl start mariadb && sudo systemctl enable mariadb
clear
mysql_secure_installation
echo "CREATE DATABASE $var_db;" | mysql -u root -p
echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga2.* TO $var_un@'localhost' IDENTIFIED BY '$var_up';" | mysql -u root -p
mysql -u root -p icinga2 < /usr/share/icinga2-ido-mysql/schema/mysql.sql
sed -i "s/\/\/user = \"icinga\"/user = \"$var_un\"/g" /etc/icinga2/features-available/ido-mysql.conf
sed -i "s/\/\/password = \"icinga\"/password = \"$var_up\"/g" /etc/icinga2/features-available/ido-mysql.conf
sed -i 's/\/\/host = "localhost"/host = "localhost"/g' /etc/icinga2/features-available/ido-mysql.conf
sed -i "s/\/\/database = \"icinga\"/database = \"$var_db\"/g" /etc/icinga2/features-available/ido-mysql.conf
sudo icinga2 feature enable ido-mysql && sudo icinga2 feature enable command
sudo systemctl restart icinga2
sudo yum install php-gd php-intl php-ZendFramework php-pear php-pdo php-soap php-ldap php-cli php-common php-devel php-mbstring php-mysql php-xml -y
sudo yum install icingaweb2 icingacli -y
sed -i "s/;date.timezone =/date.timezone = \"$var_tzc\/$var_tzs\"/g" /etc/php.ini
sudo systemctl start httpd
sudo systemctl enable httpd
clear
echo "The Icinga setup token will now be created."
echo "Please copy this token, reboot your server and open your browser to:"
read -p "http://$var_ip/icingaweb2/setup -- Press [ENTER] to continue."
echo "--"
icingacli setup token create
echo "--"
echo "Database: $var_db"
echo "User: $var_un"
echo "Pass: $var_up"
