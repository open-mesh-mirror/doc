#!/bin/sh

CODENAME="kamikaze"
VERSIONS="8.09.2"

PACKAGES="kmod-batman-advanced"
TARGETS="ppc40x ppc44x atheros ar71xx avr32 brcm47xx ifxmips adm5120 ixp4xx magicbox rb532 rdc au1000 ar7 uml x86"

CONFIG=".config"
ERRORLOG="error.log"
THREADS="1"

for version in $VERSIONS; do
	# Checkout svn tag $version
	svn co svn://svn.openwrt.org/openwrt/tags/$version openwrt-$version
	cd openwrt-$version

	# Update feeds to latest versions
	cp feeds.conf.default feeds.conf
	sid -i "s/svn-src packages .*/svn-src svn://svn.openwrt.org/openwrt/packages" feeds.conf
	scripts/feeds update

	# Add $PACKAGES from feeds if necessary
	for package in $PACKAGES; do
		[ -d package/$package ] && continue
		scripts/feeds install $package || {
			echo Feed $package not found! >> $ERRORLOG
		}
	done

	for target in $TARGETS; do
		## Creating .config ##
		# Create default config for $target
		echo CONFIG_TARGET_$target=y > $CONFIG
		make defconfig
	
		# Remove all target images
		#sed -i "s/CONFIG_TARGET_ROOTFS_\(.*\)=y$/# CONFIG_TARGET_ROOTFS_\1 is not set/" $CONFIG
		# and packages
		sed -i "s/CONFIG_PACKAGE_\(.*\)=y$/# CONFIG_PACKAGE_\1 is not set/" $CONFIG


		# Now explicitly select all $PACKAGES
		for package in $PACKAGES; do
			sed -i "s/^# CONFIG_PACKAGE_$package is not set$/CONFIG_PACKAGE_$package=y/" $CONFIG
		done

		# And add default options for those packages
		make defconfig


		## Making packages ##
		# output directories
		mkdir -p ../$CODENAME/$version/$target/packages

		# build process
		make -j $THREADS || {
			echo Error compiling $target! >> ../$ERRORLOG
			continue
		}

		# saving packages
		mv bin/packages/*/* ../$CODENAME/$version/$target/packages/
	done

	cd ..
done
