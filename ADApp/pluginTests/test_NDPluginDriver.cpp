/*
 * test_NDPluginTimeSeries.cpp
 *
 *  Created on: 21 Mar 2016
 *      Author: Ulrik Pedersen
 */

#include <stdio.h>


#include "boost/test/unit_test.hpp"

// AD dependencies
#include <NDPluginDriver.h>
#include <NDArray.h>
#include <NDAttribute.h>
#include <asynDriver.h>

#include <string.h>
#include <stdint.h>

#include <deque>
#include <boost/shared_ptr.hpp>
#include <iostream>
#include <fstream>
using namespace std;

#include "testingutilities.h"
#include "DriverPluginWrapper.h"
#include "AsynException.h"


static int callbackCount = 0;
static void *cbPtr = 0;

void Driver_callback(void *userPvt, asynUser *pasynUser, void *pointer)
{
  cbPtr = pointer;
  callbackCount++;
}

struct DriverPluginTestFixture
{
  NDArrayPool *arrayPool;
  boost::shared_ptr<asynPortDriver> upstream_driver;
  boost::shared_ptr<DriverPluginWrapper> driver;
  boost::shared_ptr<asynGenericPointerClient> client;
  TestingPlugin* downstream_plugin; // TODO: we don't put this in a shared_ptr and purposefully leak memory because asyn ports cannot be deleted
  std::vector<NDArray*>arrays_1d;
  std::vector<size_t>dims_1d;
  std::vector<NDArray*>arrays_2d;
  std::vector<size_t>dims_2d;
  std::vector<NDArray*>arrays_3d;
  std::vector<size_t>dims_3d;

  static int testCase;

  DriverPluginTestFixture()
  {
    arrayPool = new NDArrayPool(100, 0);

    // Asyn manager doesn't like it if we try to reuse the same port name for multiple drivers
    // (even if only one is ever instantiated at once), so we change it slightly for each test case.
    std::string simport("simDrv"), testport("DRV");
    uniqueAsynPortName(simport);
    uniqueAsynPortName(testport);

    // We need some upstream driver for our test plugin so that calls to connectArrayPort
    // don't fail, but we can then ignore it and send arrays by calling processCallbacks directly.
    upstream_driver = boost::shared_ptr<asynPortDriver>(new asynPortDriver(simport.c_str(),
                                                                     1, 1,
                                                                     asynGenericPointerMask,
                                                                     asynGenericPointerMask,
                                                                     0, 0, 0, 2000000));

    // This is the plugin under test
    driver = boost::shared_ptr<DriverPluginWrapper>(new DriverPluginWrapper(testport.c_str(),
                                                                      50, 0,
                                                                      simport.c_str(), 0,
                                                                      1,
                                                                      0, 0,
                                                                      0, 2000000));
    // This is the mock downstream plugin
    downstream_plugin = new TestingPlugin(testport.c_str(), 0);

    // Enable the plugin
    driver->start(); // start the plugin thread although not required for this unittesting
    driver->write(NDPluginDriverEnableCallbacksString, 1);
    driver->write(NDPluginDriverBlockingCallbacksString, 0);

    client = boost::shared_ptr<asynGenericPointerClient>(new asynGenericPointerClient(testport.c_str(), 0, NDArrayDataString));
    client->registerInterruptUser(&Driver_callback);

    // 1D: 8 channels with a single scalar sample element in each one
    size_t tmpdims_1d[] = {8};
    dims_1d.assign(tmpdims_1d, tmpdims_1d + sizeof(tmpdims_1d)/sizeof(tmpdims_1d[0]));
    arrays_1d.resize(200); // We create 200 samples
    fillNDArrays(dims_1d, NDFloat32, arrays_1d); // Fill some NDArrays with unimportant data

    // 2D: three time series channels, each with 20 elements
    size_t tmpdims_2d[] = {3,20};
    dims_2d.assign(tmpdims_2d, tmpdims_2d + sizeof(tmpdims_2d)/sizeof(tmpdims_2d[0]));
    arrays_2d.resize(24);
    fillNDArrays(dims_2d, NDFloat32, arrays_2d);

    // 3D: four channels with 2D images of 5x6 pixel (like an RGB image)
    // Not valid input for the Time Series plugin
    size_t tmpdims_3d[] = {4,5,6};
    dims_3d.assign(tmpdims_3d, tmpdims_3d + sizeof(tmpdims_3d)/sizeof(tmpdims_3d[0]));
    arrays_3d.resize(24);
    fillNDArrays(dims_3d, NDFloat32, arrays_3d);
}

  ~DriverPluginTestFixture()
  {
    delete arrayPool;
    client.reset();
    driver.reset();
    upstream_driver.reset();
    //delete downstream_plugin; // TODO: We can't delete a TestingPlugin because it tries to delete an asyn port which doesnt work
  }

};

BOOST_FIXTURE_TEST_SUITE(DriverPluginTests, DriverPluginTestFixture)

BOOST_AUTO_TEST_CASE(leak_when_changing_queue_size)
{
  BOOST_MESSAGE("Checking for leaks when changing the plugin input queue size");

  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverQueueSizeString),        50);
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverQueueFreeString),        50);
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverEnableCallbacksString),   1);
  BOOST_MESSAGE("here we are 0!\n");
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverBlockingCallbacksString), 0);

  BOOST_MESSAGE("here we are 1!\n");

  // Process a few arrays through the driver plugin.
  int num_arrays = 0;
  for (num_arrays = 0; num_arrays < 3; num_arrays++)
  {
    BOOST_CHECK_NO_THROW(driver->lock());
    BOOST_CHECK_NO_THROW(driver->driverCallback(arrays_2d[num_arrays]));
    BOOST_CHECK_NO_THROW(driver->unlock());
  }
  BOOST_MESSAGE("here we are2!\n");

  // Check that all the input arrays are still in the input queue...
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverQueueFreeString), 50-num_arrays+1);

  // Change the input queue size which should drop and release all of the
  // NDArrays currently in the queue - but only when triggered by the process task.
  driver->write(NDPluginDriverQueueSizeString, 60);
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverQueueSizeString), 60);
  BOOST_CHECK_EQUAL(driver->readInt( NDPluginDriverQueueFreeString), 50-num_arrays+1);

  // TODO: FIXME: this just doesn't work yet. Blocks forever.
  for (int i = 0; i<3; i++) driver->triggerProcessing();
}


BOOST_AUTO_TEST_SUITE_END() // Done!
