VER=git
COMPRESS=gzip

PACKAGES="$(shell sed '/^*/d' packages.list)"
kver_FILE=work/root-image/etc/mkinitcpio.d/kernel26.kver
ARCH?=$(shell uname -m)
PWD:=$(shell pwd)
FULLNAME=$(PWD)/MonkeyTool-$(VER)-$(ARCH)

all: clean monkeytool

monkeytool: base-fs
	sudo sh -c "echo 'MonkeyTool $(ARCH) $(VER)' > work/iso/version.txt"
	sudo sh -c "date -u >> work/iso/version.txt"
	sudo mkarchiso -L MonkeyTool -D monkey -c $(COMPRESS) -p syslinux iso work $(FULLNAME).iso

base-fs: root-image boot-files syslinux initcpio overlay iso-mounts

root-image: work/root-image/.arch-chroot
work/root-image/.arch-chroot:
root-image:
	sudo mkarchiso -D monkey -c $(COMPRESS) -p $(PACKAGES) create work

	./getaur.sh
	sudo pacman -U packages/*.pkg.* -r work/root-image/ --noconfirm

boot-files: root-image
	sudo cp -r boot-files work/iso/boot
	sudo cp work/root-image/boot/System.map26 work/iso/boot/
	sudo cp work/root-image/boot/vmlinuz26 work/iso/boot/

syslinux: root-image
	sudo cp -r syslinux work/iso/syslinux
	sudo cp work/root-image/usr/lib/syslinux/isolinux.bin work/iso/syslinux/
	sudo cp -r work/root-image/usr/lib/syslinux/*.c32 work/iso/syslinux/

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
	sudo rm -rf work $(FULLNAME).iso

.PHONY: all monkeytool
.PHONY: base-fs
.PHONY: root-image boot-files syslinux initcpio overlay iso-mounts
.PHONY: clean
