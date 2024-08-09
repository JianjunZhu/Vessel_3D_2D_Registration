% Perform a spatial tranformation on a given pointset
% motion:  the motion model represented by string, can be
%         'rigid','affine', 'tps'
% parameter: a row vector
function [transformed_pointset] = transform_pointset(pointset, motion, parameter,varargin)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================
dim = size(pointset,2);

if dim == 2
    switch lower(motion)       
        case 'translation'
            parameter(1:4) = [0 0 0 1]';
            transformed_pointset = transform_by_rigid2d(pointset, parameter);
        case 'rigid'
            transformed_pointset = transform_by_rigid2d(pointset, parameter);
        case 'affine'
            transformed_pointset = transform_by_affine2d(pointset, parameter);
        case 'tps'
            ctrl_pts = varargin{1};
            init_affine = varargin{2};
            [n,d] = size(ctrl_pts);
            p = reshape([init_affine parameter],d,n); p = p';
            transformed_pointset = transform_by_tps(p, pointset, ctrl_pts);
        otherwise
            error('Unknown motion type');
    end
    
elseif dim == 3
    switch lower(motion)       
        case 'translation'
            parameter(1:4) = [0 0 0 1]';
            transformed_pointset = transform_by_rigid3d(pointset, parameter);
        case 'rigid'
            transformed_pointset = transform_by_rigid3d(pointset, parameter);
        case 'affine'
            transformed_pointset = transform_by_affine3d(pointset, parameter);
        case 'tps'
            ctrl_pts = varargin{1};
            init_affine = varargin{2};
            [n,d] = size(ctrl_pts);
            p = reshape([init_affine parameter],d,n); p = p';
            transformed_pointset = transform_by_tps(p, pointset, ctrl_pts);
        otherwise
            error('Unknown motion type');
    end
else
    error('transform_pointset: pointset has to be 2 or 3 dimensional!'); 
end

