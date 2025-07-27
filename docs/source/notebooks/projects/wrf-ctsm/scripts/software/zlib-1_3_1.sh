#!/usr/bin/env bash
# Install script for zlib 
# cd /home/yuansun/jobscript/software/
# bash 'zlib-1_3_1.sh' > './log/zlib-1_3_1.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=zlib
APPVER=1.3.1
COMPILER=gcc
APP=1_3_1
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/${COMPILER}/${NAME}
ZLIBDIR=$APPROOT/${APPVER}

# making the install directory (and change accessibility if needed)
if [ -d "${APPROOT}" ]; then
   rm -rf "${APPROOT}"
   mkdir -p $APPROOT

else
   echo "create '${APPROOT}'"
   mkdir $APPROOT
fi

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER build archive
cd archive

# download the ZLIB code
wget -c -4 https://www.ece.uvic.ca/~frodo/${NAME}/software/${NAME}-${APPVER}.zip
unzip ${NAME}-${APPVER}.zip
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER

# configure the build
CC=gcc-9 CXX=g++-9 ./configure --prefix=$ZLIBDIR
make
make install
make check