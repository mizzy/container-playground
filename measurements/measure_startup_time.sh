#!/bin/bash

pushd bundle

cp config.json.for_non_nabla config.json

# runc
echo "##### runc"
time sudo runc run bundle
echo

# gVisor
echo "##### gVisor"
time sudo runsc -log /dev/null run bundle
echo

# Kata Containers
echo "##### Kata Containers"
time sudo kata-runtime run bundle

cp config.json.for_nabla config.json

# Nabla Containers
# https://github.com/nabla-containers/runnc/issues/53
sudo runnc create abcdefg123456 && sudo runnc --debug start abcdefg123456

sudo runnc delete abcdefg123456

popd
