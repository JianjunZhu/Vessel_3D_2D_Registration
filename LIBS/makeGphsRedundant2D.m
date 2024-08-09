function gph2d = makeGphsRedundant2D(VesData,bDirected,redundant)
pts2D_Sparse = VesData.VesselPoints_Sparse;

if bDirected
    Graph_Sparse = VesData.Graph_Sparse_Directed;
else
    Graph_Sparse = VesData.Graph_Sparse;
end
[GraphRedun, Paths] = makeRedundantGraph(Graph_Sparse,redundant);

numOfEdges = length(Paths);
Eg = zeros(2,numOfEdges);
for i = 1:length(Paths)
    path = Paths{i};
    Eg(:,i) = [path(1,1);path(end,2)];
end
Branch = cell(1,numOfEdges);
BranchIdx = cell(1,numOfEdges);
BranchMeanRadius = zeros(1,numOfEdges);

for i = 1:numOfEdges
    path = Paths{i};
    if size(path,1)==1 && Graph_Sparse(path(1),path(2))==1
        branchType = findDirectBranchType(VesData.BranchesCell,path);
    else
        branchType = getBranchTypeFromPath(VesData,path);
    end
   
    Branch{i} = branchType.EdgePoints;
    BranchIdx{i} = branchType.EdgePointsIDs';
    BranchMeanRadius(i) = mean(VesData.VesselRadius(BranchIdx{i}));
end

n = max(size(pts2D_Sparse));
[G, H] = gphEg2IncA_zjj(Eg, n);

gph2d.BranchMeanRadius = BranchMeanRadius;
gph2d.NodeType = sum(VesData.Graph_Sparse,1);
gph2d.Radius = VesData.VesselRadius(VesData.NodeIdxs);
gph2d.Pt = pts2D_Sparse';
gph2d.Eg = Eg;
gph2d.Branch = Branch;
gph2d.BranchIdx = BranchIdx;
gph2d.G = G;
gph2d.H = H;
gph2d.Paths = Paths;
gph2d.GraphRedun = GraphRedun;
end