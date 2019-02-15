#!/bin/sh

apt-get update

if [ ! -x /usr/bin/docker ]; then
    apt-get remove docker docker-engine docker.io containerd runc
    apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | apt-key add -

    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    apt-get update

    apt-get -y install docker-ce docker-ce-cli containerd.io
fi
