#!/bin/sh

# Downloads and builds AUR packages
# This should not be ran as root

rm -r packages
mkdir -p packages/build
cd packages/build

for line in `sed '/^*/!d' ../../packages.list`; do
  line=$(echo $line | sed 's/*//')
  echo "Downloading ${line}..."
  wget http://aur.archlinux.org/packages/${line}/${line}.tar.gz -O ${line}.tar.gz
  echo "Extracting ${line}..."
  tar xvf ${line}.tar.gz
  cd $line
  echo "Building ${line}..."
  makepkg ${line}/PKGBUILD -f
  mv ${line}-*.pkg.* ../../
  cd ..
done
