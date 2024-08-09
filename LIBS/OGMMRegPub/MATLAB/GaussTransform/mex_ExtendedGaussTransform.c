/*%%=====================================================================
%% Language:  C
%% Author:    $Author: nbaka $
%% Date:      $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%% Version:   $Revision: 473 $
%%=====================================================================*/

#include "mex.h"

double ExtendedGaussTransform(double* A, double* B, int m, int n, int dim, double* scale,double *func, double* grad);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Declare variables */ 
    int m, n, dim; 
    double *A, *B, *result, *grad, *scale, *func;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 3) {
	mexErrMsgTxt("Three input arguments required.");
    } 
    if (nlhs > 3){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of input argument */
    if (!(mxIsDouble(prhs[0]))) {
      mexErrMsgTxt("Input array must be of type double.");
    }
    if (!(mxIsDouble(prhs[1]))) {
      mexErrMsgTxt("Input array must be of type double.");
    }
    if (!(mxIsDouble(prhs[2]))) {
      mexErrMsgTxt("Input array must be of type double.");
    }
    
    /* Get the number of elements in the input argument */
    /* elements=mxGetNumberOfElements(prhs[0]); */
    /* Get the data */
    A = (double *)mxGetPr(prhs[0]);
    B = (double *)mxGetPr(prhs[1]);
    scale = (double *) mxGetPr(prhs[2]);

  	/* Get the dimensions of the matrix input A&B. */
  	m = mxGetN(prhs[0]);
  	n = mxGetN(prhs[1]);
  	dim = mxGetM(prhs[0]);
    //printf("dim = %i\n", dim); 
  	if (mxGetM(prhs[1])!=dim)
  	{
  		mexErrMsgTxt("The two input point sets should have same dimension.");
  	}
    /* Allocate the space for the return argument */
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(dim,m,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1,m,mxREAL);
    result = mxGetPr(plhs[0]);
    grad = mxGetPr(plhs[1]);
    func = mxGetPr(plhs[2]);
    *result = ExtendedGaussTransform(A, B, m, n, dim, scale, func, grad);
    
}
