function measure = heuristicMeasure(config,Node)
VesData2D = config.VesData2D;
VesData3D_Trans = Node.Trans;
EdgePair = Node.EdgePair;
alpha1 = config.alpha1;
alpha2 = config.alpha2;
sigma = config.sigma;
%% measure of registration
VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);
[~,distArray] = dist_knn(VesData3D_Proj,VesData2D,config.scale);
m1 = mean(exp(-distArray));
%% measure of matching
m2 = 0;
for iPair = 1:length(EdgePair)
    Eg3D = EdgePair(iPair).Edge3D;
    Eg2D = EdgePair(iPair).Edge2D;
    if isempty(Eg3D)||isempty(Eg2D)
        continue;
    end
    branchType1 = FindBranchtype(VesData3D_Proj,Eg3D);
    branchType2 = FindBranchtype(VesData2D,Eg2D);

%     [cm, cSq] = DiscreteFrechetDist(branchType1.EdgePoints,branchType2.EdgePoints);
    [~,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints',1);
    cm = meanDistance(branchType1.EdgePoints(ix,:),branchType2.EdgePoints(iy,:));
    
    cm = cm/length(ix);
    m2 = m2 + exp(-cm/sigma);
end
% m2 = m2/length(EdgePair);
measure = alpha1*m1+alpha2*m2;

end