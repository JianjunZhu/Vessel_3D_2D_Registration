function config = makeRegistrationConfiguration
%%
config.MultiThread = 'On';
%% Initial Registration
config.Display = 'Off';
config.DisplayDenseCorr = 'Off';
config.DisplaySparseCorr = 'Off';
config.PnP = 'ASPnP';%'EPnP','EPPnP','LHM','REPPnP','ASPnP','RPnP','DLS','OPnP','GOP','PPnP'
config.RefinePnP = 'Refinement3DA2D';
%% Rigid Registration
config.Rigid = 'On';
config.RigidnIteration = 3;
RigidParamterList = {'PriorCorr','Position','Frechet','Length'};
% {'PriorCorr','PointType','Directed','Position','Frechet','Redundant','Length'};
config.RigidParamterList = RigidParamterList;

%% Non-rigid
config.Nonrigid = 'On';
config.NonrigidnIteration = 3;
NonrigidParamterList = RigidParamterList;
config.NonrigidParamterList = NonrigidParamterList;
config.NonrigidMethod = 'SSM';

