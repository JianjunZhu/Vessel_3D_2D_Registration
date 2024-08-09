% [f, grad] = GaussTransform(A,B,scale)
% The inner product between two spherical Gaussian mixtures computed using the Gauss Transform.
% The centers of the two mixtures are given in terms of two point sets A and B (of same dimension d)
% represented by an mxd matrix and an nxd matrix, respectively.
% It is assumed that all the components have the same covariance matrix represented by 
% a scale parameter (scale).  Also, in each mixture, all the components are equally Extended.

%%  $Author: nbaka $
%%  $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $

function [f,g,ff] = ExtendedGaussTransform(A,B,scale)	

if exist('mex_ExtendedGaussTransform','file')
    [f,g,ff] = mex_ExtendedGaussTransform(A',B',scale);
    g = g';
else
    message = ['Precompiled GaussTransform module not found.\n' ...
        'If the corresponding MEX-functions exist, run the following command:\n' ...
        'mex mex_ExtendedGaussTransform.c ExtendedGaussTransform.c -output mex_ExtendedGaussTransform'];
    message_id = 'MATLAB:MEXNotFound';
    error (message_id, message);
    
end
