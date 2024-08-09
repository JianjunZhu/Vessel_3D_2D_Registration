%% customMeasure 
function measure = customMeasure(config,Node)
VesData2D = config.VesData2D;
VesData3D_Trans = Node.Trans;
EdgePair = Node.EdgePair;
alpha1 = config.alpha1;
alpha2 = config.alpha2;
sigma = config.sigma;
%% measure of registration
VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);

% [~, distArray1] = DT_Distance(VesData3D_Proj,VesData2D);
[~,distArray1] = dist_knn(VesData3D_Proj,VesData2D,config.scale);
% distArray1 = 0;
% [~, distArray2] = DT_Distance(VesData2D,VesData3D_Proj);
[~,distArray2] = dist_knn(VesData2D,VesData3D_Proj,config.scale);
m1 = mean(exp(-distArray1))+mean(exp(-distArray2));
%% measure of matching
m2 = 0;
% for iPair = 1:length(EdgePair)
%     Eg3D = EdgePair(iPair).Edge3D;
%     Eg2D = EdgePair(iPair).Edge2D;
%     if isempty(Eg3D)||isempty(Eg2D)
%         continue;
%     end
% 
%     branchType1 = FindBranchtype(VesData3D_Proj,Eg3D);
%     branchType2 = FindBranchtype(VesData2D,Eg2D);
% 
% %     [cm, cSq] = DiscreteFrechetDist(branchType1.EdgePoints,branchType2.EdgePoints);
%     
%     [~,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints',1);
%     cm = meanDistance(branchType1.EdgePoints(ix,:),branchType2.EdgePoints(iy,:));
%     
%     cm = cm/length(ix);
%     m2 = m2 + exp(-cm/sigma);
% end
%% penalty
pts = VesData3D_Proj.VesselPoints_Sparse;
disMatrix = Calculate_Distance_Matrix_Euler(pts);
m3 = exp(-mean(disMatrix(:))/sigma);

measure = alpha1*m1+alpha2*m2-m3;

end