clc;clear;close all;
addpath(genpath(pwd));
warning('off');
%% Get 3D 2D Vessel
load('Data.mat')
Display3DA2DVesselData(VesData3D,VesData2D.K,VesData2D,'title','Initial');
%% ICGM
% config = makeRegistrationConfiguration;
% config.redundant = 2;
% [VesData3DReg,~] = TopoRegistration(VesData3D,VesData2D,config);
% Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D,'title','ICGM');
%% GTSR
% config = makeconfig;
% config.VesData3D = VesData3D;
% config.VesData2D = VesData2D;
% VesData3DReg = GreedyRegistration(config);
% Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D,'title','GTSR');
%% HTSR
% VesData3DReg = HeuristicRegistration(config);
% Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D,'title','HTSR');
%% MCTSR
if ~isfield(VesData2D,'img_DT')
    img_centerline = centerlineToImage(VesData2D.VesselPoints,[2500,2500]);
    VesData2D.img_DT = bwdist(img_centerline);
end
config = makeconfigMC;
config.FindChildNodeType = 'coronary';
config.VesData3D = VesData3D;
config.VesData2D = VesData2D;
VesData3DReg = MonteCarloTreeSearchRegistration(config);
Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D,'title','MCTSR');
%% manifold nonrigid
VesData3DReg = ManifoldRegularized(VesData3DReg,VesData2D,config);
Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D,'title','manifold');


