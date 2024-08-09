function Cor_Dense = fineGraphMatch(VesData1,VesData2,Cor_Sparse,Parameters)
%% parse varargin
bUniqure = 0; bDirected = 0;
for i = 1:numel(Parameters)
    switch Parameters{i}
        case 'Directed'
            bDirected = 1;
        case 'Unique'
            bUniqure = 1;
    end
end


Cor_Dense = [];
% Proj = VesData2.K*[eye(3),zeros(3,1)];
%% for each edge in 3d, find a correspondence
if bDirected
    Graph_Sparse = VesData2.Graph_Sparse_Directed;
else
    Graph_Sparse = VesData2.Graph_Sparse;
end
for i = 1:size(VesData1.BranchesCell,1)
    branchType1 = VesData1.BranchesCell{i};
    Eg_i = branchType1.IDs;
    Eg_cor = [Cor_Sparse(Cor_Sparse(:,1)==Eg_i(1),2), ...
        Cor_Sparse(Cor_Sparse(:,1)==Eg_i(2),2)];
    if (size(Eg_cor,2)~=2) || isempty(Eg_cor)
        continue;
    end
    if Graph_Sparse(Eg_cor(1),Eg_cor(2))==1
        branchType2 = findDirectBranchType(VesData2.BranchesCell,Eg_cor);
    else
%         branchType2 = findPathInVesData(VesData2,Eg_cor);
        if bDirected
            branchType_all = findAllPathInVesData_Directed(VesData2,Eg_cor);
        else
            branchType_all = findAllPathInVesData(VesData2,Eg_cor);
        end
        branchType2 = BestCandidate(branchType1,branchType_all);
    end
    %% 
    if isempty(branchType2)
        continue;
    end
    if size(branchType1.EdgePoints,1) < 2
        continue;
    end
    if size(branchType2.EdgePoints,1) < 2
        continue;
    end
    %% dtw
%     pts_p = projectPointsByProjectMatrix(cart2homo(branchType1.EdgePoints'),Proj);

    [cm,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints',2);
%     if max(size(branchType1.EdgePoints)) <= max(size(branchType2.EdgePoints))
%         [cm,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints',1);
%     else
%         [cm,iy,ix] = dtw(branchType2.EdgePoints',branchType1.EdgePoints',1);
%     end
    
%     [cm, cSq] = DiscreteFrechetDist(branchType1.EdgePoints,branchType2.EdgePoints);
%     ix = cSq(:,1);iy = cSq(:,2);
%     
    if bUniqure == 1
        [ixu,iyu] = uniqueCorr(ix,iy,branchType1.EdgePoints,branchType2.EdgePoints);
    else
        ixu = ix; iyu = iy;
    end
    Cor_Dense = [Cor_Dense;branchType1.EdgePointsIDs(ixu)',branchType2.EdgePointsIDs(iyu)'];

end

if bUniqure == 1 && ~isempty(Cor_Dense)
    [CorrU1,ia,~] = unique(Cor_Dense(:,1));
    CorrU2 = Cor_Dense(ia,2);
    Cor_Dense = [CorrU1,CorrU2];
end

end

function branchType = findPathInVesData(VesData,Eg)
    Graph_Sparse = VesData.Graph_Sparse;
    BranchesCell = VesData.BranchesCell;
    
    [Path, bFind] = GraphPathSearch(Graph_Sparse,Eg);
    if bFind == 0
        branchType = [];
        return;
    end
    
    EdgePoints = [];
    EdgePointsIDs = [];
    for i = 1:size(Path,1);
        Edge = Path(i,:);
        branchTypefind = findDirectBranchType(BranchesCell,Edge);
        if i == 1
            EdgePoints = branchTypefind.EdgePoints;
            EdgePointsIDs = branchTypefind.EdgePointsIDs;
        else
            EdgePoints = [EdgePoints;branchTypefind.EdgePoints(2:end,:)];
            EdgePointsIDs = [EdgePointsIDs,branchTypefind.EdgePointsIDs(2:end)];
        end
    end
    branchType.EdgePoints = EdgePoints;
    branchType.EdgePointsIDs = EdgePointsIDs;
    branchType.IDs = Eg;
end

function [Path,bFind] = GraphPathSearch(G,Eg)
% depth-first search
global g_Path;
g_Path = [];

idxs_c = find(G(Eg(1),:)==1);
for i = idxs_c
   [Path,bFind] = findNextNode(G,Eg(1),i,Eg(2));
   if bFind == 1
       break;
   end
end

end

function [Path,bFind] = findNextNode(G,id_last,id_now,id_tar)
global g_Path;
Path = [id_last,id_now];

ids_c = find(G(id_now,:)==1);
ids_c(ids_c==id_last) = [];

if isempty(ids_c);
    Path = [];
    bFind = 0;
else
    for i = ids_c;
        if i == id_tar
            bFind = 1;
            Path = [Path;id_now,i];
            break;
        else
            if ~isempty(find(g_Path,i)>0)
                break
            end
            
            [Path_sub,bFind] = findNextNode(G,id_now,i,id_tar);
            if bFind == 1
                Path = [Path;Path_sub];
                break;
            end
        end
    end
    if bFind == 0
        Path = [];
    end
end

end



