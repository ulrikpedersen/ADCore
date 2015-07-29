#!/bin/bash
# Make sure we exit on any error 
set -e

ADCORE_DIR=`pwd`
mkdir -p $HOME/epics
cd $HOME/epics

#export EPICS_BASE=$HOME/epics/base-3.14.12.5
#export EPICS_HOST_ARCH=linux-x86_64

if [ ! -f baseR3.14.12.5.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/epics/download/base/baseR3.14.12.5.tar.gz
  tar -zxf baseR3.14.12.5.tar.gz
fi
if [ ! -d "$EPICS_BASE/lib/$EPICS_HOST_ARCH" ]; then
  make -C base-3.14.12.5
else
  echo 'Using cached directory epics base';
fi

if [ ! -f msi1-7.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/epics/download/extensions/msi1-7.tar.gz
  tar -zxf msi1-7.tar.gz -C $EPICS_BASE/src
fi
if [ ! -d "$EPICS_BASE/bin/$EPICS_HOST_ARCH/msi" ]; then
  make -C base-3.14.12.5/src/msi1-7
else
  echo 'Using cached directory msi';
fi

# Build asyn with libcom only if this is required
if [ ! -z "$EPICS_LIBCOM_ONLY" ]; then
  if [ ! -f asyn4-26.tar.gz ]; then
    wget -nv http://www.aps.anl.gov/epics/download/modules/asyn4-26.tar.gz
    tar -zxf asyn4-26.tar.gz
  fi
  if [ ! -d "asyn4-26/lib/$EPICS_HOST_ARCH" ]; then
    echo "EPICS_BASE=$EPICS_BASE" > asyn4-26/configure/RELEASE
    echo "EPICS_LIBCOM_ONLY=YES" >> asyn4-26/configure/CONFIG_SITE
    make -C asyn4-26/
  else
    echo 'Using cached directory asyn';
  fi
fi

cd $ADCORE_DIR
