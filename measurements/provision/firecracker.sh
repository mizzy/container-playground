#!/bin/sh

if [ ! -x /usr/local/bin/firecracker ]; then
    sudo apt install -y musl-tools
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    export PATH=$PATH:$HOME/.cargo/bin
    rustup target add x86_64-unknown-linux-musl

    git clone https://github.com/firecracker-microvm/firecracker
    cd firecracker
    git checkout v0.12.0
    cargo build --release --features vsock
    cp target/x86_64-unknown-linux-musl/release/{firecracker,jailer} \
       /usr/local/bin
    
    setfacl -m u:vagrant:rw /dev/kvm
fi
