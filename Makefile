WORKDIR=work
INSTALL_DIR=monkey# max 8 chars.
COMPRESS=gzip
#  A list of packages to install, either space separated in a string or line separated in a file. Can include groups.
PACKAGES="$(shell cat packages.list) syslinux"
# The name of our ISO. Does not specify the architecture!
NAME=monkeytool
# Version will be appended to the ISO.
VER=0.01
# Kernel version. You'll need this. Don't change it.
kver_FILE=$(WORKDIR)/root-image/etc/mkinitcpio.d/kernel26.kver
# Architecture will also be appended to the ISO name.
ARCH?=$(shell uname -m)
# Current working directory
PWD:=$(shell pwd)
# This is going to be the full name the final iso/img will carry
FULLNAME="$(PWD)"/$(NAME)-$(VER)-$(ARCH)

# Default make instruction to build everything.
all: monkeytool

# The following will first run the base-fs routine before creating the final iso image.
monkeytool: base-fs
	mkarchiso -L MonkeyTool -D $(INSTALL_DIR) -c $(COMPRESS) -p syslinux iso "$(WORKDIR)" "$(FULLNAME)".iso

# This is the main rule for make the working filesystem. It will run routines from left to right. 
# Thus, root-image is called first and syslinux is called last.
base-fs: root-image boot-files initcpio overlay iso-mounts

# The root-image routine is always executed first. 
# It only downloads and installs all packages into the $WORKDIR, giving you a basic system to use as a base.
root-image: "$(WORKDIR)"/root-image/.arch-chroot
"$(WORKDIR)"/root-image/.arch-chroot:
root-image:
	mkarchiso -D $(INSTALL_DIR) -c $(COMPRESS) -p $(PACKAGES) create "$(WORKDIR)"
	pacman -U packages/seeker-*-$(ARCH).pkg.* -r "$(WORKDIR)"/root-image/ --noconfirm

# Rule for make /boot
boot-files: root-image
	mkdir -p $(WORKDIR)/iso/boot
	cp $(WORKDIR)/root-image/boot/System.map26 $(WORKDIR)/iso/boot/
	cp $(WORKDIR)/root-image/boot/vmlinuz26 $(WORKDIR)/iso/boot/
	cp -r boot-files/syslinux/ $(WORKDIR)/iso/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/isolinux.bin $(WORKDIR)/iso/syslinux/
	cp boot-files/memtest $(WORKDIR)/iso/boot/

# Rules for initcpio images
initcpio: "$(WORKDIR)"/iso/boot/kernel26.img
"$(WORKDIR)"/iso/boot/kernel26.img: mkinitcpio.conf "$(WORKDIR)"/root-image/.arch-chroot
	mkdir -p "$(WORKDIR)"/iso/boot
	mkinitcpio -c ./mkinitcpio.conf -b "$(WORKDIR)"/root-image -k `uname -r` -g $@

# See: Overlay
overlay:
	mkdir -p "$(WORKDIR)"/overlay/etc/pacman.d
	cp -r overlay "$(WORKDIR)"/
	#wget -O "$(WORKDIR)"/overlay/etc/pacman.d/mirrorlist http://www.archlinux.org/mirrorlist/all/
	cp mirrorlist "$(WORKDIR)"/overlay/etc/pacman.d/mirrorlist
	sed -i "s/#Server/Server/g" "$(WORKDIR)"/overlay/etc/pacman.d/mirrorlist

# Rule to process isomounts file.
iso-mounts: $(WORKDIR)/iso/$(INSTALL_DIR)/isomounts
$(WORKDIR)/iso/$(INSTALL_DIR)/isomounts: isomounts root-image
	sed "s|@ARCH@|$(ARCH)|g" isomounts > $@

# In case "make clean" is called, the following routine gets rid of all files created by this Makefile.
clean:
	rm -rf "$(WORKDIR)" "$(FULLNAME)".img "$(FULLNAME)".iso

.PHONY: all monkey
.PHONY: base-fs
.PHONY: root-image boot-files initcpio overlay iso-mounts
.PHONY: clean

