#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'pio-2_6_6.sh' > './log/pio-2_6_6.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=pio
APPVER=2.6.6
COMPILER=gcc
APP=2_6_6
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
PIODIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
PNETCDFDIR=${INROOT}/${COMPILER}/pnetcdf/1.12.3
NETCDFCDIR=${INROOT}/${COMPILER}/netcdf-c/4.9.2
NETCDFFDIR=${INROOT}/${COMPILER}/netcdf-fortran/4.6.1
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$PNETCDFDIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$PNETCDFDIR/share/man:$NETCDFCDIR/share/man:$NETCDFFDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$HDF5DIR/include:$PNETCDFDIR/include:$NETCDFCDIR/include:$NETCDFFDIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$LIBRARY_PATH"

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

# download the PIO2 code
wget -c -4  https://github.com/NCAR/ParallelIO/archive/refs/tags/${NAME}${APP}.tar.gz
tar zxvf ${NAME}${APP}.tar.gz
mv ParallelIO-${NAME}${APP} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

## environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include -I$HDF5DIR/include -I$PNETCDFDIR/include -I$NETCDFCDIR/include -I$NETCDFFDIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib -L$HDF5DIR/lib -L$PNETCDFDIR/lib -L$NETCDFCDIR/lib -L$NETCDFFDIR/lib"
export CC=mpicc
export FC=mpifort
export MPICXX=mpicxx

# configure the build
mkdir m4
aclocal -I m4
libtoolize --force
autoheader
automake --add-missing --copy
autoconf
./configure --prefix=$PIODIR --enable-fortran
make
make install