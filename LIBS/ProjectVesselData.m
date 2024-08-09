function VesData2D = ProjectVesselData(VesData3D,K)
    projMatrix = K*eye(3,4);
    [VesselPoints2D,~] = projectPointsByProjectMatrix(cart2homo(VesData3D.VesselPoints'),projMatrix);
    [VesselPoints_Sparse2D,~] = projectPointsByProjectMatrix(cart2homo(VesData3D.VesselPoints_Sparse'),projMatrix);

    branchesCell3D = VesData3D.BranchesCell;
    numBranch = max(size(branchesCell3D));
    branchesCell2D = cell(size(branchesCell3D));
    
    for i = 1:numBranch
        branchType3D = branchesCell3D{i};
        branchType2D.EdgePointsIDs = branchType3D.EdgePointsIDs;

        branchType2D.IDs = branchType3D.IDs;
        pts = branchType3D.EdgePoints;
        branchType2D.EdgePoints = projectPointsByProjectMatrix(cart2homo(pts'),projMatrix);
        
        branchesCell2D{i} = branchType2D;
    end
    %% write to VesData2D
    VesData2D.VesselPoints = VesselPoints2D;
    VesData2D.VesselPoints_Sparse = VesselPoints_Sparse2D;
    VesData2D.BranchesCell = branchesCell2D;
    VesData2D.VesselRadius =VesData3D.VesselRadius;
    VesData2D.NodeIdxs = VesData3D.NodeIdxs;
    VesData2D.K = K;
    VesData2D.Graph = VesData3D.Graph;
    VesData2D.Graph_Directed = VesData3D.Graph_Directed;
    VesData2D.Graph_Sparse = VesData3D.Graph_Sparse;
    VesData2D.Graph_Sparse_Directed = VesData3D.Graph_Sparse_Directed;
    VesData2D.VesselRadius = VesData3D.VesselRadius;
end