#!/usr/bin/env bash
# Install script for zlib 
# cd /home/yuansun/jobscript/software/
# bash 'jasper-4_2_5.sh' > './log/jasper-4_2_5.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=jasper
APPVER=1.900.1
COMPILER=gcc
APP=1_900_1
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/$COMPILER/${NAME}
JASPERDIR=$APPROOT/${APPVER}

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

# download the JASPER code
wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-${APPVER}.zip
unzip jasper-${APPVER}.zip
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER
SOURCE_DIR=${APPROOT}/build/jasper-${APP}
BUILD=${APPROOT}/build/jasper-${APP}-build
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
NETCDFCDIR=${INROOT}/${COMPILER}/netcdf-c/4.9.2
NETCDFFDIR=${INROOT}/${COMPILER}/netcdf-fortran/4.6.1
export CPPFLAGS="-I$MPICHDIR/include -I$HDF5DIR/include -I$NETCDFCDIR/include -I$NETCDFFDIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$HDF5DIR/lib -L$NETCDFCDIR/lib -L$NETCDFFDIR/lib"
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$PATH"
export CC=mpicc
export FC=mpifort
export MPICXX=mpicxx
MY_INSTALL=${APPROOT}/${APPVER}

./configure --prefix=${MY_INSTALL}
make -j 4
make install            