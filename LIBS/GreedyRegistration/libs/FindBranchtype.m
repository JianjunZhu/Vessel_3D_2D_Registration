%% FindBranchtype
function branchType = FindBranchtype(VesData,Eg)

if size(Eg,1) == 1
    branchType = findDirectBranchType(VesData.BranchesCell,Eg);
else
    Path = Eg;
    EdgePoints = [];
    EdgePointsIDs = [];
    for idEdge = 1:size(Path,1);
        Edge = Path(idEdge,:);
        branchTypefind = findDirectBranchType(VesData.BranchesCell,Edge);
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
    branchType.IDs = Eg;
end

end