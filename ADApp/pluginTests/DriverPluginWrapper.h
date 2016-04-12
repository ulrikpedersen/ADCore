/*
 * TimeSeriesPluginWrapper.cpp
 *
 *  Created on: 21 Mar 2016
 *      Author: Ulrik Pedersen
 */

#ifndef ADAPP_PLUGINTESTS_DRIVERPLUGINWRAPPER_H_
#define ADAPP_PLUGINTESTS_DRIVERPLUGINWRAPPER_H_

#include <NDPluginDriver.h>
#include "AsynPortClientContainer.h"

class DriverPluginWrapper : public NDPluginDriver, public AsynPortClientContainer
{
public:
  DriverPluginWrapper(const std::string& port, const std::string& detectorPort);
  DriverPluginWrapper(const std::string& port,
                   int queueSize, int blocking,
                   const std::string& detectorPort, int address,
                   int maxAddr,
                   int maxBuffers, size_t maxMemory,
                   int priority, int stackSize);
  virtual ~DriverPluginWrapper ();
  void driverCallback(NDArray* pArray);
  void wait(int num_processing);
  void triggerProcessing();

protected:
  virtual void processCallbacks(NDArray* pArray);
  void processCallbacksDirect(NDArray* pArray);
  virtual void driverCallback(asynUser *pasynUser, void *genericPointer);

private:
  epicsEvent trigger_process_event;
  epicsEvent processing_complete_event;
};

#endif /* ADAPP_PLUGINTESTS_DRIVERPLUGINWRAPPER_H_ */
