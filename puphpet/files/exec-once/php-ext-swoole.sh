#!/bin/bash

cp /vagrant/install/php/swoole-src-2.0.7.tar.gz ./
tar xzf swoole-src-2.0.7.tar.gz
 cd swoole-src-2.0.7
phpize
php-config
./configure
make
make install
tee /etc/php.d/swoole.ini <<< 'extension=swoole.so'
service php-fpm restart
