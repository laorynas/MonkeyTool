VER=git
COMPRESS=gzip

PACKAGES="$(shell sed '/^*/d' packages.list)"
kver_FILE=work/root-image/etc/mkinitcpio.d/kernel26.kver
ARCH?=$(shell uname -m)
PWD:=$(shell pwd)
FULLNAME="$(PWD)"/MonkeyTool-$(VER)-$(ARCH)

all: clean monkeytool

monkeytool: base-fs
	sudo mkarchiso -L MonkeyTool -D monkey -c $(COMPRESS) -p syslinux iso work "$(FULLNAME)".iso

base-fs: root-image boot-files initcpio overlay iso-mounts

root-image: work/root-image/.arch-chroot
work/root-image/.arch-chroot:
root-image:
	sudo mkarchiso -D monkey -c $(COMPRESS) -p $(PACKAGES) create work

	echo "====> Installing AUR packages..."
	./getaur.sh
	sudo pacman -U packages/*.pkg.* -r work/root-image/ --noconfirm

boot-files: root-image
	sudo mkdir -p work/iso/boot
	sudo cp work/root-image/boot/System.map26 work/iso/boot/
	sudo cp work/root-image/boot/vmlinuz26 work/iso/boot/
	sudo cp -r boot-files/syslinux/ work/iso/
	sudo cp work/root-image/usr/lib/syslinux/isolinux.bin work/iso/syslinux/
	sudo cp boot-files/memtest work/iso/boot/

initcpio: work/iso/boot/kernel26.img
work/iso/boot/kernel26.img: mkinitcpio.conf work/root-image/.arch-chroot
	sudo mkdir -p work/iso/boot
	sudo mkinitcpio -c ./mkinitcpio.conf -b work/root-image -k `uname -r` -g $@

overlay:
	sudo cp -r overlay work/

iso-mounts: work/iso/monkey/isomounts
work/iso/monkey/isomounts: isomounts root-image
	sudo sh -c "sed 's|@ARCH@|$(ARCH)|g' isomounts > $@"

clean:
	sudo rm -rf work "$(FULLNAME)".iso

.PHONY: all monkeytool
.PHONY: base-fs
.PHONY: root-image boot-files initcpio overlay iso-mounts
.PHONY: clean
