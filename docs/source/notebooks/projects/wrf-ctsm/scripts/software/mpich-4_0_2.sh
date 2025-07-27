#!/usr/bin/env bash
# Install script for mpich-4.0.2
# cd /home/yuansun/jobscript/software/
# bash 'mpich-4_0_2.sh' > './log/mpich-4_0_2.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=mpich
APPVER=4.0.2
COMPILER=gcc
APP=4_0_2
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/${COMPILER}/${NAME}
MPICHDIR=$APPROOT/${APPVER}

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

# download the MPICH code
wget -c -4 https://github.com/pmodels/${NAME}/releases/download/v${APPVER}/${NAME}-${APPVER}.tar.gz
tar zxvf ${NAME}-${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER

# environmental settings
unset F90
unset F90FLAGS

# configure the build
CC=gcc-9 CXX=g++-9 FC=gfortran-9 ./configure --prefix=$MPICHDIR --with-device=ch3
make
make install
make check

