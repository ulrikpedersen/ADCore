#ifndef NDFILEHDF5DATASET_H_
#define NDFILEHDF5DATASET_H_

#include <string>
#include <hdf5.h>
#include "NDPluginFile.h"

class NDFileHDF5Dataset
{
  public:
    NDFileHDF5Dataset(const std::string& name, hid_t dataset);

    asynStatus configureDims(NDArray *pArray, bool multiframe, int extradimensions, int *extra_dims, int *user_chunking);
    void extendDataSet(int extradims);
    asynStatus writeFile(NDArray *pArray, hid_t datatype, hid_t dataspace, hsize_t *framesize);
    hid_t getHandle();
    void closeHandle();
    hid_t reopenHandle(hid_t file);

  private:

    std::string name_;     // Name of this dataset
    hid_t       dataset_;  // Dataset handle
    haddr_t     addr_;     // Dataset address/offset in file. Used for closing/reopening dset.

    int nextRecord;

    int arrayDims[ND_ARRAY_MAX_DIMS];
    // dimension descriptors
    int rank;             // number of dimensions
    hsize_t *dims;        // Array of current dimension sizes. This updates as various dimensions grow.
    hsize_t *maxdims;     // Array of maximum dimension sizes. The value -1 is HDF5 term for infinite.
    hsize_t *chunkdims;   // Array of chunk size in each dimension. Only the dimensions that indicate the frame size (width, height) can really be tweaked. All other dimensions should be set to 1.
    hsize_t *offset;      // Array of current offset in each dimension. The frame dimensions always have 0 offset but additional dimensions may grow as new frames are added.
//    hsize_t *framesize;   // The frame size in each dimension. Frame width, height and possibly depth (RGB) have real values -all other dimensions set to 1.
    hsize_t *virtualdims; // The desired sizes of the extra (virtual) dimensions: {Y, X, n}
    char *ptrDimensionNames[ND_ARRAY_MAX_DIMS]; // Array of strings with human readable names for each dimension

    char *dimsreport;     // A string which contain a verbose report of all dimension sizes. The method getDimsReport fill in this
};


#endif

