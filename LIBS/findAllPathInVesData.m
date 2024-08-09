function branchTypes = findAllPathInVesData(VesData,Eg)
global g_Directed;
if g_Directed
    Graph_Sparse = VesData.Graph_Sparse_Directed;
else
    Graph_Sparse = VesData.Graph_Sparse;
end
BranchesCell = VesData.BranchesCell;

Paths = GraphPathTraverseSearch(Graph_Sparse,Eg);
branchTypes = cell(size(Paths));
for id = 1:length(Paths)
    Path = Paths{id};
    EdgePoints = [];
    EdgePointsIDs = [];
    for idEdge = 1:size(Path,1);
        Edge = Path(idEdge,:);
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
    branchType.IDs = Eg;
    
    branchTypes{id} = branchType;
end


end
