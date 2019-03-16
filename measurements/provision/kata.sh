#!/bin/sh

if [ ! -x /usr/bin/kata-runtime ]; then
    ARCH=$(arch)
    sh -c \
       "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/stable-1.5/xUbuntu_$(lsb_release -rs)/ /' \
  > /etc/apt/sources.list.d/kata-containers.list"
    curl -sL \
         http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/master/xUbuntu_$(lsb_release -rs)/Release.key \
        | apt-key add -
    apt-get update
    apt-get -y install kata-runtime kata-proxy kata-shim
fi
