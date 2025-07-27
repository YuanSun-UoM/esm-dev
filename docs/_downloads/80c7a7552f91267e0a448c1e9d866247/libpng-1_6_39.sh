#!/usr/bin/env bash
# Install script for zlib 
# cd /home/yuansun/jobscript/software/
# bash 'libpng-1_6_39.sh' > './log/libpng-1_6_39.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=libpng
APPVER=1.6.39
COMPILER=gcc
APP=1_6_39
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/$COMPILER/${NAME}
LIBPNGDIR=$APPROOT/${APPVER}
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

# download the LIBPNG code
wget --no-check-certificate https://sourceforge.net/projects/libpng/files/libpng16/${APPVER}/libpng-${APPVER}.tar.gz
tar zxvf ${NAME}-${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
export LD_LIBRARY_PATH="$ZLIBDIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$ZLIBDIR/share/man:$MANPATH"
export CPATH="$ZLIBDIR/include:$CPATH"
export LIBRARY_PATH="$ZLIBDIR/lib:$LIBRARY_PATH"

# configure the build
CC=gcc-9 CXX=g++-9 FC=gfortran-9 ./configure --prefix=$LIBPNGDIR
make
make check
make install           