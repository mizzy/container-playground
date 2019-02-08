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

