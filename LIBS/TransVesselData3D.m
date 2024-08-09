function VesData3D_Trans = TransVesselData3D(VesData3D,T,strPara,varargin)
%% if strPara == 'normal',rotate point via origin points 
%% if strPara == 'central',rotate point via its central

if nargin == 2
    strPara = 'normal';
end

if strcmp(strPara,'central') && numel(varargin) > 0
    centroid = varargin{1};
else
    centroid = mean(VesData3D.VesselPoints,1);
end

R = T(1:3,1:3);
t = T(1:3,4)';

if strcmp(strPara,'normal')
%     VesselPoints_trans = (T*cart2homo(VesData3D.VesselPoints'))';
    VesselPoints_trans = add2AllMat(VesData3D.VesselPoints*R',t);
elseif strcmp(strPara,'central')
%     VesselPoints_trans = TransformPointSet(VesData3D.VesselPoints,R,t);
    Points_Mean = centroid;
    VesselPoints_trans = add2AllMat(add2AllMat(VesData3D.VesselPoints,-Points_Mean)*R',+ t + Points_Mean);
end

VesData3D_Trans = UpdateVesselPoints(VesData3D,VesselPoints_trans);

% % Display_Graph(VesselPoints_trans',VesData3D.Graph);
% 
% VesselPoints_Sparse_Trans = VesselPoints_trans(VesData3D.NodeIdxs,:);
% VesData3D_Trans.VesselPoints_Sparse = VesselPoints_Sparse_Trans;
% 
% for i = 1:max(size(VesData3D.BranchesCell))
%     EdgePointsIDs = VesData3D_Trans.BranchesCell{i}.EdgePointsIDs;
%     VesData3D_Trans.BranchesCell{i}.EdgePoints = VesselPoints_trans(EdgePointsIDs,:);
% end

end

% function PointsTrans = TransformPointSet(Points,R,t)
%     Points_Mean = mean(Points,1);
%     PointsTrans = add2AllMat(add2AllMat(Points,-Points_Mean)*R',+ t + Points_Mean);
% end