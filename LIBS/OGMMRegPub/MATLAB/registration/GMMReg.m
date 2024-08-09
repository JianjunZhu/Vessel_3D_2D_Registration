%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 12:51:37 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

function [param, transformed_model,history,config] = GMMReg(model, scene, scale, motion, init_param,varargin)
%   'model' and 'scene'  are two point sets
%   'scale' is a free scalar parameter
%   'motion':  the transformation model, can be
%         ['rigid2d', 'rigid3d', 'affine2d', 'affine3d']
%         The default motion model is 'rigid2d' or 'rigid3d' depending on
%         the input dimension
%   'init_param':  initial parameter

config.model = model;
config.scene = scene;
config.scale = scale;
config.motion = motion;
config.init_param = init_param;
param = init_param;

% initialization of optional parameters
config.display = 1; %   'display': display the intermediate steps or not.
config.max_iter = 300;
% config.Lb = [-1*ones(3,1);0.5;-1000*ones(3,1)];
% config.Ub = [1*ones(3,1);1.0001;1000*ones(3,1)];
config.nModelPoints = size(model,1);
config.dimModelPoints = size(model,2);
config.nScenePoints = size(scene,1);
config.dimScenePoints = size(scene,2);
config.wTrans =100; % weight for translation gradient
config.sigmaOrient = 0.3; % for Oriented GMM, threshold around 60 degree
config.optimizer = 'fmincon';%'fminsearch';%
config.wF2 = 1; % subtraction objective function. With =0 it would be multiplication.
config.orient = 0; % 0 for unoriented point clouds, 1 for oriented point clouds mod 180 degree, and 2 for oriented point clouds mod 360 degree

for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'display' %   'display': display the intermediate steps or not.
            config.display = varargin{i+1}; 
        case 'orient'
            config.orient = varargin{i+1}; 
        case 's2w'
            config.s2w = varargin{i+1};
        case 'optimizer'
            config.optimizer = varargin{i+1};
        case 'projMatrix'
            config.projMatrix = varargin{i+1};
        case 'maxIter'
            config.max_iter = varargin{i+1};
        case 'projPlane'
            config.projPlane = varargin{i+1};
        case 'objFunWeight'
            config.wF2 = varargin{i+1};
        case 'wTrans'
            config.wTrans = varargin{i+1};
        case 'sigmaOrient'
            config.sigmaOrient = varargin{i+1};
        case 'radius'
            config.weightMatrixCell = varargin{i+1};
        case 'PriorModel'
            config.PriorModel = varargin{i+1};
        case 'quaternion'
            config.quatParam = varargin{i+1};
    end
end

for iScale = 1:numel(scale)
    config.scale = scale(iScale);
    config.init_param = param;
    [param, transformed_model, history, config] = gmmreg_L2_(config);
end
