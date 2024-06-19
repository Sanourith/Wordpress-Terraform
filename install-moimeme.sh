#! /bin/bash

db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_endpoint=${db_endpoint}

## Déploiement de la suite WordPress :

# Mise à jour système
sudo apt update && sudo apt upgrade -y
sudo apt install -y vim nginx mariadb-client php php-fpm php-curl php-mysql php-gd php-mbstring php-xml php-imagick php-zip php-xmlrpc software-properties-common curl zip unzip
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# Ajout du PPA pour la dernière version de PHP
sudo apt update && sudo apt upgrade -y

# Suppression d'Apache2 (si nécessaire)
sudo apt-get purge -y apache2

# Démarrage et activation de Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Préparation de WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz
sudo rm latest.tar.gz
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
 
# Configuration de wp-config.php avec les informations de la base de données
sudo sed -i "s/database_name_here/${db_name}/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/${db_username}/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/${db_user_password}/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/${db_endpoint}/g" /var/www/html/wordpress/wp-config.php

cat <<EOF | sudo tee -a /var/www/html/wordpress/wp-config.php
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '256M');
EOF

cat <<EOF | sudo tee -a /etc/nginx/conf.d/wordpress.conf 
server {
    listen 80;
    root /var/www/html/wordpress;
    index  index.php index.html index.htm;
    server_name  tf.sanou.cloudns.be;
    client_max_body_size 500M;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         include fastcgi_params;
    }
}
EOF

# fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

# Ajustements des permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Redémarrage des services PHP-FPM et Nginx
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx
sudo nginx -t

echo "WordPress a été installé et configuré avec succès."
echo "L'endpoint RDS est: ${db_endpoint}"