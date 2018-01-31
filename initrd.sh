#!/bin/sh

set -e

sdst=initrd/sbin
ssrc=rootfs/sbin

rm -fr $sdst; mkdir -p $sdst

cp -at $sdst $ssrc/system/findblk
cp -at $sdst $ssrc/system/switchroot
cp -at $sdst $ssrc/system/reboot
cp -at $sdst $ssrc/service/udevmod
cp -at $sdst $ssrc/modprobe
cp -at $sdst $ssrc/runwith
cp -at $sdst $ssrc/kmount
cp -at $sdst $ssrc/msh

linux=`ls rootfs/var/lib/pacman/local | grep 'linux-[3-9]'`
kver=`echo "$linux" | sed -e 's/linux-//' -e 's/$/-ARTIX/'`

msrc=rootfs/lib/modules/$kver/kernel
mdst=initrd/lib/modules/$kver/kernel

rm -fr $mdst; mkdir -p $mdst

addkobj() {
	ksrc="$msrc/$1"
	kdst="$mdst/$1"
	ddir=`dirname "$kdst"`
	test -f "$kdst" && return
	mkdir -p "$ddir"
	cp -a "$ksrc" "$kdst"
}

addmod() {
	modprobe -d rootfs -S $kver --show-depends $@ |\
		sed -e "s!.*/$kver/kernel/!addkobj !" > addmod.tmp 
	source ./addmod.tmp
	rm addmod.tmp
}

addall() {
	find "$msrc/$1" -name "*.ko*" | while read i; do
		m=`basename "$i" | sed -e 's/\.ko.*$//'`
		test -n "$m" && addmod "$m"
	done
}

addmod ext4
addmod xhci-hcd
addmod uhci-hcd
addmod ehci-hcd
addmod usb_storage

addmod cdrom
#addmod i8042
addmod ata_piix
addmod sd_mod
addmod sr_mod

find $mdst -name '*.ko.xz' -exec xz -d \{\} \;

cp -at initrd/lib/modules/$kver rootfs/lib/modules/$kver/modules.{builtin,order}
depmod -b initrd $kver
rm initrd/lib/modules/$kver/*.bin

(cd initrd && find . | cpio -oH newc) | gzip -c > initrd.img
