#!/bin/bash

set -eux

make all

sudo docker build . -t image

cid=`sudo docker create image /hello`
mkdir -p rootfs
sudo docker export $cid | tar -C rootfs -xvf -

pushd ..

git clone https://github.com/nabla-containers/solo5.git
pushd solo5
./configure.sh
make
sudo cp kernel/ukvm/solo5.o /usr/lib/libsolo5_seccomp.a

popd

git clone https://github.com/nabla-containers/rumprun.git
pushd rumprun
git checkout 8b01b3
git submodule update --init
pushd src-netbsd
patch -p1 < /vagrant/netbsd.patch
popd
patch -p1 < /vagrant/rumprun.patch
CC=cc ./build-rr.sh solo5 -- -F CFLAGS="-Wimplicit-fallthrough=0 -Wno-maybe-uninitialized"
CC=cc ./build-rr.sh solo5 -- -F CFLAGS="-Wimplicit-fallthrough=0"
. obj/config-PATH.sh
sudo cp solo5/tenders/spt/solo5-spt /usr/local/bin

popd

git clone https://github.com/nabla-containers/nabla-base-build
pushd nabla-base-build
git submodule update --init --recursive

popd

popd

x86_64-rumprun-netbsd-gcc -o hello.out hello.c
rumprun-bake solo5_ukvm_seccomp hello.nabla hello.out

x86_64-rumprun-netbsd-gcc -o loop.out loop.c
rumprun-bake solo5_spt loop.nabla loop.out




sudo docker build . -t image-for-nabla -f Dockerfile_for_nabla
