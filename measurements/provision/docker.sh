#!/bin/sh

if [ ! -x /usr/bin/docker ]; then
    apt-get remove docker docker-engine docker.io containerd runc
    apt-get -y install \
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

    cat <<EOF > /etc/docker/daemon.json
{
    "runtimes": {
        "runsc": {
            "path": "/usr/local/bin/runsc"
        },
        "kata-runtime": {
            "path": "/usr/bin/kata-runtime"
        },
        "runnc": {
            "path": "/usr/local/bin/runnc"
        }
    }
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi
