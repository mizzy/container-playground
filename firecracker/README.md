# Firecracker

## Pointers

- [Firecracker](https://firecracker-microvm.github.io/)
- [firecracker-microvm/firecracker: Secure and fast microVMs for serverless computing.](https://github.com/firecracker-microvm/firecracker)
- [firecracker/getting-started.md at master · firecracker-microvm/firecracker](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md)

----

## Getting Started

If you use VirtualBox, firecracker does not work because VirtualBox does not support kvm.

### Building Firecracker

```sh
git clone https://github.com/firecracker-microvm/firecracker
cd firecracker
sudo tools/devtool build
sudo mv build/debug/firecracker /usr/local/bin
```

### Running Firecracker

Add permission to access to /dev/kvm.

```sh
sudo setfacl -m u:${USER}:rw /dev/kvm
```
In your first shell:

Start firecracker.

```sh
rm -f /tmp/firecracker.socket
firecracker --api-sock /tmp/firecracker.socket
```

In yousr second shell:

Get the kernel and rootfs.

```sh
curl -fsSL -o hello-vmlinux.bin \
  https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
curl -fsSL -o hello-rootfs.ext4 \
  https://s3.amazonaws.com/spec.ccfc.min/img/hello/fsfiles/hello-rootfs.ext4
```

Set the guest kernel.

```sh
curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT 'http://localhost/boot-source'   \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d '{
        "kernel_image_path": "/home/vagrant/hello-vmlinux.bin",
        "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
    }'
```

Set the rootfs.

```sh
curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT 'http://localhost/drives/rootfs' \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d '{
        "drive_id": "rootfs",
        "path_on_host": "/home/vagrant/hello-rootfs.ext4",
        "is_root_device": true,
        "is_read_only": false
    }'
```


Start the guest machine.

```sh
curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT 'http://localhost/actions'       \
    -H  'Accept: application/json'          \
    -H  'Content-Type: application/json'    \
    -d '{
        "action_type": "InstanceStart"
     }'
```

You can see login prompt in your first shell. You can login with root/root.
