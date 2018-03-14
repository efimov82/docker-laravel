FROM ubuntu
MAINTAINER Danil Efimov <efimov82@gmail.com>

# ensure UTF-8
#RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8

# change resolv.conf
RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# setup
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# nginx-php installation
RUN apt-get -y update &&\
    apt-get -y upgrade &&\
    apt-get clean
    #&&\
    #apt-get install php7.2 php7.2-fpm php7.2-common php7.2-cli php7.2-mysql php7.2-mcrypt php7.2-curl php7.2-bcmath php7.2-mbstring  php7.2-xml php7.2-zip php7.2-json php7.2-imap php-xdebug &&\
    #apt-get clean

#RUN DEBIAN_FRONTEND="noninteractive" apt-get update
#RUN DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
#RUN DEBIAN_FRONTEND="noninteractive" apt-get update --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.0 php7.0-mysql php7.0-curl php7.0-mbstring php7.0-xml php7.0-zip php7.0-json php7.0-imap php-xdebug
#RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.2-fpm php7.2-common php7.2-cli php7.2-mysql php7.2-mcrypt 
#RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.2-curl php7.2-bcmath php7.2-mbstring  php7.2-xml php7.2-zip php7.2-json php7.2-imap php-xdebug

# install nginx (full)
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx-full

# install latest version of nodejs
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git

# install php composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# copy files from repo
ADD build/nginx.conf /etc/nginx/sites-available/default

# disable services start
RUN update-rc.d -f apache2 remove

# Add user
#RUN useradd -ms /bin/bash laravel_user
RUN useradd -c 'Project user' -m -d /home/laravel_user -s /bin/bash laravel_user
#RUN chown -R node.node /src
USER laravel_user
ENV HOME /home/laravel_user

# add build script (also set timezone to Belarus/Minsk)
RUN mkdir -p $HOME/setup
ADD build/setup.sh $HOME/setup/setup.sh
ADD build/.bashrc $HOME/.bashrc
RUN chmod +x $HOME/setup/setup.sh
RUN $HOME/setup/setup.sh

#RUN (cd $HOME/setup/; /root/setup/setup.sh)


#RUN update-rc.d -f nginx remove
#RUN update-rc.d -f php7.0-fpm remove

# add startup scripts for nginx
#ADD build/nginx.sh /etc/service/nginx/run
#RUN chmod +x /etc/service/nginx/run

# add startup scripts for php7.0-fpm
#ADD build/phpfpm.sh /etc/service/phpfpm/run
#RUN chmod +x /etc/service/phpfpm/run

# set WWW public folder
RUN mkdir -p /var/www/public
RUN git clone https://github.com/efimov82/laravel-rest.git /var/www/public/laravel-rest
RUN (cd /var/www/public/laravel-rest; composer install)
#ADD build/index.php /var/www/public/index.php

RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www

# set terminal environment
#ENV TERM=xterm

# port and settings
EXPOSE 80 9000

# cleanup apt and lists
RUN apt-get clean
RUN apt-get autoclean
