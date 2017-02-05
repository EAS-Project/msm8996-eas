#!/bin/bash

#
#  Build Script for Render Kernel for OnePlus 3!
#  Based off AK'sbuild script - Thanks!
#

# Bash Color
rm .version
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="lineageos_oneplus3_defconfig"

# Kernel Details
VER=Render-Kernel
VARIANT="OP3-LOS-N"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=RenderBroken
export KBUILD_BUILD_HOST=RenderServer.net
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/android/source/kernel/OP3-AnyKernel"
PATCH_DIR="${HOME}/android/source/kernel/OP3-AnyKernel/patch"
MODULES_DIR="${HOME}/android/source/kernel/OP3-AnyKernel/modules"
ZIP_MOVE="${HOME}/android/source/zips/OP3-zips"
ZIMAGE_DIR="${HOME}/android/source/kernel/OP3-LOS-kernel/arch/arm64/boot"

# Functions
function checkout_ak_branches {
		cd $REPACK_DIR
		git checkout rk-oos-anykernel
		cd $KERNEL_DIR
}

function clean_all {
		cd $REPACK_DIR
		rm -rf $MODULES_DIR/*
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		rm -rf zImage
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm64/boot/
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 RenderKernel-"$VARIANT"-R.zip *
		mv RenderKernel-"$VARIANT"-R.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Render Kernel Creation Script:"
echo -e "${restore}"

echo "Pick Toolchain..."
select choice in LINARO-aarch64-linux-gnu-4.9.3-05012016 LINARO-aarch64-linux-gnu-5.3.1-05012016 HYPER-aarch64-6.x-10032016 LINARO-aarch64-linux-gnu-6.2.1-12082016
do
case "$choice" in
	"LINARO-aarch64-linux-gnu-4.9.3-05012016")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/LINARO-aarch64-linux-gnu-4.9.3-05012016/bin/aarch64-linux-gnu-
		break;;
	"LINARO-aarch64-linux-gnu-5.3.1-05012016")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/LINARO-aarch64-linux-gnu-5.3.1-05012016/bin/aarch64-linux-gnu-
		break;;
	"HYPER-aarch64-6.x-10032016")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/HYPER-aarch64-6.x-10032016/bin/aarch64-linux-android-
		break;;
	"LINARO-aarch64-linux-gnu-6.2.1-12082016")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/LINARO-aarch64-linux-gnu-6.2.1-12082016/bin/aarch64-linux-gnu-
		break;;
esac
done

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		checkout_ak_branches
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		checkout_ak_branches
		make_kernel
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
