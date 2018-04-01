FROM php:latest

MAINTAINER Caio César Tavares <caiotava@gmail.com>

#---------------------------------------------------
# Software Instalation
#---------------------------------------------------

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        vim \
        libncurses5-dev \
        ncurses-doc \
        libncursesw5-dev \
        wget \
    && apt-get clean

#--------------------------------------------------
# Composer
#--------------------------------------------------

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');"

#-------------------------------------------------
# Ncurses Ext instalation
#
# @see https://stackoverflow.com/questions/39151234/install-ncurses-extensions-on-php7-0/47542051#47542051?newreg=43558a95980b4ba3868b955a79fa1057
#-------------------------------------------------
RUN cd ~/ && \
    pecl download ncurses && \
    mkdir ~/ncurses && \
    cd ~/ncurses && \
    tar -xvzf ~/ncurses-1.0.2.tgz && \
    wget "https://bugs.php.net/patch-display.php?bug_id=71299&patch=ncurses-php7-support-again.patch&revision=1474549490&download=1" -O ~/ncurses/ncurses.patch && \
    mv ncurses-1.0.2 ncurses-php5 && \
    patch --strip=0 --verbose --ignore-whitespace < ~/ncurses/ncurses.patch && \
    cd ncurses-php5 && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    docker-php-ext-enable ncurses && \
    rm -Rf ~/ncurses ~/ncurses-1.0.2 ~/channels.xml

WORKDIR /app
