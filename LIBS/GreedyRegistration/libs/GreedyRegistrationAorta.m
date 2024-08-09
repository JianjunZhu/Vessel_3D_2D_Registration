function [VesData3DReg,CorrSparse,CorrDense,Nodes] = GreedyRegistrationAorta(config)
%% version for aorta
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
%% root node
startIDPair = config.startIDPair;
Nodes = CreatNodeStruct;
Nodes(1).PairSparse = startIDPair; Nodes(1).level = 0;
LeafNodeIdxs = 1;
%%
config.AssignStrategy = 'uniform';
config.FilterStrategy = 'custom';
GreedyIndexs = [];
GreedyCounts = config.greedycounts;
greedyLevel = config.greedyLevel;
level = 1;

scoreLast = 0;

while 1
    LeafNodeIdxsTemp = [];
    disp(['---- level :', num2str(level,'%02d'),' ---- Counts of leaf nodes : ', num2str(length(LeafNodeIdxs))]);
    for leaf = LeafNodeIdxs
        NodesChild = FindChildNodesAorta(Nodes(leaf),config);
        NodesChild = AssignDensePairs(NodesChild,Nodes(leaf),config);
        NodesChild = EsitmateNodesMeaure(NodesChild,config);
        countAdd = length(NodesChild);
        
        if countAdd > 1
            if countAdd > GreedyCounts
                NodesChild = GreedyFilterNodes(NodesChild,GreedyCounts,config);
                countAdd = length(NodesChild);
            end
            Nodes = [Nodes,NodesChild];
            LeafNodeIdxsTemp = [LeafNodeIdxsTemp,length(Nodes)-length(NodesChild)+1:length(Nodes)];
        elseif countAdd == 1 % 合并当前子节点
            NodesChild.level = NodesChild.level-1;
            Nodes(leaf) = NodesChild;
            LeafNodeIdxsTemp = [LeafNodeIdxsTemp,leaf];
        end
    end
    if isempty(LeafNodeIdxsTemp)
        break;
    end
    if level >= greedyLevel
        [NodesChildRet, idBest] = GreedyFilterNodes(Nodes(LeafNodeIdxsTemp),1,config);
        scoreNow = NodesChildRet.Measure;
        if scoreNow < scoreLast
            break;
        end
        scoreLast = scoreNow;
        GreedyIndexs = [GreedyIndexs, LeafNodeIdxsTemp(idBest)];
        LeafNodeIdxsTemp = LeafNodeIdxsTemp(idBest);
    end
    LeafNodeIdxs = LeafNodeIdxsTemp;
    level = level + 1;
end
%%
NodeFinal = Nodes(LeafNodeIdxs);
VesData3DReg = NodeFinal.Trans;
CorrSparse = NodeFinal.PairSparse;
CorrDense = NodeFinal.PairDense;
%% Refine
VesData3DRegRefine = MyRefinement(VesData3DReg,VesData2D,0,{'ORGMM'});
distReg = dist_knn(ProjectVesselData(VesData3DReg,VesData2D.K),VesData2D,config.scale);
distRefine = dist_knn(ProjectVesselData(VesData3DRegRefine,VesData2D.K),VesData2D,config.scale);
if distReg > distRefine
    VesData3DReg = VesData3DRegRefine;
end
VesData3DReg = DT_3D2DReg(VesData3DReg,VesData2D,0);
end
