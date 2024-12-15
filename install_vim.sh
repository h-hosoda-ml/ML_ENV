#!/bin/bash

apt-get install -y git make
cd /root
git clone https://github.com/vim/vim.git
cd vim
git pull
cd src
make distclean
make
make install