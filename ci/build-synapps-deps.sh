#!/bin/bash
# Make sure we exit on any error 
set -e

ADCORE_DIR=`pwd`
mkdir -p $HOME/synapps
cd $HOME/synapps

#export EPICS_BASE=$HOME/epics/base-3.14.12.5
#export EPICS_HOST_ARCH=linux-x86_64

export PATH=$PATH:$EPICS_BASE/bin/$EPICS_HOST_ARCH

if [ ! -f asyn4-26.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/epics/download/modules/asyn4-26.tar.gz
  tar -zxf asyn4-26.tar.gz
fi
if [ ! -d "$HOME/synapps/asyn4-26/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > asyn4-26/configure/RELEASE
  make -C asyn4-26/
else
  echo 'Using cached directory asyn';
fi

cd $ADCORE_DIR

