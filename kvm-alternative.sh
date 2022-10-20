#!/bin/bash
echo "This quick installer script requires root privileges."
echo "Checking..."
if [[ $(/usr/bin/id -u) -ne 0 ]]; 
then
    echo "Not running as root"
    exit 0
else
        echo "Installation continues"
fi

SUDO=
if [ "$UID" != "0" ]; then
        if [ -e /usr/bin/sudo -o -e /bin/sudo ]; then
                SUDO=sudo
        else
                echo "*** This quick installer script requires root privileges."
                exit 0
        fi
fi
#Define variables for the virtual machine installation
name="debian-11"
ram="--ram=4096"
cpu="--vcpus=2"
os="--os-variant=debian11"
acc="--accelerate"
disk="--disk /var/lib/libvirt/images/$name.qcow2,device=disk,size=20,sparse=yes,cache=none,format=qcow2,bus=virtio"
network="--network=bridge:br-ex,model=virtio,virtualport_type=openvswitch"
graphics="--graphics none"
console="--console pty,target_type=serial"
#location="--location=/iso/debian-11.5.0-amd64-netinst.iso"
location="--location 'http://ftp.nl.debian.org/debian/dists/bullseye/main/installer-amd64/'"
machine_type="--virt-type qemu"

echo "Create a disk for a virtual machine"
#qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/images/$name.qcow2 20G
virt-builder debian-11 --format qcow2 --size 20G -o /var/lib/libvirt/images/$name.qcow2
echo "Install a virtual machine:"
virt-install --name=$name $ram $cpu $os $acc $disk $network $graphics $console $location $machine_type --extra-args 'console=ttyS0,115200n8 serial'
