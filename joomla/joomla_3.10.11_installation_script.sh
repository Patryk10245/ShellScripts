#!/bin/bash
#
# This script is an installator for Joomla 3.10.11
# You can install every part separately or install everything at once.
# Tested on Debian
#
echo "Welcome in this installator"

printf "1. Install everything \n
2. Install Apache2 \n
3. Install PHP \n
4. Install MariaDB \n
5. Install MySQL \n
6. Install Joomla \n \n"

echo "What do you want to install?"

installApache2(){
	apt-get update | apt-get upgrade
    echo "Installing apache2"
	apt-get install apache2
	echo "Installation completed"
	apache2 -v
	systemctl status apache2.service
	systemctl start apache2.serice | systemctl enable apache2.service
	echo "Now we need to allow TCP ports"
	ufw allow 80/tcp | ufw allow 443/tcp
	ufw status
	ufw enable
	echo "What name of your domain you want to set?"
	read domain
	mkdir -p /var/www/$domain
	chown -R www-data:www-data /var/www/$domain
	chmod -R 755 /var/www/$domain
	echo "Do you want to config index.html? [Y/n]"
	read INDEX
	if [[ "$INDEX" == 'Y' ]] || [[ "$INDEX" == 'y' ]]; then
	nano /var/www/$domain/index.html
	fi
	printf "Here is your IP \n"
	hostname -I

}

installphp(){
	apt-get install php php-common php-cli php-fpm php-json php-pdo php-mysql php-zip
	apt-get install php-gd php-mbstring php-curl php-xml php-pear php-bcmath
	apt-get install libapache2-mod-php
}

installMariaDB(){
	apt-get install mariadb-server
	mysql_secure_installation
}
installMySQL(){
	apt-get wget
	wget 'https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb'
	apt-get install ./mysql-apt-config_0.8.22-1_all.deb
	apt-get install mysql-server
}
installJoomla(){
	echo "Do you want to config a php.ini? [Y/n]"
	read VALUE
	if [[ "$VALUE" == 'Y' ]] || [[ "$VALUE" == 'y' ]]; then
	nano /etc/php/7.4/cli/php.ini
	fi
	systemctl start apache2
	systemctl start mariadb
	mysql_secure_installation
	mysql -u root -p
	wget 'https://downloads.joomla.org/cms/joomla3/3-10-11/Joomla_3-10-11-Stable-Full_Package.zip'
	mkdir /var/www/joomla
	unzip Joomla_3-10-11-Stable-Full_Package.zip -d /var/www/joomla/
	chown -R www-data:www-data /var/www/joomla/
	chmod -R 755 /var/www/joomla/
	systemctl restart apache2
	nano /etc/apache2/sites-available/joomla.conf
	a2dissite 000-default.conf
	a2ensite joomla.conf
	systemctl restart apache2
	printf "\nHere is your IP\n"
	hostname -I
}
installEverything(){
	installApache2
	installphp
	installMariaDB
	installMySQL
	installJoomla
}
read NUMBER

case $NUMBER in
	1)
	echo "Installing everything"
	installEverything
	;;

	2)
	echo "Installing Apache2"
	installApache2
	;;

	3)
	echo "Installing PHP"
        installphp
	;;

	4)
	echo "Installing MariaDB"
	installMariaDB
	;;

	5)
	echo "Installing MySQL"
	installMySQL
	;;

	6)
	echo "Installing Joomla 3"
	installJoomla
	;;

	*)
	printf "Wrong number. Please choose one from list\n" ;;

esac

if [[ "$NUMBER" -le "6" ]] && [[ "$NUMBER" -gt "0" ]]; then
	printf "\nInstallation completed\n"
fi
