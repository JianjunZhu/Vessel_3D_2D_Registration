function [VesData3DReg,CorrSparse,CorrDense,NodeFine] = MonteCarloTreeSearchRegistration(config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;

%% root node
startIDPair = [1, 1];
Nodes = CreatNodeStruct(config.type);
Nodes(1).PairSparse = startIDPair; Nodes(1).level = 0; Nodes(1).Expandable = 1; 
Nodes(1).QUrgency = 0; Nodes(1).Nvisit = 0; Nodes(1).QSim = 0; Nodes(1).Measure = -1e10;
TreeAdjMatrix = 0;
%% setting
config.NodesTraverseOrders = BFSVesData(VesData3D,startIDPair(1));
iter = 1;
LeafNodeIdxs = 1; 
while iter < config.maxIteration;
    %% disp
%     disp(['iter = ', num2str(iter)]);
    if Nodes(1).Expandable == 0 && Nodes(1).ExpandCurrent == 0
        break;
    end
    
    if iter <= config.MaxExpandLevel 
        LeafNodeIdxsTemp = [];
        for leaf = LeafNodeIdxs
            [Nodes,TreeAdjMatrix,idExpand] = MCTS_Procedure(Nodes,TreeAdjMatrix,leaf,config,iter);
            LeafNodeIdxsTemp = [LeafNodeIdxsTemp,idExpand];
        end
        LeafNodeIdxs = LeafNodeIdxsTemp;
    else
        %% selection
        id_selected = selectionExpandedNode(Nodes,TreeAdjMatrix);
        %% Expansion & Simulation & Backpropagation
        [Nodes,TreeAdjMatrix,~] = MCTS_Procedure(Nodes,TreeAdjMatrix,id_selected,config,iter);
    end
    %%
    iter = iter + 1;
end
[~,indexTemp] = sort([Nodes.Measure]); 
NodeFine = Nodes(indexTemp(end));
VesData3DReg = NodeFine.Trans;
CorrSparse = NodeFine.PairSparse; CorrDense = NodeFine.PairDense;

end

function [Nodes,TreeAdjMatrix,idExpand] = MCTS_Procedure(Nodes,TreeAdjMatrix,id_selected,config,iter)

%% Expansion
NodesChild = FindChildNodesWrap(Nodes(id_selected),config);

NodesChild = NodeInitialDefaultSetting(NodesChild,1);

NodesChild = FilterChildNodes(Nodes,TreeAdjMatrix,id_selected,NodesChild);

NodesChild = AssignDensePairs(NodesChild,Nodes(id_selected),config);

NodesChild = EsitmateNodesMeaure(NodesChild,config);

if isempty(NodesChild)
    idExpand = [];
    return;
end

if iter > config.MaxExpandLevel
    if length(NodesChild) > config.NExpand  
        Measures = [NodesChild.Measure];
        [~,I] = sort(Measures,'descend');
        idBest = I(1:config.NExpand);
        NodesChild = NodesChild(idBest);
        Nodes(id_selected).ExpandCurrent = 1;
    else
        Nodes(id_selected).ExpandCurrent = 0;
    end
else
    if length(NodesChild) > config.NChild  
        Measures = [NodesChild.Measure];
        [~,I] = sort(Measures,'descend');
        idBest = I(1:config.NChild);
        NodesChild = NodesChild(idBest);
        Nodes(id_selected).ExpandCurrent = 1;
    else
        Nodes(id_selected).ExpandCurrent = 0;
    end
end


idExpand = length(Nodes)+1:length(Nodes)+length(NodesChild);
TreeAdjMatrixTemp = zeros(idExpand(end));
TreeAdjMatrixTemp(1:length(Nodes),1:length(Nodes)) = TreeAdjMatrix;
TreeAdjMatrixTemp(id_selected,idExpand) = 1;
Nodes = [Nodes,NodesChild];
TreeAdjMatrix = TreeAdjMatrixTemp;
 %% Simulation & Backpropagation
for id = idExpand
    QSim = NodeSimulation(Nodes(id),config);
    if isempty(FindChildNodesWrap(Nodes(id),config))
        Nodes(id).ExpandCurrent = 0;
    else
        Nodes(id).ExpandCurrent = 1;
    end
    Nodes = BackPropagationMCT(Nodes,id,TreeAdjMatrix,QSim);
end

Nodes = UpdateNodeExpandable(Nodes,TreeAdjMatrix);
Nodes = UpdateNodeNvisit(Nodes,TreeAdjMatrix,id_selected);
Nodes = UpdateNodeQUrgency(Nodes,config,iter);
end



