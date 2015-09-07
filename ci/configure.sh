#!/bin/bash
# Configure ADCore in preparation for build
# Make sure we exit on any error 
set -e

# Generate the configure/RELEASE.local and configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
# with the details of where to find various external libraries.
echo "EPICS_BASE=$EPICS_BASE"                >> configure/RELEASE.local
echo "HDF5=/usr"                             >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "HDF5_LIB=/usr/lib"                     >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "HDF5_INCLUDE=-I/usr/include"           >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "XML2_INCLUDE=-I/usr/include/libxml2"   >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
if [ -z "$BOOST" ]; then
  echo "Not building boost unittests"
else
  echo "BOOST=$BOOST"                        >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
  echo "BOOST_LIB=$BOOST/lib"                >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
  echo "BOOST_INCLUDE=$BOOST/include"        >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
fi
echo "HOST_OPT=NO"                           >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
echo "USR_CXXFLAGS_Linux=--coverage"         >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
echo "USR_LDFLAGS_Linux=--coverage"          >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 

if [ -z "$EPICS_LIBCOM_ONLY" ]; then
  echo "ASYN=$HOME/synapps/asyn4-26"                >> configure/RELEASE.local
else
  echo "ASYN=$HOME/epics/asyn4-26"           >> configure/RELEASE.local
  echo "EPICS_LIBCOM_ONLY=YES"               >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
fi

echo "====== configure/RELEASE.local ============="
cat configure/RELEASE.local

echo "====== configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common ============="
cat configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common

