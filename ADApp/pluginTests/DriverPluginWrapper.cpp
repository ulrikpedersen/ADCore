/*
 * TimeSeriesPluginWrapper.cpp
 *
 *  Created on: 21 Mar 2016
 *      Author: Ulrik Pedersen
 */

#include "DriverPluginWrapper.h"

DriverPluginWrapper::DriverPluginWrapper(const std::string& port, const std::string& detectorPort)
  :  NDPluginDriver(port.c_str(), 16, 0,
                    detectorPort.c_str(), 1, 1, 55,
                    0, 0,
                    asynFloat64Mask | asynGenericPointerMask,
                    asynFloat64Mask | asynGenericPointerMask,
                    ASYN_MULTIDEVICE, 1,
                    0, 0),
     AsynPortClientContainer(port)
{
}

DriverPluginWrapper::DriverPluginWrapper(const std::string& port,
                                         int queueSize, int blocking,
                                         const std::string& detectorPort, int address,
                                         int maxAddr,
                                         int maxBuffers, size_t maxMemory,
                                         int priority, int stackSize)
  :  NDPluginDriver(port.c_str(), queueSize, blocking,
                        detectorPort.c_str(), address, 1, 55,
                        maxBuffers, maxMemory,
                        asynFloat64Mask | asynGenericPointerMask,
                        asynFloat64Mask | asynGenericPointerMask,
                        ASYN_MULTIDEVICE, 1,
                        priority, stackSize),
     AsynPortClientContainer(port)
{
}

DriverPluginWrapper::~DriverPluginWrapper ()
{
  cleanup();
}

void DriverPluginWrapper::processCallbacks(NDArray* pArray)
{
  NDPluginDriver::processCallbacks(pArray);
  // We just block to wait for an event. Emulates slow processing.
  this->unlock();
  this->trigger_process_event.wait(1.0);
  this->lock();
}

void DriverPluginWrapper::processCallbacksDirect(NDArray* pArray)
{
  NDPluginDriver::processCallbacks(pArray);
}

void DriverPluginWrapper::wait(int num_processing)
{
  for (int i = 0; i < num_processing; i++)
  {
    this->processing_complete_event.wait();
  }
}

void DriverPluginWrapper::triggerProcessing()
{
  this->trigger_process_event.signal();
}

void DriverPluginWrapper::driverCallback(asynUser *pasynUser, void *genericPointer)
{
  NDPluginDriver::driverCallback(pasynUser, genericPointer);
}

void DriverPluginWrapper::driverCallback(NDArray* pArray)
{
  this->driverCallback(this->pasynUserSelf, static_cast<void*>(pArray));
}
