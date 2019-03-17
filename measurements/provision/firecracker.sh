#!/bin/bash

if [ ! -x /usr/local/bin/firecracker ]; then
    sudo apt install -y musl-tools
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    export PATH=$PATH:$HOME/.cargo/bin
    rustup target add x86_64-unknown-linux-musl

    git clone https://github.com/firecracker-microvm/firecracker
    pushd firecracker
    git checkout v0.12.0
    cargo build --release --features vsock
    cp target/x86_64-unknown-linux-musl/release/{firecracker,jailer} \
       /usr/local/bin
    popd
    
    setfacl -m u:vagrant:rw /dev/kvm
fi

if [ ! -x /usr/local/bin/containerd-shim-aws-firecracker ]; then
    git clone \
        https://github.com/firecracker-microvm/firecracker-containerd
    pushd firecracker-containerd
    GO111MODULE=on make STATIC_AGENT=true
    cp runtime/containerd-shim-aws-firecracker /usr/local/bin
    cp snapshotter/cmd/naive/naive_snapshotter /usr/local/bin
    popd
fi


if [ ! -f hello-vmlinux.bin ]; then
    curl -fsSL -o hello-vmlinux.bin \
         https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
    curl -fsSL -o hello-rootfs.ext4 \
         https://s3.amazonaws.com/spec.ccfc.min/img/hello/fsfiles/hello-rootfs.ext4

    mkdir /tmp/mnt

    cat >fc-agent.start <<EOF
#!/bin/sh
mkdir -p /container
exec > /container/agent-debug.log # Debug logs from the agent
exec 2>&1
touch /container/runtime
mkdir /container/rootfs
mount -t auto -o rw /dev/vdb /container/rootfs
cd /container
/usr/local/bin/agent -id 1 -debug &
EOF

    chmod +x fc-agent.start
    truncate --size=+50M hello-rootfs.ext4
    /sbin/e2fsck -f hello-rootfs.ext4 -y
    /sbin/resize2fs hello-rootfs.ext4
    mount hello-rootfs.ext4 /tmp/mnt
    cp $(which runc) firecracker-containerd/agent/agent /tmp/mnt/usr/local/bin
    cp fc-agent.start /tmp/mnt/etc/local.d
    ln -s /etc/init.d/local /tmp/mnt/etc/runlevels/default/local
    ln -s /etc/init.d/cgroups /tmp/mnt/etc/runlevels/default/cgroups
    umount /tmp/mnt
    rmdir /tmp/mnt

    mkdir -p /etc/containerd
    tee -a /etc/containerd/config.toml <<EOF
[proxy_plugins]
  [proxy_plugins.firecracker-naive]
    type = "snapshot"
    address = "/var/run/firecracker-containerd/naive-snapshotter.sock"
EOF

    mkdir -p /var/lib/firecracker-containerd/runtime
    cp hello-rootfs.ext4 hello-vmlinux.bin \
       /var/lib/firecracker-containerd/runtime
    mkdir -p /etc/containerd
    tee -a /etc/containerd/firecracker-runtime.json <<EOF
{
  "firecracker_binary_path": "/usr/local/bin/firecracker",
  "socket_path": "./firecracker.sock",
  "kernel_image_path": "/var/lib/firecracker-containerd/runtime/hello-vmlinux.bin",
  "kernel_args": "console=ttyS0 noapic reboot=k panic=1 pci=off nomodules rw",
  "root_drive": "/var/lib/firecracker-containerd/runtime/hello-rootfs.ext4",
  "cpu_count": 1,
  "cpu_template": "T2",
  "console": "stdio",
  "log_fifo": "/tmp/fc-logs.fifo",
  "log_level": "Debug",
  "metrics_fifo": "/tmp/fc-metrics.fifo"
}
EOF

    modprobe vhost-vsock
fi
