function [param, transformed_model, history, config] = gmmreg_L2_(config)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 12:51:37 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

% Set up shared variables with OUTFUN
history.x = [ ];
history.fval = [ ];
if nargin<1
    error('Usage: gmmreg_L2(config)');
end
[n,d] = size(config.model); % number of points in model set
if (d~=2)&&(d~=3)
    error('The current program only deals with 2D or 3D point sets.');
end

optimizer = str2func(config.optimizer);
problem.solver = config.optimizer;
problem.lb = [];
problem.ub = [];
switch config.optimizer
    case 'fminsearch' %nelder-mead
        options = optimset( 'display','final','TolFun',1e-4, 'TolX',5*1e-5, 'TolCon', 1e-4);
    case 'fminunc' % default
        options = optimset( 'display','final', 'LargeScale','off','TolFun',1e-7, 'TolX',1e-7, 'TolCon', 1e-4);
        options = optimset(options, 'GradObj', 'off'); % 'on'
    case 'fmincon' 
        options = optimset( 'display','final', 'LargeScale','off','TolFun',1e-4, 'TolX',5*1e-5, 'TolCon', 1e-4);
        options = optimset(options, 'GradObj', 'off');
%         problem.lb = config.Lb;
%         problem.ub = config.Ub;
end
options = optimset(options, 'MaxFunEvals', config.max_iter);
problem.options = options;

tic

switch lower(config.motion)
    case 'rigid'
        x0 = config.init_param;
        % for translation weighting
        w = config.wTrans;
        if config.dimModelPoints == 2
            x0 = x0 ./ [w,w,1];
        else
            x0 = x0 ./ [1,1,1,1,w,w,w];
        end
        problem.x0 = x0;
        problem.objective = @(x)gmmreg_L2_costfunc_(x, config);
        param = optimizer(problem);
        if config.dimModelPoints == 2
            param = param .* [w,w,1];
        else
            param = param .* [1,1,1,1,w,w,w];
        end

        transformed_model = transform_pointset(config.model, config.motion, param);
        
    case 'ssm'
        PriorModel = config.PriorModel;
        quatParam = config.quatParam;
        dim = PriorModel.dim;
        latent = PriorModel.latent(1:size(config.init_param,2));
        
        
        problem.lb = -sqrt(latent)*5;
        problem.ub = sqrt(latent)*5;
        x0 = config.init_param;
        problem.x0 = x0;
        problem.objective = @(x)gmmreg_L2_ssm_costfunc_(x, config);
        param = optimizer(problem);
        
        transformed_model = GeneratePtsByPriorModel(PriorModel,param,quatParam);
end

toc        






