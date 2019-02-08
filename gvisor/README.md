# gVisor Playground

## Overview

- [google/gvisor: Container Runtime Sandbox](https://github.com/google/gvisor)
- [gvisor/quick_start.md at master · google/gvisor](https://github.com/google/gvisor/blob/master/docs/user_guide/quick_start.md)

## Using runsc

### Run an OCI compatible container

```sh
mkdir bundle
cd bundle
mkdir rootfs
sudo docker export $(sudo docker create busybox) | tar -xf - -C rootfs
runsc spec
sudo runsc run hello
```

This does not show a command prompt, but you can execute commands.


```
$ ps -ef|grep runsc
root     15420 15365  0 09:15 pts/0    00:00:00 sudo runsc run hello
root     15421 15420  0 09:15 pts/0    00:00:00 runsc run hello
root     15426 15421  0 09:15 pts/0    00:00:00 runsc-gofer --root=/var/run/runsc --debug=false --log= --log-format=text --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 gofer --bundle /home/vagrant/bundle --spec-fd=3 --io-fds=4 --apply-caps=false --setup-root=false
nobody   15427 15421  2 09:15 ?        00:00:01 runsc-sandbox --root=/var/run/runsc --debug=false --log= --log-format=text --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 boot --bundle=/home/vagrant/bundle --controller-fd=3 --spec-fd=4 --start-sync-fd=5 --io-fds=6 --stdio-fds=7 --stdio-fds=8 --stdio-fds=9 hello
```
