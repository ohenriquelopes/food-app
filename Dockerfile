FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    openssl

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt update -y
RUN apt install nodejs -y
RUN npm install -g npm@latest

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY docker/.htaccess.example /var/www/html/.htaccess

RUN a2enmod rewrite
RUN a2enmod ssl                              

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer clear-cache
RUN composer self-update
RUN composer install --no-interaction

COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

COPY docker/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY docker/fake-cert.crt /etc/ssl/certs/fake-cert.crt
COPY docker/chave_privada.key /etc/ssl/private/chave_privada.key
RUN a2ensite default-ssl
RUN a2enmod headers
RUN a2enmod ssl
# RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert.key -out /etc/ssl/certs/ssl-cert.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com" 
# Cria certificado autogerado (não recomendado para uso em produção)

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80 443

CMD ["apache2-foreground"]
