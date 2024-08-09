function [VesData3DReg,CorrSparse,CorrDense] = HeuristicRegistration(config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
%% root node
startIDPair = [1, 1];
Nodes = CreatNodeStruct;
Nodes(1).PairSparse = startIDPair; Nodes(1).level = 0;
%% Breadth-First-Search 3D nodes
config.NodesTraverseOrders = BFSVesData(VesData3D,startIDPair(1));
%%
config.AssignStrategy = 'uniform';
config.FilterStrategy = 'heuristic';
NodesQueueOpen(1) = Nodes;
NodesQueueClose = [];
while 1
    %% disp
%     disp(['Counts of NodesQueue = ', num2str(length(NodesQueue))]);
    %% pop
    NodeLeaf = NodesQueueOpen(1);
    NodesQueueClose = [NodesQueueOpen(1),NodesQueueClose];
    NodesQueueOpen(1) = [];
    %%
    NodesChild = FindChildNodes(NodeLeaf,config);
    
    NodesChild = AssignDensePairs(NodesChild,NodeLeaf,config);
    NodesChild = EsitmateNodesMeaure(NodesChild,config);
    
    NodesQueueOpen = [NodesChild,NodesQueueOpen];
    if ~isempty(NodesQueueOpen)
        [~,indexTemp] = sortrows([NodesQueueOpen.Measure].'); 
        NodesQueueOpen = NodesQueueOpen(indexTemp(end:-1:1)); clear indexTemp;
    else
        break;
    end
    if length(NodesQueueClose) > 300 % NodesQueueOpen(1).level == length(config.NodesTraverseOrders) || 
        break;
    end
end

[~,indexTemp] = sortrows([NodesQueueClose.Measure].'); 
NodeFine = NodesQueueClose(indexTemp(end));
VesData3DReg = NodeFine.Trans;
CorrSparse = NodeFine.PairSparse; CorrDense = NodeFine.PairDense;

end
