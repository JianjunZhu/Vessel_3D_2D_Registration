function [VesData3DReg,CorrSparse,CorrDense] = HeuristicRegistrationAorta(config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
%% root node
startIDPair = config.startIDPair;
Nodes = CreatNodeStruct;
Nodes(1).PairSparse = startIDPair; Nodes(1).level = 0; Nodes(1).Measure = 0;

%%
config.AssignStrategy = 'uniform';
config.FilterStrategy = 'heuristic';
NodesQueueOpen(1) = Nodes;
NodesQueueClose = []; iterCounts = 0;
while 1
    %% disp
%     disp(['Counts of NodesQueue = ', num2str(length(NodesQueue))]);
    %% pop
    NodeLeaf = NodesQueueOpen(1);
    NodesQueueClose = [NodesQueueOpen(1),NodesQueueClose]; iterCounts = iterCounts + 1;
    NodesQueueOpen(1) = [];
    %%
    NodesChild = FindChildNodesAorta(NodeLeaf,config);
    
    NodesChild = AssignDensePairs(NodesChild,NodeLeaf,config);
    NodesChild = EsitmateNodesMeaure(NodesChild,config);
    
    NodesQueueOpen = [NodesChild,NodesQueueOpen];
    if ~isempty(NodesQueueOpen)
        [~,indexTemp] = sortrows([NodesQueueOpen.Measure].'); 
        NodesQueueOpen = NodesQueueOpen(indexTemp(end:-1:1)); clear indexTemp;
    else
        break;
    end
    
    if ~isempty(NodesQueueClose)
        [~,indexTemp] = sortrows([NodesQueueClose.Measure].'); 
        NodesQueueClose = NodesQueueClose(indexTemp(end));
    end
    
    if  iterCounts > 500 %length(NodesQueueClose) > 500 % NodesQueueOpen(1).level == length(config.NodesTraverseOrders) || 
        break;
    end
end

[~,indexTemp] = sortrows([NodesQueueClose.Measure].'); 
NodeFine = NodesQueueClose(indexTemp(end));
VesData3DReg = NodeFine.Trans;
CorrSparse = NodeFine.PairSparse; CorrDense = NodeFine.PairDense;

%% Refine
VesData3DRegRefine = MyRefinement(VesData3DReg,VesData2D,0,{'ORGMM'});
distReg = dist_knn(ProjectVesselData(VesData3DReg,VesData2D.K),VesData2D,config.scale);
distRefine = dist_knn(ProjectVesselData(VesData3DRegRefine,VesData2D.K),VesData2D,config.scale);
if distReg > distRefine
    VesData3DReg = VesData3DRegRefine;
end
VesData3DReg = DT_3D2DReg(VesData3DReg,VesData2D,0);
end
