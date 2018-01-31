dropin = $(shell find dropin -type f)
chache = $(shell find cached -type f -name '*.pkg.tar.xz')

whole.img: bootfs.img rootfs.img
	./whole.sh

rootfs.img: rootfs.px $(dropin) $(cache)
	./rootfs.px

bootfs.img: bootfs.sh initrd.img bootfs/syslinux.cfg
	./bootfs.sh

initrd.img: initrd.sh rootfs.img initrd/init initrd/etc/*
	./initrd.sh

update:
	rm -fr repos
	./rootfs.px

clean:
	rm -fr rootfs.img rootfs rootfs.tmp
	rm -fr initrd.img initrd/{lib,sbin}
	rm -fr bootfs.img bootfs/linux

distclean: clean
	rm -fr cache repos
	rm -fr build/*/{src,pkg}
	rm -f build/*/*.pkg.tar.xz
