#!/bin/bash

cp /vagrant/install/php/cphalcon-3.0.4.tar.gz ./
tar xzf cphalcon-3.0.4.tar.gz
cd cphalcon-3.0.4/build
./install
tee /etc/php.d/phalcon.ini <<< 'extension=phalcon.so'
service php-fpm restart
