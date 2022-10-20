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

#Define variables for the virtual machine installation
name="opensuse-13.2"
ram="--ram=2048"
disk="--disk path=/var/lib/libvirt/images/$name.qcow2"
cpu="--vcpus=2"
os="--os-variant=opensuse13.2"
network="--network bridge=br-ex,model=virtio,virtualport_type=openvswitch"
graphics="--graphics none"
serial="--serial pty"
console="--console pty"
boot="--boot hd"
import="--import"
# Uncomment one of the below and modify if you need to install it from iso or directly from the network location and add $location after $import in the last command.
#location="--location=/iso/debian-11.5.0-amd64-netinst.iso"
#location="--location 'http://ftp.nl.debian.org/debian/dists/bullseye/main/installer-amd64/'"

echo "Create a file that contains a root password"
cd /home/username
touch password
echo "Strong_password" > password
chmod 0600 password

echo "Create a disk for a virtual machine"
virt-builder opensuse-13.2  --format qcow2 --size 20G -o /var/lib/libvirt/images/$name.qcow2 --root-password file:/home/username/password

echo "Install a virtual machine:"
virt-install --name=$name $ram $disk $cpu $os $network $graphics $serial $console $boot $import 
