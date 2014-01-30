#include "NDFileHDF5Dataset.h"
#include <iostream>

// Utility function to print some details from an dataset access property list
void print_apl(hid_t dset_id);

NDFileHDF5Dataset::NDFileHDF5Dataset(const std::string& name, hid_t dataset)
: name_(name), dataset_(dataset), addr_(0), nextRecord(0)
{
  this->maxdims     = NULL;
  this->chunkdims   = NULL;
  this->dims        = NULL;
  this->offset      = NULL;
  this->virtualdims = NULL;
}

asynStatus NDFileHDF5Dataset::configureDims(NDArray *pArray, bool multiframe, int extradimensions, int *extra_dims, int *user_chunking)
{
  int i=0,j=0, extradims = 0, ndims=0;
  asynStatus status = asynSuccess;

  extradims = extradimensions;

  ndims = pArray->ndims + extradims;

  // first check whether the dimension arrays have been allocated
  // or the number of dimensions have changed.
  // If necessary free and reallocate new memory.
  if (this->maxdims == NULL || this->rank != ndims){
    if (this->maxdims     != NULL) free(this->maxdims);
    if (this->chunkdims   != NULL) free(this->chunkdims);
    if (this->dims        != NULL) free(this->dims);
    if (this->offset      != NULL) free(this->offset);
    if (this->virtualdims != NULL) free(this->virtualdims);

    this->maxdims       = (hsize_t*)calloc(ndims,     sizeof(hsize_t));
    this->chunkdims     = (hsize_t*)calloc(ndims,     sizeof(hsize_t));
    this->dims          = (hsize_t*)calloc(ndims,     sizeof(hsize_t));
    this->offset        = (hsize_t*)calloc(ndims,     sizeof(hsize_t));
    this->virtualdims   = (hsize_t*)calloc(extradims, sizeof(hsize_t));
  }

  if (multiframe){
    /* Configure the virtual dimensions -i.e. dimensions in addition
     * to the frame format.
     * Normally set to just 1 by default or -1 unlimited (in HDF5 terms)
     */

    for (i=0; i<extradims; i++){
      this->chunkdims[i]   = 1;
      this->maxdims[i]     = H5S_UNLIMITED;
      this->dims[i]        = 1;
      this->offset[i]      = 0; // because we increment offset *before* each write we need to start at -1

      this->virtualdims[i] = extra_dims[i];
    }
  }

  this->rank = ndims;

  for (j=pArray->ndims-1,i=extradims; i<this->rank; i++,j--){
    this->chunkdims[i]  = pArray->dims[j].size;
    this->maxdims[i]    = pArray->dims[j].size;
    this->dims[i]       = pArray->dims[j].size;
    this->offset[i]     = 0;
  }

  // Collect the user defined chunking dimensions and check if they're valid
  //
  // A check is made to see if the user has input 0 or negative value (which is invalid)
  // in which case the size of the chunking is set to the maximum size of that dimension (full frame)
  // If the maximum of a particular dimension is set to a negative value -which is the case for
  // infinite lenght dimensions (-1); the chunking value is set to 1.
  int max_items = 0;
  int hdfdim = 0;
  for (i = 0; i<3; i++){
      hdfdim = ndims - i - 1;
      max_items = (int)this->maxdims[hdfdim];
      if (max_items <= 0)
      {
        max_items = 1; // For infinite length dimensions
      } else {
        if (user_chunking[i] > max_items) user_chunking[i] = max_items;
      }
      if (user_chunking[i] < 1) user_chunking[i] = max_items;
      this->chunkdims[hdfdim] = user_chunking[i];
  }

  return status;
}

void NDFileHDF5Dataset::extendDataSet(int extradims)
{
  int i=0;
  bool growdims = true;
  bool growoffset = true;

  // Add the n'th frame dimension (for multiple frames per scan point)
  extradims += 1;

  // first frame already has the offsets and dimensions preconfigured so
  // we dont need to increment anything here
  if (this->nextRecord == 0) return;

  // in the simple case where dont use the extra X,Y dimensions we
  // just increment the n'th frame number
  if (extradims == 1){
    this->dims[0]++;
    this->offset[0]++;
    return;
  }

  // run through the virtual dimensions in reverse order: n,X,Y
  // and increment, reset or ignore the offset of each dimension.
  for (i=extradims-1; i>=0; i--){
    if (this->dims[i] == this->virtualdims[i]) growdims = false;

    if (growoffset){
      this->offset[i]++;
      growoffset = false;
    }

    if (growdims){
      if (this->dims[i] < this->virtualdims[i]) {
        this->dims[i]++;
        growdims = false;
      }
    }

    if (this->offset[i] == this->virtualdims[i]) {
      this->offset[i] = 0;
      growoffset = true;
      growdims = true;
    }
  }

  return;
}



asynStatus NDFileHDF5Dataset::writeFile(NDArray *pArray, hid_t datatype, hid_t dataspace, hsize_t *framesize)
{
  herr_t hdfstatus;

  hdfstatus = H5Dset_extent(this->dataset_, this->dims);

  // Select a hyperslab.
  hid_t fspace = H5Dget_space(this->dataset_);
  hdfstatus = H5Sselect_hyperslab(fspace, H5S_SELECT_SET, this->offset, NULL, framesize, NULL);

  // Write the data to the hyperslab.
  hdfstatus = H5Dwrite(this->dataset_, datatype, dataspace, fspace, H5P_DEFAULT, pArray->pData);

  hdfstatus = H5Sclose(fspace);

  this->nextRecord++;

  return asynSuccess;
}

hid_t NDFileHDF5Dataset::getHandle()
{
  return this->dataset_;
}


void NDFileHDF5Dataset::closeHandle()
{
  herr_t hdferr;
  if (this->dataset_ > 0) {
    print_apl(this->dataset_);
	// Retrieve the dataset address
	H5O_info_t object_info;
	herr_t hdferr;
	hdferr = H5Oget_info( this->dataset_, &object_info );
	if (hdferr < 0) {
      // error!
	  return;
	}
	this->addr_ = object_info.addr;
	hdferr = H5Dclose( this->dataset_ );
	this->dataset_ = 0;
  }

}

// TODO: protect against some corner-cases where dataset_ and/or file is open/closed already...
hid_t NDFileHDF5Dataset::reopenHandle(hid_t file)
{
  hid_t dset=0;
  if (this->dataset_ == 0 && file > 0) {
	dset = H5Oopen_by_addr( file, this->addr_ );
	if (dset > 0) this->dataset_ = dset;

	// DEBUG: Check and print the chunk cache config
	print_apl(dset);
  }

  return dset;
}

void print_apl(hid_t dset_id)
{
  size_t rdcc_nslots;
  size_t rdcc_nbytes;
  double rdcc_w0;

  hid_t apl = H5Dget_access_plist( dset_id );
  H5Pget_chunk_cache( apl, &rdcc_nslots, &rdcc_nbytes, &rdcc_w0 );
  std::cout << "\t rdcc_nslots = " << rdcc_nslots << std::endl;
  std::cout << "\t rdcc_nbytes = " << rdcc_nbytes << std::endl;
  std::cout << "\t rdcc_w0     = " << rdcc_w0 << std::endl;

}
