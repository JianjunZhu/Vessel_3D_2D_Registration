function [VesData3DReg,CorrSparse,CorrDense,Nodes] = GreedyRegistration(config)
%% define searching node
% Node = {PairSparse, PairDense, Trans, Measure};
% Searching Tree, adjacent matrix TreeAdjMatrix, if TreeAdjMatrix(i,j) =
% 1,i is the parent node of j
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
% PlotSparseVesselGraph(VesData3D);
% PlotSparseVesselGraph(VesData2D);
%% root node
startIDPair = [1, 1];
% startIDPair = config.startIDPair;
% recompute the directed graph using startIDPair
% diG = GenerateDirectedGraph(VesData3D.Graph_Sparse,startIDPair(1));
% VesData3D.Graph_Sparse_Directed = diG;
% config.VesData3D = VesData3D;
%%
Nodes = CreatNodeStruct;
Nodes(1).PairSparse = startIDPair; Nodes(1).level = 0;
TreeAdjMatrix = 0;
LeafNodeIdxs = 1;
%% Breadth-First-Search 3D nodes
config.NodesTraverseOrders = BFSVesData(VesData3D,startIDPair(1));
greedyLevel = config.greedyLevel;
%%
config.FilterStrategy = 'custom';
GreedyIndexs = [];
GreedyCounts = config.greedycounts;
%% add nodes
level = 1;
while 1
    LeafNodeIdxsTemp = [];
    disp(['---- level :', num2str(level,'%02d'),' ---- Counts of leaf nodes : ', num2str(length(LeafNodeIdxs))]);
    for leaf = LeafNodeIdxs
        NodesChild = FindChildNodes(Nodes(leaf),config);
        if level >= greedyLevel
            config.AssignStrategy = 'uniform';%projected
        else
            config.AssignStrategy = 'uniform';
        end
        NodesChild = SetNodesAttribute(NodesChild,Nodes(leaf),config);
        countAdd = length(NodesChild);
        if countAdd > 1
            
            if countAdd > GreedyCounts
                NodesChild = GreedyFilterNodes(NodesChild,GreedyCounts,config);
                countAdd = length(NodesChild);
            end
            
            TreeAdjMatrixNew = zeros(countAdd+length(Nodes));
            TreeAdjMatrixNew(1:length(Nodes),1:length(Nodes)) = TreeAdjMatrix;
            TreeAdjMatrixNew(leaf,1+length(Nodes):countAdd+length(Nodes)) = 1;
            TreeAdjMatrix = TreeAdjMatrixNew;
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
    %%
    if level >= greedyLevel
        [NodesChildRet, idBest] = GreedyFilterNodes(Nodes(LeafNodeIdxsTemp),1,config);
        GreedyIndexs = [GreedyIndexs, LeafNodeIdxsTemp(idBest)];
        
        LeafNodeIdxsTemp = LeafNodeIdxsTemp(idBest);
%         Nodes(LeafNodeIdxsTemp) = NodesChildRet;

        %% Display
%         disp(LeafNodeIdxsTemp);
%         VesData3D_Trans = Nodes(LeafNodeIdxsTemp).Trans;
%         CorrSparse = Nodes(LeafNodeIdxsTemp).PairSparse;
%         CorrDense = Nodes(LeafNodeIdxsTemp).PairDense;
%         Display3DA2DVesselData(VesData3D_Trans,VesData2D.K,VesData2D);
%         Display3DA2DVesselData(VesData3D_Trans,VesData2D.K,VesData2D,'SparseCorr',CorrSparse,'Label',1);
%         SavePath = [pwd,'\',num2str(LeafNodeIdxsTemp,'%02d'),'.png'];
%         Display3DA2DVesselDataMatching(VesData3D,VesData2D.K,VesData2D,'SparseCorr',CorrSparse,'Label',1,'SavePath',SavePath);
%         Display3DA2DVesselData(VesData3D_Trans,VesData2D.K,VesData2D,'DenseCorr',CorrDense);
    end
    LeafNodeIdxs = LeafNodeIdxsTemp;
    level = level + 1;
end
%% 画图显示分数

Scores = zeros(size(GreedyIndexs));
for ind = 1:length(GreedyIndexs)
    Scores(ind) = Nodes(GreedyIndexs(ind)).Measure;
end
disp(Scores);
% figure,plot(Scores);
%% display search graph
% [s, t] = find(TreeAdjMatrix==1);
% G = digraph(s,t);
% figure,plot(G);drawnow;title('Search graph');
%%
NodeFinal = Nodes(LeafNodeIdxs);
VesData3DReg = Nodes(LeafNodeIdxs).Trans;
CorrSparse = Nodes(LeafNodeIdxs).PairSparse;
CorrDense = Nodes(LeafNodeIdxs).PairDense;

end

%% SetNodesAttribute
function NodesChild = SetNodesAttribute(NodesChild,NodeLeaf,config)
    NodesChild = AssignDensePairs(NodesChild,NodeLeaf,config);
    NodesChild = EsitmateNodesMeaure(NodesChild,config);
end



