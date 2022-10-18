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

echo "Add a network repository"
zypper addrepo https://download.opensuse.org/repositories/network/15.4/network.repo | echo 'a'
echo "Refresh repositories"
zypper refresh

echo "Installation of the packages"
zypper install -y -t pattern kvm_server
zypper install -y -t pattern kvm_tools
zypper install -y libvirt
zypper install -y virt-manager
zypper install -y qemu-kvm
zypper install -y bridge-utils
zypper install -y libnetcontrol0
zypper install -y libibverbs

systemctl status kvm_stat.service
systemctl start kvm_stat.service
systemctl enable kvm_stat.service
systemctl is-enabled kvm_stat.service
systemctl status kvm_stat.service

systemctl status libvirtd.service
systemctl start libvirtd.service
systemctl enable libvirtd.service
systemctl is-enabled libvirtd.service
systemctl status libvirtd.service

cd /root
mkdir iso
cd iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.5.0-amd64-netinst.iso

#Define variablesfor the virtual machine installation
name="debian"
ram="--ram=4096"
cpu="--vcpus=2"
os="--os-variant=debian11"
acc="--accelerate"
disk="--disk /var/lib/libvirt/images/debian11.qcow2,device=disk,size=10,sparse=yes,cache=none,format=qcow2,bus=virtio"
network="--network type=direct,source=br-ex,model=virtio"
graphics="--graphics none"
console="--console pty,target_type=serial"
location="--location=/root/iso/debian-11.5.0-amd64-netinst.iso"
extra="--extra-args 'console=ttyS0,115200n8 serial'"
type="--virt-type qemu"

# preallocation=metadata - See the explanation: https://www.jamescoyle.net/how-to/1810-qcow2-disk-images-and-performance 
echo "Create a disk for a virtual machine"
qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/images/$name.qcow2 10G

echo "Install a virtual machine:"
virt-install --name=$name $ram $cpu $os $acc $disk $network $graphics $console $location $extra $type
