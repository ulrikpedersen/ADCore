< envPaths.linux

errlogInit(20000)

dbLoadDatabase("$(TOP)/dbd/simDetectorApp.dbd")
simDetectorApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "13SIM1:")
# The port name for the detector
epicsEnvSet("PORT",   "SIM1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1024")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1024")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")

# The EPICS environment variable EPICS_CA_MAX_ARRAY_BYTES needs to be set to a value at least as large
# as the largest image that the standard arrays plugin will send.
# That vlaue is $(XSIZE) * $(YSIZE) * sizeof(FTVL data type) for the FTVL used when loading the NDStdArrays.template file.
# The variable can be set in the environment before running the IOC or it can be set here.
# It is often convenient to set it in the environment outside the IOC to the largest array any client 
# or server will need.  For example 10000000 (ten million) bytes may be enough.
# If it is set here then remember to also set it outside the IOC for any CA clients that need to access the waveform record.  
# Do not set EPICS_CA_MAX_ARRAY_BYTES to a value much larger than that required, because EPICS Channel Access actually
# allocates arrays of this size every time it needs a buffer larger than 16K.
# Uncomment the following line to set it in the IOC.
#epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "10000000")

# Create a simDetector driver
# simDetectorConfig(const char *portName, int maxSizeX, int maxSizeY, int dataType,
#                   int maxBuffers, int maxMemory, int priority, int stackSize)
simDetectorConfig("$(PORT)", $(XSIZE), $(YSIZE), 1, 0, 0)

NDFileHDF5Configure("FileHDF1", $(QSIZE), 0, "$(PORT)", 0)

dbLoadRecords("../../db/simDetectorIOC.db")


#asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,255)

iocInit()

