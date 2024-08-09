function [GraphData,idxs_s] = processGraphWrap(pts,G,spac,startID)
%% 再此函数里添加生成有向图的方法


% this function envolves several function to process graph data
% downsample, extracting intersection node, extracting branch edge
if nargin == 3
    startID = 0;
end

%% global value used to maintain a list which records point index searched
global g_IdxsFindList;
g_IdxsFindList = [];
G_SUM = sum(G);
%% find branch
if startID == 0
    idx_vertex = find(G_SUM==1);
    idx_start = idx_vertex(1);
    idx_next = find(G(idx_start,:)==1);
else
    idx_start = startID;
    idx_next = find(G(idx_start,:)==1);
end

branches = findNextBranch(idx_start,idx_next,G);

%% downsampe spacing 
branches_sample = {};
for i = 1:size(branches,2)
    branch = branches{i};
    if size(branch,2) < 5
        branches_sample = [branches_sample branch];
    else
        branch_sample = unique_unsorted([branch(1:spac:end) branch(end)]);
        branches_sample = [branches_sample branch_sample];
    end
end
%% generate dense graph and directed graph
idxs_s = [];
for i = 1:size(branches_sample,2)
    idxs_s = [idxs_s branches_sample{i}];
end
idxs_s = unique_unsorted(idxs_s);
VesselPoints = pts(idxs_s,:);



G_temp = zeros(size(G));
% G_temp_di = zeros(size(G));
for i = 1:size(branches_sample,2)
    branch_sample = branches_sample{i};
    for j = 1:size(branch_sample,2)-1
        G_temp(branch_sample(j),branch_sample(j+1)) = 1;
        G_temp(branch_sample(j+1),branch_sample(j)) = 1;
        
%         G_temp_di(branch_sample(j),branch_sample(j+1)) = 1;
    end
end
% G_temp = G_temp + triu(G_temp,1)';
G_dense = G_temp(idxs_s,idxs_s);
% G_dense_di = G_temp_di(idxs_s,idxs_s);
%% node type
nodeType = zeros(1,size(VesselPoints,1));
G_s_SUM = sum(G_dense);
nodeType(G_s_SUM==1) = 1;
nodeType(G_s_SUM==2) = 2;
nodeType(G_s_SUM==3) = 3;

%% generate sparse graph
numofEdges = size(branches_sample,2);
BranchesCell = cell(numofEdges,1);

NodeIdxs = find(G_s_SUM ~= 2);
Graph_Sparse = zeros(max(size(NodeIdxs)));
% Graph_Sparse_Directed = zeros(max(size(NodeIdxs)));
VesselPoints_Sparse = VesselPoints(NodeIdxs,:);
for i = 1:numofEdges
    branch = branches_sample{i};
    EdgePointsIDs = findIDs(branch,idxs_s);
    
    id_s = find(NodeIdxs == EdgePointsIDs(1));
    id_e = find(NodeIdxs == EdgePointsIDs(end));
    Graph_Sparse(id_s,id_e) = 1;Graph_Sparse(id_e,id_s) = 1;
%     Graph_Sparse_Directed(id_s,id_e) = 1;
    
    Branch.IDs = [id_s id_e];
    Branch.EdgePointsIDs = EdgePointsIDs;
    Branch.EdgePoints = VesselPoints(EdgePointsIDs,:);
    BranchesCell{i} = Branch;
end

%% make return data
% GraphData.GraphDir = G_dense_di;
GraphData.Graph = G_dense;
GraphData.NodeType = nodeType;
GraphData.NodeIdxs = NodeIdxs;%findIDs(idxs_inter,idxs_s);
GraphData.VesselPoints = VesselPoints;
GraphData.Graph_Sparse = Graph_Sparse;
% GraphData.Graph_Sparse_Directed = Graph_Sparse_Directed;
GraphData.VesselPoints_Sparse = VesselPoints_Sparse;
GraphData.BranchesCell = BranchesCell;
end

%%
function IDs = findIDs(vals1,vals2)
    n = max(size(vals1));
    IDs = zeros(size(vals1));
    for i = 1:n
        IDs(i) = find(vals2 == vals1(i));
    end
end
%% recursion find branches
function branches = findNextBranch(idx_start,idx_next,G)
global g_IdxsFindList;
sub_branch = [idx_start,idx_next];
idx_s = idx_next;
idx_n = idx_start;
while 1
    idxs_c = find(G(idx_s,:)==1);
    idxs_c(idxs_c==idx_n)=[];
    if size(idxs_c,2) ~= 1
        break;  
    end
    sub_branch = [sub_branch idxs_c];
    idx_n = idx_s;
    idx_s = idxs_c;
end

g_IdxsFindList = [g_IdxsFindList sub_branch];

if isempty(idxs_c)
    branches = {sub_branch};
else
    branches = {};
    for ii = idxs_c
        if isempty(find(g_IdxsFindList == ii, 1))
            branches = [branches findNextBranch(idx_s,ii,G)];
        end
    end
    branches = [sub_branch branches];
end
end