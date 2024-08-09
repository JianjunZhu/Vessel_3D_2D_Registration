function VesData3DReg = NonRigidRegistration(VesData3D,VesData2D,config)
%% set control points
numOfCtrls = 50;
spac = round(size(VesData3D.Graph,1)/numOfCtrls);
[GraphDataTemp,~] = processGraphWrap(VesData3D.VesselPoints,VesData3D.Graph,spac);
CtrlPts = GraphDataTemp.VesselPoints;

% CtrlPts = VesData3D.VesselPoints;
config.CtrlPts = CtrlPts;
config.VesData3D = VesData3D;
config.VesData2D = VesData2D;
%% calculate distance transform
if ~isfield(VesData2D,'img_centerline')
    img_centerline = centerlineToImage(VesData2D.VesselPoints,[512,512]);
else
    img_centerline = VesData2D.img_centerline;
end
img_DT = bwdist(img_centerline);
config.img_DT = img_DT;
%% calculate scale
P = VesData2D.VesselPoints_Sparse;
config.scale2D = power(det(P'*P/length(P)),1/(2^size(P,2)));
%% calculate length
[len,lenArray]= CalculateVesselLength(VesData3D);
config.len = len;
config.EdgeCounts = length(lenArray);
%% config initialize
config.step = 1e5;

config.max_iter = 1000;
config.optimizer = 'fminsearch';%'fminsearch';%
optimizer = str2func(config.optimizer);
problem.solver = config.optimizer;
problem.lb = [];
problem.ub = [];
switch config.optimizer
    case 'fminsearch' %nelder-mead
        options = optimset( 'display','iter','TolFun',1e-4, 'TolX',1e-18, 'TolCon', 1e-4);
    case 'fminunc' % default
        options = optimset( 'display','iter', 'LargeScale','off','TolFun',1e-4, 'TolX',1e-18, 'TolCon', 1e-5);
        options = optimset(options, 'GradObj', 'off'); % 'on'
    case 'fmincon' 
        options = optimset( 'display','off', 'LargeScale','off','TolFun',1e-4, 'TolX',5*1e-5, 'TolCon', 1e-4);
        options = optimset(options, 'GradObj', 'off');
end
options = optimset(options, 'MaxFunEvals', config.max_iter);
problem.options = options;

param = zeros(size(CtrlPts));
[config.Tau,config.U] = CalculateBasis(CtrlPts,VesData3D.VesselPoints,config.beta);

nonrigid_sigma = config.nonrigid_sigma;
for sigma = nonrigid_sigma
    config.sigma = sigma;
    problem.x0 = param;
    problem.objective = @(x)Nonrigid_costfunc_(x, config);
    param = optimizer(problem)
end 
pts3d_reg = VesData3D.VesselPoints + config.Tau*param*config.step ;
VesData3DReg = UpdateVesselPoints(VesData3D,pts3d_reg);
end

function [Tau, U] = CalculateBasis(CtrlPts,Points,beta)

Tau = zeros(length(Points),length(CtrlPts));
for i = 1:length(Points)
    pt_i = Points(i,:);
    for j = 1:length(CtrlPts)
        pt_j = CtrlPts(j,:);
        Tau(i,j) = exp(-norm((pt_i-pt_j)./beta)^2/2);
    end
end

U = zeros(length(CtrlPts));
for i = 1:length(CtrlPts)
    pt_i = CtrlPts(i,:);
    for j = i+1:length(CtrlPts)
        pt_j = CtrlPts(j,:);
        U(i,j) = exp(-norm((pt_i-pt_j)./beta)^2/2);
        U(j,i) = U(i,j);
    end
    U(i,i) = 1;
end

end

function [f,g] = Nonrigid_costfunc_(param, config)
param = param*config.step ;
g = [];
Tau = config.Tau;
U = config.U;
Points = config.VesData3D.VesselPoints;

t = Tau*param;
pts3d_reg = Points + t;
VesDataReg = UpdateVesselPoints(config.VesData3D,pts3d_reg);
VesData3D_Proj = ProjectVesselData(VesDataReg,config.VesData2D.K);
f = 0;
%% 1st item : distance error
dis = DT_Distances(pts3d_reg,config.img_DT ,config.VesData2D.K);
f1 = mean(dis/(config.sigma^2)); 
%% 2nd item : regularization
f2 = trace(param'*U*param);
%% 3rd item: scale 

P = VesData3D_Proj.VesselPoints_Sparse;
scale3D = power(det(P'*P/length(P)),1/(2^size(P,2)));
scale2D = config.scale2D;

f3 = scale2D/scale3D+scale3D/scale2D;
%% 4th item: length
f4 = abs(config.len - CalculateVesselLength(VesDataReg))/config.len;
%% 5th: manifold regularization
A = config.VesData3D.Graph;
D = diag(sum(A,1));
L = D - A;
f5 = trace(t'*L*t)/config.EdgeCounts;
%%
f = f1 + 0.0001*f2 + f3*0.01 + f4*0.1 + f5*0.1;
% f = f1 + f3*0.05 + f4 + f5;
% f = f1;
% disp(['f1=',num2str(f1),',f2=',num2str(f2),',f3=',num2str(f3),',f4=',num2str(f4),',f5=',num2str(f5)]);


end

function dis = DT_Distances(pts3d,img_DT,K)
projMatrix = K*eye(3,4);
[pts3d_proj,~] = projectPointsByProjectMatrix(cart2homo(pts3d'),projMatrix);
ptsIdxs = uint16(pts3d_proj);

measures = zeros(length(ptsIdxs),1);
for i = 1:length(ptsIdxs)
    idxs = ptsIdxs(i,:);
    x = idxs(1); y = idxs(2);
    if x < 1
        x = 1;
    elseif x > size(img_DT,2)
        x = size(img_DT,2);
    end
    
    if y < 1
        y = 1;
    elseif y > size(img_DT,1)
        y = size(img_DT,1);
    end
    
    measures(i) = img_DT(y,x);
end
dis = measures;

end

function pts3d_reg = transform_nonrigid(Points,Tau,param)

pts3d_reg = Points + Tau*param;

end

function [len,lenArray] = CalculateVesselLength(VesData3D)
lenArray = [];
for i = 1:numel(VesData3D.BranchesCell)
    EdgePoints = VesData3D.BranchesCell{i}.EdgePoints;
    for j = 1:size(EdgePoints,1)-1
        lenArray = [lenArray, norm(EdgePoints(j,:)-EdgePoints(j+1,:))];
    end
end
len = sum(lenArray);
end
