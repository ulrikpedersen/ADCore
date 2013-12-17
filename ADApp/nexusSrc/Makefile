TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================


INC += napi.h
INC += napiconfig.h
INC += nxconfig.h

USR_CFLAGS += -DHDF5 -D_FILE_OFFSET_BITS=64
ifeq ($(STATIC_BUILD), NO)
  USR_CFLAGS_WIN32 += -DH5_BUILT_AS_DYNAMIC_LIB
endif

LIB_LIBS_WIN32     += hdf5dll szip zlib1

# Check if the hdf5 library has been installed somewhere else
ifdef HDF5
  LIB_LIBS_Linux      += hdf5
  LIB_LIBS_Darwin     += hdf5
  hdf5_DIR=$(HDF5)/lib
else
  # Alternativly use the installed system library
  LIB_SYS_LIBS_Linux  += hdf5
  LIB_SYS_LIBS_Darwin += hdf5
endif

ifdef SZIP
  LIB_LIBS_Linux      += sz
  LIB_LIBS_Darwin     += sz
  sz_DIR=$(SZIP)/lib
else
  LIB_SYS_LIBS_Linux  += sz
  LIB_SYS_LIBS_Darwin += sz
endif


LIBRARY_IOC_WIN32    += NeXus
LIBRARY_IOC_cygwin32 += NeXus
LIBRARY_IOC_Linux    += NeXus
LIBRARY_IOC_Darwin   += NeXus

LIB_SRCS += napi.c
LIB_SRCS += napi5.c
LIB_SRCS += napiu.c
LIB_SRCS += nxdataset.c
LIB_SRCS += nxio.c
LIB_SRCS += nxstack.c
LIB_SRCS += nxxml.c
LIB_SRCS += stptok.c

#=============================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

