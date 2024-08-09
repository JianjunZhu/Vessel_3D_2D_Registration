function NodesChild = FindChildNodesAorta(NodeParent,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;

ParentVertexPair = NodeParent.PairSparse;
ParentEdgePair = NodeParent.EdgePair;
% NodesChild = CreatNodeStruct;
NodesChild = CreatNodeStruct(config.type);
id = 1;

if isempty(ParentEdgePair)
    Edge3DCell = {};Edge2DCell = {};
else
    Edge3DCell = {ParentEdgePair.Edge3D};
    Edge2DCell = {ParentEdgePair.Edge2D};
end

Edges3D = findExpandEdges(VesData3D,Edge3DCell,ParentVertexPair(:,1),config.redundant-1);
Edges2D = findExpandEdges(VesData2D,Edge2DCell,ParentVertexPair(:,2),config.redundant);

n3D = numel(Edges3D); n2D = numel(Edges2D);


for i = 1:n3D
    Eg3D = Edges3D{i};
    for j = 1:n2D
        Eg2D = Edges2D{j};
        % 需要判断 Eg3D(1,1) 和 Eg2D(1,1) 是不是匹配的
        if ~isempty(find(ismember(ParentVertexPair,[Eg3D(1,1),Eg2D(1,1)],'rows'))==1)
            NodesChild(id).PairSparse = [ParentVertexPair;Eg3D(end,2),Eg2D(end,2)];
            NodesChild(id).level = NodeParent.level + 1;
            NodesChild(id).EdgePair = [ParentEdgePair,struct('Edge3D',Eg3D,'Edge2D',Eg2D)];
            id = id + 1;
        end
    end
end


end

function EdgesFound = findExpandEdges(VesData,Edges,Vertices,redun)
Graph = VesData.Graph_Sparse;
EdgesFound = {};
for v = Vertices'
    [nodes, paths] = getOverConnectNode(Graph,v,redun);
    for i = 1:length(nodes)
        if isFeasibleForMatching(nodes(i), paths{i}, Edges)
            EdgesFound = [EdgesFound, paths{i}];
        end
    end
end
    
end

function isFeasible = isFeasibleForMatching(node, path, Edges)
%% 目前仅考虑是节点是否共用的问题
vertices = [];
for i = 1:numel(Edges)
    vertices = [vertices,Edges{i}(1,1),Edges{i}(end,2)];
end
isFeasible = isempty(find(vertices==node, 1));

end