#!/bin/sh
if [[ $1 == *android-ndk-* ]]; then
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
export PATH=$PATH:$Input:$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin

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
export ANDROID_TOOLCHAIN=$Input/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin
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


