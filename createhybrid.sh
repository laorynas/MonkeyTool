#!/bin/sh

COMPRESS=gzip
FULLNAME=${PWD}/MonkeyTool-hybrid

if [ ! -f ./$1 ];then
	echo "ERROR: i686 image not found."
	exit
fi

if [ ! -f ./$2 ];then
	echo "ERROR: x86_64 image not found."
	exit
fi

sudo rm -r hybridwork
sudo rm ${FULLNAME}.iso

mkdir -p hybridwork/iso
mkdir -p hybridwork/i686
mkdir -p hybridwork/x86_64

sudo mount $1 -o loop hybridwork/i686
sudo mount $2 -o loop hybridwork/x86_64

cp -r boot-files hybridwork/iso/boot
mkdir -p hybridwork/iso/boot/i686/
cp hybridwork/i686/boot/kernel26.img hybridwork/iso/boot/i686/
cp hybridwork/i686/boot/System.map26 hybridwork/iso/boot/i686/
cp hybridwork/i686/boot/vmlinuz26 hybridwork/iso/boot/i686/
mkdir -p hybridwork/iso/boot/x86_64/
cp hybridwork/x86_64/boot/kernel26.img hybridwork/iso/boot/x86_64/
cp hybridwork/x86_64/boot/System.map26 hybridwork/iso/boot/x86_64/
cp hybridwork/x86_64/boot/vmlinuz26 hybridwork/iso/boot/x86_64/

cp -r hybridwork/i686/syslinux hybridwork/iso/
sudo cp hybrid/syslinux.cfg hybridwork/iso/syslinux/

mkdir -p hybridwork/iso/monkey
cp -r hybridwork/i686/monkey/i686 hybridwork/iso/monkey
cp -r hybridwork/x86_64/monkey/x86_64 hybridwork/iso/monkey
cp hybrid/isomounts hybridwork/iso/monkey

echo 'MonkeyTool hybrid' > hybridwork/iso/version.txt
date -u >> hybridwork/iso/version.txt

sudo umount hybridwork/i686
sudo umount hybridwork/x86_64

sudo mkarchiso -L MonkeyTool -D monkey -c ${COMPRESS} -p syslinux iso hybridwork ${FULLNAME}.iso
