% [result] = transform_by_affine2d(pointset, param)
% perform a 2D affine transform on a pointset and
% return the transformed pointset
% the param is expected in the order of 
%  [tx ty a11 a21 a12 a22] or
%  [tx a11 a12 ]
%  [ty a21 a22 ]
%
% See also: transform_by_affine3d, transform_by_rigid2d
function [result] = transform_by_affine2d(pointset, param)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================
n = size(pointset,1);
A = reshape(param,2,3);   A = A';
result =  [ones(n,1)  pointset(:,1:2)]*A;


