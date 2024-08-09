function config = makeconfigMC
config.redundant = 3;
config.scale = [5,0.2];

config.sigma = 5;

config.alpha1 = 1;
config.alpha2 = 0.1;
config.startIDPair = [1,1];
config.FilterStrategy = 'MCTSR2';%fast MCTSR2 custom
config.AssignStrategy = 'uniform';%'uniform';%'projected';%
config.NExpand = 4;
config.type = 'MCT';
config.SimulationCounts = 20;

config.urgency_sigma = 0.001;
config.Qnorm = 1;
config.maxIteration = 300;
config.FindChildNodeType = 'coronary';%'coronary';%
config.MaxExpandLevel = 3;
config.NChild = 4;
config.refine = 'on';

config.multi_sigma = 5;%[10,5,.5];
config.lamda1 = 0.1;
% add flat UCB and pruning
config.advance = 1;
config.flat_para = 5;
config.pruning_thr = 1.2;

%% nonrigid
config.beta = 5;
config.nonrigid_sigma = [15,5,.5];

config.lamda2 = 1;
config.lamda3 = 1;
