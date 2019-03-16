#!/bin/bash

set -eux

make all

cid=`sudo docker create busybox`
mkdir -p bundle/rootfs
sudo docker export $cid | tar -C bundle/rootfs -xvf -
cp hello bundle/rootfs
cp loop bundle/rootfs

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
# https://github.com/rumpkernel/rumprun/issues/122
patch -p1 < /vagrant/netbsd.patch
popd
# https://github.com/rumpkernel/rumprun/pull/118
patch -p1 < /vagrant/rumprun.patch
make
. obj/config-PATH.sh
pushd rumprun-solo5/bin
patch -p1 < /vagrant/rumprun-bake.patch
popd

popd

x86_64-rumprun-netbsd-gcc -o hello.out hello.c
rumprun-bake solo5_ukvm_seccomp hello.nabla hello.out
cp hello.nabla bundle/rootfs

x86_64-rumprun-netbsd-gcc -o loop.out loop.c
rumprun-bake solo5_ukvm_seccomp loop.nabla loop.out
cp loop.nabla bundle/rootfs
