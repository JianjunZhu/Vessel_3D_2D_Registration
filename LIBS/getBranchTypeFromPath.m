function branchType = getBranchTypeFromPath(VesData,path)

BranchesCell = VesData.BranchesCell;
EdgePoints = [];
EdgePointsIDs = [];
for idEdge = 1:size(path,1);
    Edge = path(idEdge,:);
    branchTypefind = findDirectBranchType(BranchesCell,Edge);
    if idEdge == 1
        EdgePoints = branchTypefind.EdgePoints;
        EdgePointsIDs = branchTypefind.EdgePointsIDs;
    else
        EdgePoints = [EdgePoints;branchTypefind.EdgePoints(2:end,:)];
        EdgePointsIDs = [EdgePointsIDs,branchTypefind.EdgePointsIDs(2:end)];
    end
end
branchType.EdgePoints = EdgePoints;
branchType.EdgePointsIDs = EdgePointsIDs;
branchType.IDs = path;

end
