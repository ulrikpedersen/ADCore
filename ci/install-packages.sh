#!/bin/bash

# Installing latest version of code coverage tool lcov (because the ubuntu package is very old)
wget http://downloads.sourceforge.net/ltp/lcov-1.11.tar.gz
tar -zxf lcov-1.11.tar.gz
sudo make -C lcov-1.11 install
gem install coveralls-lcov
