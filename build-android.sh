#!/bin/sh

set -e

if [ -z "$TOOLCHAIN" ]; then echo "TOOLCHAIN must be set."; exit -1; fi
if [ -z "$SYSROOT" ]; then echo "SYSROOT must be set."; exit -1; fi
if [ -z "$PROGRAMS"]; then PROGRAMS="dropbear"; fi

HOST=arm-linux-androideabi
COMPILER=${TOOLCHAIN}/bin/arm-linux-androideabi-gcc
STRIP=${TOOLCHAIN}/bin/arm-linux-androideabi-strip
export CC="$COMPILER --sysroot=$SYSROOT"
if [ -z $DISABLE_PIE ]; then export CFLAGS="-g -O2 -pie -fPIE"; else echo "Disabling PIE compilation..."; fi
unset GOOGLE_PLATFORM

./configure --host="$HOST" --disable-utmp --disable-wtmp --disable-utmpx --disable-zlib --disable-syslog --disable-lastlog
make -j$(nproc) PROGRAMS="$PROGRAMS"
for PROGRAM in $PROGRAMS; do
    if [ ! -f $PROGRAM ]; then
        echo "${PROGRAM} not found!"
    fi
    $STRIP "./${PROGRAM}"
done
