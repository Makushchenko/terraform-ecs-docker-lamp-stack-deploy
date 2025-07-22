apt update
apt -y install apache2
echo "<?php
phpinfo();
?>
" > index.php
mv index.php /var/www/html/ && rm /var/www/html/index.html
apt-get -y install php libapache2-mod-php php-mysql
apt-get -y install mysql-server
