function NodesChild = FilterChildNodes(Nodes,TreeAdjMatrix,id_expand,NodesChild)

idChildInTree = find(TreeAdjMatrix(id_expand,:)==1);

idRet = [];
for ic = 1:length(NodesChild)
    NodeChild = NodesChild(ic);
    bSame = false;
    for id = idChildInTree
       if isSameNode(NodeChild,Nodes(id))
           bSame = true;
           break;
       end
    end
    if ~bSame
        idRet = [idRet,ic];
    end
end
NodesChildRet = [];
for i = idRet
    NodesChildRet = [NodesChildRet,NodesChild(i)];
end
NodesChild = NodesChildRet;

end
function bSameNode = isSameNode(Node1,Node2)

EdgePair1 = Node1.EdgePair;
EdgePair2 = Node2.EdgePair;

if length(EdgePair1) ~= length(EdgePair2)
    bSameNode = false;
    return;
end

bDiff = false;
iEdge = 1;
while iEdge <= length(EdgePair1)
    
    if ~isSameEdge(EdgePair1(iEdge).Edge3D,EdgePair2(iEdge).Edge3D)
        bDiff = true;
        break;
    end
    if ~isSameEdge(EdgePair1(iEdge).Edge2D,EdgePair2(iEdge).Edge2D)
        bDiff = true;
        break;
    end
    iEdge = iEdge + 1;
end
bSameNode = ~bDiff;

end

function bSameEdge = isSameEdge(Edge1,Edge2)
if size(Edge1,1) ~= size(Edge2,1)
    bSameEdge = false;
    return;
end

if isempty(Edge1) || isempty(Edge2)
    bSameEdge = true;
    return;
end

bDiff = false;
iSeg = 1;
while iSeg <= size(Edge1,1)
    if (Edge1(iSeg,1) ~= Edge2(iSeg,1)) || (Edge1(iSeg,2) ~= Edge2(iSeg,2))
        bDiff = true;
        break;
    end
    iSeg = iSeg + 1;
end
bSameEdge = ~bDiff;

end