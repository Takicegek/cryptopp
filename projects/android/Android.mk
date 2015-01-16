LOCAL_PATH := $(call my-dir)/../../

include $(CLEAR_VARS)

LOCAL_ARM_MODE := arm
LOCAL_CLANG := true

LOCAL_CFLAGS	:= -Wall \
-W \
-O2 \
-pipe \
-fPIC \
-D_ANDROID \

LOCAL_CPPFLAGS += -std=c++11 -pthread -frtti -fexceptions

LOCAL_MODULE    := cryptopp_android

LOCAL_C_INCLUDES:= \
$(ANDROIDNDK_PATH)/sources/android/support/include \
$(ANDROIDNDK_PATH)/sources/cxx-stl/llvm-libc++/libcxx/include \
$(ANDROIDNDK_PATH)/platforms/android-19/arch-arm/usr/include \
$(LOCAL_PATH) \


LOCAL_SRC_FILES := 3way.cpp \
adler32.cpp \
algebra.cpp \
algparam.cpp \
arc4.cpp \
asn.cpp \
authenc.cpp \
base32.cpp \
base64.cpp \
basecode.cpp \
bfinit.cpp \
blowfish.cpp \
blumshub.cpp \
camellia.cpp \
cast.cpp \
casts.cpp \
cbcmac.cpp \
ccm.cpp \
channels.cpp \
cmac.cpp \
cpu.cpp \
crc.cpp \
cryptlib.cpp \
cryptlib_bds.cpp \
default.cpp \
des.cpp \
dessp.cpp \
dh.cpp \
dh2.cpp \
dll.cpp \
dlltest.cpp \
dsa.cpp \
eax.cpp \
ec2n.cpp \
eccrypto.cpp \
ecp.cpp \
elgamal.cpp \
emsa2.cpp \
eprecomp.cpp \
esign.cpp \
files.cpp \
filters.cpp \
fips140.cpp \
fipsalgt.cpp \
fipstest.cpp \
gcm.cpp \
gf256.cpp \
gf2_32.cpp \
gf2n.cpp \
gfpcrypt.cpp \
gost.cpp \
gzip.cpp \
hex.cpp \
hmac.cpp \
hrtimer.cpp \
ida.cpp \
idea.cpp \
integer.cpp \
iterhash.cpp \
luc.cpp \
mars.cpp \
marss.cpp \
md2.cpp \
md4.cpp \
md5.cpp \
misc.cpp \
modes.cpp \
mqueue.cpp \
mqv.cpp \
nbtheory.cpp \
network.cpp \
oaep.cpp \
osrng.cpp \
panama.cpp \
pch.cpp \
pkcspad.cpp \
polynomi.cpp \
pssr.cpp \
pubkey.cpp \
queue.cpp \
rabin.cpp \
randpool.cpp \
rc2.cpp \
rc5.cpp \
rc6.cpp \
rdtables.cpp \
regtest.cpp \
rijndael.cpp \
ripemd.cpp \
rng.cpp \
rsa.cpp \
rw.cpp \
safer.cpp \
salsa.cpp \
seal.cpp \
seed.cpp \
serpent.cpp \
sha.cpp \
sha3.cpp \
shacal2.cpp \
shark.cpp \
sharkbox.cpp \
simple.cpp \
skipjack.cpp \
socketft.cpp \
sosemanuk.cpp \
square.cpp \
squaretb.cpp \
strciphr.cpp \
tea.cpp \
tftables.cpp \
tiger.cpp \
tigertab.cpp \
trdlocal.cpp \
ttmac.cpp \
twofish.cpp \
vmac.cpp \
wait.cpp \
wake.cpp \
whrlpool.cpp \
winpipes.cpp \
xtr.cpp \
xtrcrypt.cpp \
zdeflate.cpp \
zinflate.cpp \
zlib.cpp \


include $(BUILD_STATIC_LIBRARY)

