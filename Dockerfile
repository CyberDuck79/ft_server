FROM debian:buster-slim

# To avoid annoying warnings
ENV DEBIAN_FRONTEND noninteractive
# Mkcert url (Certificate generation util)
ARG MKCERT_URL=https://github.com/FiloSottile/mkcert/releases/download/v1.1.2/mkcert-v1.1.2-linux-amd64

# Package installation
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \
	nginx \
	mariadb-server \
	php \
	php-mysql \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-xmlrpc \
	php-soap \
	php-intl \
	php-zip \
	php-cli \
	php-cgi \
	php-dev \
	php-fpm \
	php-apcu \
	php-pear \
	php-imap \
	php-pspell \
	php-dom \
	php-json \
	wget \
	libnss3-tools

# SSL key generation
RUN wget -O ~/mkcert $MKCERT_URL; \
	cd && chmod +x ./mkcert && ./mkcert -install && ./mkcert localhost; \
	rm -rf ~/mkcert && apt-get remove --autoremove wget libnss3-tools -y

# Nginx web server setup
RUN mkdir -p /var/www/localhost;
COPY ./srcs/nginx-conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
RUN rm /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-available/default
# Index files
COPY ./srcs/index.html /var/www/localhost
COPY ./srcs/index.css /var/www/localhost
COPY ./srcs/rubber_ducky.jpg /var/www/localhost
COPY ./srcs/quack.mp3 /var/www/localhost

# Database setup
RUN service mysql start; \
	echo "CREATE DATABASE wordpress;" | mysql -u root; \
	echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';" | mysql -u root; \
	echo "FLUSH PRIVILEGES;" | mysql -u root; \
	echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

# Wordpress setup
COPY ./srcs/wordpress.tar.gz /var/www/localhost/
RUN cd /var/www/localhost/ && tar xzf wordpress.tar.gz && rm wordpress.tar.gz

# PhpMyAdmin setup
COPY ./srcs/phpmyadmin.tar.gz /var/www/localhost/
RUN cd /var/www/localhost/ && tar xzf phpmyadmin.tar.gz && rm phpmyadmin.tar.gz

# Nginx permissions
RUN chown -R www-data:www-data /var/www/* && chmod -R 755 /var/www/*

# Server initialization script
COPY ./srcs/start.sh ./

EXPOSE 80 443

CMD ["bash", "start.sh"]
