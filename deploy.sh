#!/bin/sh

set -e

warn() { echo "$@" >&2; }
die() { echo "$@" >&2; exit 255; }

deploy() {
	pkg=$1
	tar=$2

	warn "Deploying $pkg"

	var=rootfs/var/lib/pacman/local/$pkg

	test -d "$var" && die "Package $pkg is already in rootfs/"
	mkdir -p "$var"

	rm -f rootfs/.[A-Z]*
	bsdtar -C rootfs -xvf "$tar" 2>&1 |\
		sed -e '1i%FILES%' -e 's/^x //;/\/$/d;/^\./d;' \
		> "$var/files"
	mv rootfs/.PKGINFO "$var/desc"
	rm -f rootfs/.[A-Z]*
}

rm -fr rootfs
mkdir rootfs

