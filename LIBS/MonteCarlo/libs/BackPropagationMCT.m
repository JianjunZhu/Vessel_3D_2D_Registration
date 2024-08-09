function Nodes = BackPropagationMCT(Nodes,id,TreeAdjMatrix,QSim)
Nodes(id).QSim = QSim;
idTemp = id;
while 1
    id_parent = find(TreeAdjMatrix(:,idTemp)==1);
    if isempty(id_parent)
        break;
    end
    if QSim > Nodes(id_parent).QSim
        Nodes(id_parent).QSim = QSim;
    end
    idTemp = id_parent;
end

