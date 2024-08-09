% [result] = transform_by_rigid3d(pointset, param)
% perform a 3D rigid transform on a pointset and
% return the transformed pointset
% Note that here 3D rigid transform is parametrized by 7 numbers
% [quaternion(1 by 4) translation(1 by 3)]
%
% See also: quaternion2rotation, transform_by_rigid2d,
% transform_by_affine3d

function [result] = transform_by_rigid3d(pointset, param)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================
n = size(pointset,1);
% r = quaternion2rotation(param(1:4));
r=quat2dcm(param(1:4));
t = param(5:7);

meanPoint = mean(pointset,1);
result = add2AllMat(add2AllMat(pointset,-meanPoint)*r',+ t + meanPoint);