#!/bin/bash

db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_endpoint=${db_endpoint}
# EFS_FS_ID="fs-xxxxxxxxx"

sudo dnf update -y

#install wget, apache server, php and efs utils
sudo dnf install -y httpd mariadb105 wget php-fpm php-mysqli php-json php amazon-efs-utils 

#create wp-content mountpoint
# sudo mkdir -p /var/www/html/wp-content
# mount -t efs $EFS_FS_ID:/ /var/www/html/wp-content

#install wordpress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz
sudo rm latest.tar.gz
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

#change wp-config with DB details
sudo sed -i "s/database_name_here/${db_name}/g" /var/www/html/wordpress/wp-config.php # sudo sed -i "s/database_name_here/wordpressdb/g" /var/www/html/wordpress/wp-config.php 
sudo sed -i "s/username_here/${db_username}/g" /var/www/html/wordpress/wp-config.php # sudo sed -i "s/username_here/sanou/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/${db_user_password}/g" /var/www/html/wordpress/wp-config.php # sudo sed -i "s/password_here/password/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/${db_endpoint}/g" /var/www/html/wordpress/wp-config.php # sudo sed -i "s/localhost/wordpress-rds-instance.cbgy0ouc03so.eu-west-3.rds.amazonaws.com/g" /var/www/html/wordpress/wp-config.php

cat <<EOF | sudo tee -a /var/www/html/wordpress/wp-config.php
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '256M');
EOF

#change httpd.conf file to allowoverride
#  enable .htaccess files in Apache config using sed command
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# sudo usermod -a -G apache ec2-user
# sudo chown -R ec2-user:apache /var/www
# sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
# sudo find /var/www -type f -exec sudo chmod 0664 {} \;
# chown apache:apache -R /var/www/html

# create phpinfo file
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# Recursively change OWNER of directory /var/www and all its contents
sudo chown -R apache:apache /var/www

sudo systemctl restart httpd
sudo systemctl enable httpd
