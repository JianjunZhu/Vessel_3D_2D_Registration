function Nodes = UpdateNodeExpandable(Nodes,TreeAdjMatrix)
global g_Nodes;
g_Nodes = Nodes;
GetChildTreeExpandable(TreeAdjMatrix,1);
Nodes = g_Nodes;

end


function Expandable = GetChildTreeExpandable(TreeAdjMatrix,iNode)
global g_Nodes;

idChild = find(TreeAdjMatrix(iNode,:)==1);
Expandable = 0;
if ~isempty(idChild)
    for ic = idChild
        Expandable = Expandable| g_Nodes(ic).ExpandCurrent | GetChildTreeExpandable(TreeAdjMatrix,ic);
    end
end
g_Nodes(iNode).Expandable = Expandable;

end