#!/bin/bash

# location
export KERNELDIR=/KernelDEV/HTC;
export STIFOLDER=$KERNELDIR/STi-Kernel
export ARCH=arm;
export SUBARCH=arm;
export KERNEL_CONFIG=cyanogenmod_m7_defconfig;
export TOOLCHAIN=$KERNELDIR/arm-eabi-4.8/bin/arm-eabi-

# build script

chmod -R 777 /tmp;

echo -e "\e[1;31mWelcome to the STi Kernel Build Script!\e[m";


#Lets make the kernel menu

echo "Edit kernel before build?";
read ANS

if [ $ANS == "y" ]; then 
echo " ";
echo " ";
echo "Editing kernel....";
		make menuconfig;
else [ "$ANS" == "n" ];
echo " ";
echo " ";
echo "Starting build...";

# gcc 4.7.4 (Linaro 13.07)
export CROSS_COMPILE=$TOOLCHAIN;

# importing PATCH for GCC depend on GCC version
GCCVERSION=`./scripts/gcc-version.sh ${CROSS_COMPILE}gcc`;

# compiler detection
if [ "a$GCCVERSION" == "a0404" ]; then
	echo "GCC 4.3.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0404" ]; then
	echo "GCC 4.4.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0405" ]; then
	echo "GCC 4.5.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0406" ]; then
	echo "GCC 4.6.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0407" ]; then
	echo "GCC 4.7.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0408" ]; then
	echo "GCC 4.8.X Compiler Detected, building";
elif [ "a$GCCVERSION" == "a0409" ]; then
	echo "GCC 4.9.X Compiler Detected, building";
else
	echo -e "\e[1;31mCompiler not recognized! please fix the 'build_script.sh'-script to match your compiler.\e[m";
	exit 0;
fi;

# Core Detection

#Lets delete old .zip files
echo "What is the OLD version number?"
read VOLD
rm $STIFOLDER/STi_Kernel-v.$VOLD.zip;

#Declare the new build number
echo "What is the new version number?"
read VER

echo "Use how many extra or less build threads do you want? [Ex.-1, 1]";
read BTHREADS
	NAMBEROFCPUS=$(expr `grep processor /proc/cpuinfo | wc -l` + $BTHREADS);
	echo "Setting $NAMBEROFCPUS build threads....";


# copy config
if [ ! -f $KERNELDIR/.config ]; then
	cp $KERNELDIR/arch/arm/configs/$KERNEL_CONFIG $KERNELDIR/.config;
fi;

# read config
. $KERNELDIR/.config;

# remove previous zImage files
if [ -e $KERNELDIR/zImage ]; then
	rm $KERNELDIR/zImage;
fi;
if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	rm $KERNELDIR/arch/arm/boot/zImage;
fi;

# copy new config
cp $KERNELDIR/.config $KERNELDIR/arch/arm/configs/$KERNEL_CONFIG;

# remove all old modules before compile
for i in `find $KERNELDIR/ -name "*.ko"`; do
	rm -f $i;
done;


# make kernel!!!
make -j$NAMBEROFCPUS CROSS_COMPILE=$TOOLCHAIN

# copy modules
mkdir -p $KERNELDIR/STi-Kernel/system/lib/modules;
for i in `find $KERNELDIR -name '*.ko'`; do
	cp -av $i $KERNELDIR/STi-Kernel/system/lib/modules;
done;
for i in `find $KERNELDIR/STi-Kernel/system/lib/modules -name '*.ko'`; do
	${CROSS_COMPILE}strip --strip-unneeded $i;
done;
chmod 755 $KERNELDIR/STi-Kernel/system/lib/modules*;



# restore clean arch/arm/boot/compressed/Makefile_clean till next time
cp $KERNELDIR/arch/arm/boot/compressed/Makefile_clean $KERNELDIR/arch/arm/boot/compressed/Makefile;

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	cp $KERNELDIR/.config $KERNELDIR/arch/arm/configs/$KERNEL_CONFIG;

#Zip up the kernel
	cp $KERNELDIR/arch/arm/boot/zImage $STIFOLDER/kernel;
	cd $STIFOLDER && zip -r STi_Kernel-v.$VER.zip .;

else
	#Stop build with red-color
	echo -e "\e[1;31mBuild Error! Please check code.\e[m"
fi;
fi;
