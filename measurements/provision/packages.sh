#!/bin/sh

apt-get update

apt-get -y install gcc make pkg-config libseccomp-dev zlib1g-dev \
        silversearcher-ag
