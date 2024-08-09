function Nodes = UpdateNodeNvisit(Nodes,TreeAdjMatrix,id)

idTemp = id;
Nodes(idTemp).Nvisit = Nodes(idTemp).Nvisit + 1;
while 1
    id_parent = find(TreeAdjMatrix(:,idTemp)==1);
    if isempty(id_parent)
        break;
    end
    Nodes(id_parent).Nvisit = Nodes(id_parent).Nvisit + 1;
    idTemp = id_parent;
end