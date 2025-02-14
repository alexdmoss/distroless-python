#!/usr/bin/sh

mkdir /tmp/python-libs/

if [ -d /lib/aarch64-linux-gnu ]; then
    ARCH=aarch64-linux-gnu
else
    ARCH=x86_64-linux-gnu
fi

cp /lib/$ARCH/libz.so.1 /tmp/python-libs/
cp /lib/$ARCH/libexpat* /tmp/python-libs/
cp /usr/lib/$ARCH/libffi* /tmp/python-libs/
