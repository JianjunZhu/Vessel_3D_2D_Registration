function [projectedPointsOnPlane,omegas,projectionMatrix0,norm0] = projectPointsToPlane(points,proj)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

p2w = proj.planeToWorldMatrix;
sourcePoint = proj.sourcePoint; % in image coordinates
if ~iscolumn(sourcePoint)
    sourcePoint = sourcePoint';
end
sourcePlaneDist = dot(sourcePoint,p2w(1:3,3));

%% project landmarks to plain
% calculate projection matrix
transMatrix = [eye(4,3),[-1 * sourcePoint;1]];
norm0 = p2w(:,3)' ./ sourcePlaneDist;
perspectiveProjection = [eye(3,4);norm0];

% project the shape
projectionMatrix0 = p2w^-1 * transMatrix^-1 * perspectiveProjection * transMatrix;
projectedPoints = projectionMatrix0 * points;
omegas = (projectedPoints(4,:)).^-1;
projectedPointsOnPlane = projectedPoints(1:2,:).*repmat(omegas,2,1);