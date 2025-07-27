#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'hdf5-1_12_3.sh' > './log/hdf5-1_12_3.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=hdf5
APPVER=1.12.3
COMPILER=gcc
APP=1_12_3
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
HDF5DIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
export PATH="$MPICHDIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$LIBRARY_PATH"

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

# download the HDF5 code
wget -c -4 https://github.com/HDFGroup/${NAME}/archive/refs/tags/${NAME}-${APP}.tar.gz
tar zxvf ${NAME}-${APP}.tar.gz
mv ${NAME}-${NAME}-${APP} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

## environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib"
export CC=mpicc
export FC=mpifort

# configure the build
./configure --prefix=$HDF5DIR --with-zlib=$ZLIBDIR --enable-hl --enable-fortran --enable-parallel --enable-shared

make 
make install
make check