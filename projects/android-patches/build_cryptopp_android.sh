#!/bin/sh

#Note [TBD] : There is no check for ndk-version
#Please use the ndk-version as per host machine for now

#Get the machine type
PROCTYPE=`uname -m`

if [ "$PROCTYPE" = "i686" ] || [ "$PROCTYPE" = "i386" ] || [ "$PROCTYPE" = "i586" ] ; then
        echo "Host machine : x86"
        ARCHTYPE="x86"
else
        echo "Host machine : x86_64"
        ARCHTYPE="x86_64"
fi

#Get the Host OS
HOST_OS=`uname -s`
case "$HOST_OS" in
    Darwin)
        HOST_OS=darwin
        ;;
    Linux)
        HOST_OS=linux
        ;;
esac

#NDK-path
if [[ $1 == *ndk* ]]; then
	echo "----------------- NDK Path is : $1 ----------------"
	Input=$1;
else
	echo "Please enter your android ndk path:"
	echo "For example:/home/astro/android-ndk-r8e"
	read Input
	echo "You entered:$Input"

	echo "----------------- Exporting the android-ndk path ----------------"
fi

#Set path
if [ "$ARCHTYPE" = "x86" ] ; then
	export PATH=$PATH:$Input:$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$HOST_OS-x86/bin
else
        export PATH=$PATH:$Input:$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/$HOST_OS-x86_64/bin
fi

#create install directories
mkdir -p ./../android
mkdir -p ./../../../build
mkdir -p ./../../../build/android


#cryptopp module build
echo "------ Building cryptopp 5.6.2 for ANDROID platform ------"
pushd `pwd`
mkdir -p ./../../../build/android/cryptopp
mkdir -p ./../../../build/android/cryptopp/include

cd ./../android
rm -rf *
cp ../android-patches/* .
unzip cryptopp.zip
unzip -a GNUmakefile-android.patch.zip
unzip -a Config.h.patch.zip

#export ANDROID_STL_LIB=$Input/sources/cxx-stl/stlport/libs/armeabi/libstlport_shared.so
export ANDROID_STL_LIB=$Input/sources/cxx-stl/gnu-libstdc++/4.4.3/libs/armeabi/libgnustl_shared.so
export ANDROID_NDK_ROOT=$Input
if [ "$ARCHTYPE" = "x86" ] ; then
	export ANDROID_TOOLCHAIN=$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin
else 
    export ANDROID_TOOLCHAIN=$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86_64/bin	
fi
#export ANDROID_STL_INC=$Input/sources/cxx-stl/stlport/stlport/
export ANDROID_STL_INC=$Input/sources/cxx-stl/gnu-libstdc++/4.4.3/include
export ANDROID_STL_INC_2=$Input/sources/cxx-stl/gnu-libstdc++/4.4.3/libs/armeabi/include
#export ANDROID_STL_LIB=$Input/sources/cxx-stl/stlport/libs/armeabi/libstlport_static.a:$ANDROID_STL_LIB
export ANDROID_STL_LIB=$Input/sources/cxx-stl/gnu-libstdc++/4.4.3/libs/armeabi/libgnustl_static.a:$ANDROID_STL_LIB
export ANDROID_SYSROOT=$Input/platforms/android-9/arch-arm
export IS_ANDROID=1
export IS_CROSS_COMPILE=1

patch -p0 -i GNUmakefile-android.patch
patch -p0 -i config.h.patch

make static dynamic
popd

echo "-------- Installing cryptopp libs -----"
cp -r ./../../../cryptopp/projects/android/lib* ./../../../build/android/cryptopp/
cp -r ./../../../cryptopp/projects/android/*.h ./../../../build/android/cryptopp/include

#clean
rm -rf ./../android


