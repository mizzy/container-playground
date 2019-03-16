#!/bin/sh

if [ ! -x /usr/local/bin/runsc ]; then
    wget -q https://storage.googleapis.com/gvisor/releases/nightly/latest/runsc
    wget -q https://storage.googleapis.com/gvisor/releases/nightly/latest/runsc.sha512
    sha512sum -c runsc.sha512
    chmod a+x runsc
    mv runsc /usr/local/bin
fi
