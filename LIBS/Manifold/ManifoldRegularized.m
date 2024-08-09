function VesData3DReg = ManifoldRegularized(VesData3D,VesData2D,config,varargin)
PairDense = [];
for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'PairDense'
            PairDense = varargin{i+1};
    end
end
config.PairDense = PairDense;
config.VesData3D = VesData3D;
config.VesData2D = VesData2D;
config.T_final = 0.5;
lambda1_final = 0.1;
%% parameters
A = VesData3D.Graph;
config.L = diag(sum(A,1)) - A;
% belta is the scale of basis function
% config.belta = findMinimalDistance(VesData3D.VesselPoints);
config.belta = config.T_final;

MagDegree = 100;
% T_final = findMinimalDistance(VesData3D.VesselPoints);
T_final = config.T_final;
T_update = 0.9; 
T_init = MagDegree * T_final;
T_iter = T_init;
% lambda1 and lambda2 are the weights of deformation and manifold
% regularization items
% config.lambda1 = 10;

config.lambda1 = lambda1_final * MagDegree;

lambda2_final = 100 / (length(find(A==1)) / 2);
config.lambda2  = lambda2_final;% * MagDegree;
% lambda1_init = 100 * lambda1_final;
% config.lambda1 = lambda1_init;
iIter = 1;
MaxIter = 50;
while (iIter < MaxIter) && (T_iter >= T_final) && (config.lambda1 > lambda1_final) % (config.lambda2 > lambda2_final) &&
    %% Dense Matching
%     [Points3D, Points2D] = DenseMatchingWithNodeMatching(config,T_iter,T_init);
%     [Points3D, Points2D] = DenseMatchingAssign(config,T_iter,T_init);
    [Points3D, Points2D] = DenseMatchingClosest(config);
%     [Points3D, Points2D] = DenseMatchingWithPairDense(config);
    
    config.Points3D = Points3D;
    config.Points2D = Points2D;
    
    %% Control Points Stuff
    numOfPoints = length(config.VesData3D.VesselPoints);
    if numOfPoints < 500;
        config.ControlPoints = config.VesData3D.VesselPoints;
        [config.T,config.U] = CalcBasicMatrix(config.Points3D,config.ControlPoints,config.belta);
    else
        numOfCtrls = 500;
        spac = round(size(config.VesData3D.Graph,1)/numOfCtrls);
        [GraphDataTemp,~] = processGraphWrap(config.VesData3D.VesselPoints,config.VesData3D.Graph,spac);
        config.ControlPoints = GraphDataTemp.VesselPoints;
        [config.T,config.U] = CalcBasicMatrix(config.Points3D,config.ControlPoints,config.belta);
    end
 
    %%
