function branchType = findDirectBranchType(BranchesCell,Eg)
    branchType = [];
    for i = 1:numel(BranchesCell)
        branchType_i = BranchesCell{i};
        Eg_i = branchType_i.IDs;
        if (Eg(1)==Eg_i(1)) && (Eg(2)==Eg_i(2))
            branchType = branchType_i;
            return;
        elseif (Eg(1)==Eg_i(2)) && (Eg(2)==Eg_i(1))
            branchType.IDs = flip(branchType_i.IDs);
            branchType.EdgePoints = flip(branchType_i.EdgePoints);
            branchType.EdgePointsIDs = flip(branchType_i.EdgePointsIDs);
            return;
        end
    end
    disp('empty find \n');
end