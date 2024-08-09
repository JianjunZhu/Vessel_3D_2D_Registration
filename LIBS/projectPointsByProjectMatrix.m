function [projectedPoints,omegas] = projectPointsByProjectMatrix(points,projMatrix)
%%=====================================================================
%% $Author: zhujianjun $
%% $Date: 31-May-2017 $
%%=====================================================================
Point_p = projMatrix*points;
omegas = (Point_p(3,:)).^-1;
Point_temp = Point_p(1:2,:).*repmat(omegas,2,1);
projectedPoints = Point_temp';