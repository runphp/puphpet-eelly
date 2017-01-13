#!/bin/bash

cp /vagrant/install/php/cphalcon-phalcon-v2.0.13.tar.gz  ./
tar xzf cphalcon-phalcon-v2.0.13.tar.gz
cd cphalcon-phalcon-v2.0.13/build
./install
tee /etc/php.d/phalcon.ini <<< 'extension=phalcon.so'
service php-fpm restart
