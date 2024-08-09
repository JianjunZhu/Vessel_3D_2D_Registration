function VesData3DNew = UpdateVesselPoints(VesData3D,vesselPts)
%% Update 'vesselPts' in 'VesData' Data to Get 'VesData3DNew'
    VesData3DNew = VesData3D;
    VesData3DNew.VesselPoints = vesselPts;
    VesData3DNew.VesselPoints_Sparse = vesselPts(VesData3D.NodeIdxs(:),:);
    
    BranchesCellNew = cell(size(VesData3DNew.BranchesCell));
    for i = 1:size(VesData3DNew.BranchesCell,1)
        Branch = VesData3DNew.BranchesCell{i};
        Branch.EdgePoints = vesselPts(Branch.EdgePointsIDs(:),:);
        BranchesCellNew{i} = Branch;
    end
    VesData3DNew.BranchesCell = BranchesCellNew;
    
    if isfield(VesData3D,'PriorModel')
        VesData3DNew.quaternionPara = GetQuaternionPts1ToPts2(VesData3D.PriorModel.VesselDataRef.VesselPoints,VesData3DNew.VesselPoints);
    end
    
end