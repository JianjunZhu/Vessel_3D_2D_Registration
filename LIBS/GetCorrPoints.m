function [pts3d,pts2d,Cor_Dense_Refine] = GetCorrPoints(Cor_Dense,Cor_Sparse,VesData3D,VesData2D)
%% A simple way to unique correspondence, do not consider the selection of multi-correspondence
% 
% pts3d = VesData3D.VesselPoints;
% pts2d = VesData2D.VesselPoints;
% K = VesData2D.K; projMatrix = K*eye(3,4);

% [pts3d_p,~] = projectPointsByProjectMatrix(cart2homo(pts3d'),projMatrix);
% [ixu,iyu] = uniqueCorr(Cor_Dense(:,1),Cor_Dense(:,2),pts3d_p,pts2d);
% Cor_Dense_Refine = [ixu,iyu];

[~,ia,~] = unique(Cor_Dense(:,1));
ia = sort(ia);
Cor_Refine = Cor_Dense(ia,:);

Cor_Dense_Refine = Cor_Refine;

ixu = Cor_Refine(:,1);
iyu = Cor_Refine(:,2);

pts3d = VesData3D.VesselPoints(ixu,:);
pts2d = VesData2D.VesselPoints(iyu,:);

if ~isempty(Cor_Sparse)
    pts3d_s = VesData3D.VesselPoints_Sparse(Cor_Sparse(:,1),:);
    pts2d_s = VesData2D.VesselPoints_Sparse(Cor_Sparse(:,2),:);
    pts3d = [pts3d;repmat(pts3d_s,10,1)];
    pts2d = [pts2d;repmat(pts2d_s,10,1)];
end

