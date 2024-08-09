%% FindChildNodes
function NodesChild = FindChildNodes(NodeParent,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;

NodesTraverseOrders = config.NodesTraverseOrders;
ParentPair = NodeParent.PairSparse;
NodesChild = CreatNodeStruct(config.type);

if NodesTraverseOrders(end) == ParentPair(end,1)
%     disp('Paring finished');
    return;
end

IdxFound3D = NodesTraverseOrders(find(NodesTraverseOrders==ParentPair(end,1)) + 1);

IdxParent3D = find(VesData3D.Graph_Sparse_Directed(:,IdxFound3D)==1);

IdxParent2D = ParentPair(ParentPair(:,1)==IdxParent3D,2);
% IdxsFound2D = FindVesselNodeDirected(VesData2D.Graph_Sparse_Directed,IdxParent2D,config.redundant);

[IdxsFound2D,EdgesFound] = getOverConnectNode(VesData2D.Graph_Sparse,IdxParent2D,config.redundant); % Graph_Sparse_Directed
[IdxsFound2D,EdgesFound] = RemoveElements(IdxsFound2D,EdgesFound,ParentPair(:,2)');

assert(length(IdxFound3D)==1);
if isempty(IdxsFound2D)
%     disp('Not found 2D node');
    return;
end

for i = 1:length(IdxsFound2D)
    NodesChild(i).PairSparse = [ParentPair;IdxFound3D,IdxsFound2D(i)];
    NodesChild(i).level = NodeParent.level + 1;
    NodesChild(i).EdgePair = [NodeParent.EdgePair,struct('Edge3D',[IdxParent3D,IdxFound3D],'Edge2D',EdgesFound{i})];
    
    if strcmp(config.type,'MCT')
        NodesChild(i).Nvisit = 0;
    end
    
end

% add a null edge for 'Edge3D',[IdxParent3D,IdxFound3D], only if IdxFound3D
% is a end node of graph
if isempty(find(VesData3D.Graph_Sparse_Directed(IdxFound3D,:)==1, 1))
    id = length(NodesChild) + 1;
    NodesChild(id).PairSparse = [ParentPair;IdxFound3D,0];
    NodesChild(id).level = NodeParent.level + 1;
    NodesChild(id).EdgePair = [NodeParent.EdgePair,struct('Edge3D',[IdxParent3D,IdxFound3D],'Edge2D',[])];
end

end




%% RemoveElements
function [IdxsRet, EdgesRet] = RemoveElements(Idxs,Edges,NotList)
IdxsRet = [];
EdgesRet = {};

allInds = 1:length(Idxs);
for i = 1: length(Idxs)
    Edge = Edges{i};
    EdgesNodes = unique_unsorted(Edge(:))';
    [~, ind] = ismember(EdgesNodes(2:end), NotList);
    if ~isempty(find(ind>0, 1))
        allInds(allInds==i) = [];
    end
end

for i = allInds
    IdxsRet = [IdxsRet, Idxs(i)];
    EdgesRet = [EdgesRet, Edges{i}];
end

end