%     P = VesData2D.K*eye(3,4);
%     fY = projectPointsByProjectMatrix(cart2homo(Points3D'),P);
%     figure;imshow(VesData2D.img_src,'border','tight','initialmagnification','fit');
%     hold on;
%     scatter(fY(:,1),fY(:,2),'r');
%     scatter(Points2D(:,1),Points2D(:,2),'g');
%     for i = 1:size(fY,1)
%         plot([fY(i,1),Points2D(i,1)],[fY(i,2),Points2D(i,2)]);
%     end
%     fS = projectPointsByProjectMatrix(cart2homo(config.ControlPoints'),P);
%     scatter(fS(:,1),fS(:,2),'b');
%     hold off; drawnow;
    %% Optimization for NonRigid
    Param = zeros(size(config.ControlPoints));
    Param = reshape(Param,[],1);
    maxIter = 50;
    memSize = 10;
    [Param_Output,Fcost,k] =optLBFGS(@costfunc_ManifoldRegularized,Param,config,maxIter,memSize);
    
    if numel(Param_Output(isnan(Param_Output))) > 0
        break;
    end
    
    Param_Output = reshape(Param_Output,[],3);

    deformed_points = config.Points3D  + config.T' * Param_Output;
    VesData3DReg = UpdateVesselPoints(config.VesData3D,deformed_points);
    config.VesData3D = VesData3DReg;
    %%
    iIter = iIter + 1;
    T_iter = T_update * T_iter;
%     config.lambda2 = config.lambda2 * T_update;
    config.lambda1 = config.lambda1 * T_update;
    %% Display
%     SavePath = [config.dirOutput,'GIF/',num2str(iIter,'%02d'),'.png'];
%     DisplayRealRegResultNew(VesData3DReg,VesData2D,'SavePath',SavePath,'visible',1);
%     DisplayRealRegResultNew(VesData3DReg,VesData2D);
%     Display3DA2DVesselData(VesData3DReg,VesData2D.K,VesData2D);
 end


end

function [Points3D, Points2D] = DenseMatchingClosest(config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
VesData3D_Proj = ProjectVesselData(VesData3D,VesData2D.K);

%% Closest Relation Matching
NS = createns(VesData2D.VesselPoints,'NSMethod','kdtree');
[idxs, ~] = knnsearch(NS,VesData3D_Proj.VesselPoints,'k',1);
Points3D = VesData3D.VesselPoints;
Points2D = VesData2D.VesselPoints(idxs,:);


end

function [Points3D, Points2D] = DenseMatchingAssign(config,T_iter,T_init)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;

Points3D = VesData3D.VesselPoints;
projMatrix = VesData2D.K*eye(3,4);
[Points3DProj,~] = projectPointsByProjectMatrix(cart2homo(Points3D'),projMatrix);
Points2D = VesData2D.VesselPoints;
%%
AssignMatrix = zeros(size(Points2D,1)+1,size(Points3DProj,1)+1);
for i = 1:size(Points2D,1)
    pt_i = Points2D(i,:);
    for j = 1:size(Points3DProj,1)
        pt_j = Points3DProj(j,:);
        AssignMatrix(i,j) = exp(-norm(pt_i-pt_j)^2/(T_iter*2))/T_iter;
    end
end
Outlier = mean(Points3DProj,1);
for i = 1:size(Points2D,1)
    pt_i = Points2D(i,:);
    AssignMatrix(i,size(Points3DProj,1)+1) = exp(-norm(pt_i-Outlier)^2/(T_init*2))/T_init;
end
Outlier = mean(Points2D,1);
for j = 1:size(Points3DProj,1)
    pt_j = Points3DProj(j,:);
    AssignMatrix(size(Points2D,1)+1,j) = exp(-norm(pt_j-Outlier)^2/(T_init*2))/T_init;
end
AssignMatrix(size(Points2D,1)+1,size(Points3DProj,1)+1) = 0;
%%
SumMat = repmat(sum(AssignMatrix,1),size(AssignMatrix,1),1);
AssignMatrix = AssignMatrix./(SumMat + eps);

%% Compute new correspondence
Pts2D = [];
for j = 1:size(AssignMatrix,2)-1
    as = AssignMatrix(1:end-1,j);
    Pts2D = [Pts2D;sum(Points2D.*repmat(as,1,2),1)];
end
Points2D = Pts2D;


end


function [f,g] = costfunc_ManifoldRegularized(Param,config)
Param = reshape(Param,[],3);
VesData3D = config.VesData3D; VesData2D = config.VesData2D;
Points3D = config.Points3D; Points2D = config.Points2D;
belta = config.belta; lambda1 = config.lambda1; lambda2 = config.lambda2;
U = config.U; ControlPoints = config.ControlPoints; T = config.T;
L = config.L;
%%
W = Param;
P = VesData2D.K*eye(3,4);
Tao = T' * W;
Y = Points3D + Tao;
Yh = [Y,ones(size(Y,1),1)];
fY = projectPointsByProjectMatrix(cart2homo(Y'),P);
n = size(Points3D,1);
X = Points2D;
%% Distance Error Item
try
    f1 = sum(sum((X - fY).^2)) / n;
catch
    size(X)
    size(fY)
end


gradq = zeros(size(Y));
for i = 1:n
    Jc = zeros(3,2);
    P1_ = P(1,:)*Yh(i,:)';
    P2_ = P(2,:)*Yh(i,:)';
    P3_ = P(3,:)*Yh(i,:)';
    
    Jc(1,1) = P(1,1) * P3_ - P(3,1) * P1_;
    Jc(1,2) = P(2,1) * P3_ - P(3,1) * P2_;
    Jc(2,1) = P(1,2) * P3_ - P(3,2) * P1_;
    Jc(2,2) = P(2,2) * P3_ - P(3,2) * P2_;
    Jc(3,1) = P(1,3) * P3_ - P(3,3) * P1_;
    Jc(3,2) = P(2,3) * P3_ - P(3,3) * P2_;
    
    Jc = Jc ./ (P3_^2 + eps);
    
    gradq(i,:) = -(2/n)*(X(i,:)-fY(i,:))*Jc';
end
grad1 = T * gradq;
%% Bending Energy and Manifold Regularization
UW = U * W;
f2 = trace(W' * UW); 
grad2 = 2 * UW;

LT = L * Tao;
f3 = trace(Tao' * LT); 
grad3 = 2 * T * LT;
%%
f = f1 + lambda1 * f2 + lambda2 * f3;
g = grad1 + lambda1 * grad2 + lambda2 * grad3;
g = reshape(g,[],1);
end

function [T,U] = CalcBasicMatrix(Points3D,ControlPoints,belta)
A = pdist2(ControlPoints, Points3D);
T = exp(-0.5*(A/belta).^2);
B = pdist2(ControlPoints, ControlPoints);
U = exp(-0.5*(B/belta).^2);
end

function [Points3D, Points2D] = DenseMatchingWithPairDense(config)
Cor_Dense = config.PairDense;
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
VesData3D_Proj = ProjectVesselData(VesData3D,VesData2D.K);

%% Closest Relation Matching
NS = createns(VesData2D.VesselPoints,'NSMethod','kdtree');
[idxs, ~] = knnsearch(NS,VesData3D_Proj.VesselPoints,'k',1);
Points3D = VesData3D.VesselPoints;
Points2D = VesData2D.VesselPoints(idxs,:);
Points2D(Cor_Dense(:,1),:) = VesData2D.VesselPoints(Cor_Dense(:,2),:);
end

function [Points3D, Points2D] = DenseMatchingWithNodeMatching(config,T_iter,T_init)
NodeMatching = config.NodeMatching;
Cor_Sparse_temp = NodeMatching';
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
VesData3D_Proj = ProjectVesselData(VesData3D,VesData2D.K);
%% Topo Dense Matching
Cor_Dense = fineGraphMatch(VesData3D_Proj,VesData2D,Cor_Sparse_temp,{'Directed'});
[~,ia,~] = unique(Cor_Dense(:,1));
Cor_Dense = Cor_Dense(ia,:);
%%
% [~, Points2D] = DenseMatchingAssign(config,T_iter,T_init);
% Points3D = VesData3D.VesselPoints;
% Points2D(Cor_Dense(:,1),:) = VesData2D.VesselPoints(Cor_Dense(:,2),:);


%% Closest Relation Matching
NS = createns(VesData2D.VesselPoints,'NSMethod','kdtree');
[idxs, ~] = knnsearch(NS,VesData3D_Proj.VesselPoints,'k',1);
Points3D = VesData3D.VesselPoints;
Points2D = VesData2D.VesselPoints(idxs,:);
Points2D(Cor_Dense(:,1),:) = VesData2D.VesselPoints(Cor_Dense(:,2),:);
end

function dis = findMinimalDistance(Points)
NS = createns(Points,'NSMethod','kdtree');
[~, DistArray] = knnsearch(NS,Points,'k',2);
dis = min(DistArray(:,2));
end
