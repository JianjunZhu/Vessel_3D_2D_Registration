function [Cor_Sparse] = redundantMatching(VesData1,VesData2,redundant,Parameters)

%% parse varargin
bPosition = 0; bPointType = 0; bPtRadius = 0; bFrechet = 0; bDTW = 0; bEdge = 0; bDirected = 0; bLength = 0; bBranchRadius = 0;
PriorCorr = []; bIsolated = 0; bRedundant = 0;
for i = 1:numel(Parameters)
    switch Parameters{i}
        case 'Directed'
            bDirected = 1;
        case 'Position'
            bPosition = 1;
        case 'PointType'
            bPointType = 1;
        case 'PtRadius'
            bPtRadius = 1;
        case 'BranchRadius'
            bBranchRadius = 1;
        case 'Frechet'
            bFrechet = 1;   
        case 'DTW'
            bDTW = 1;
        case 'Edge'
            bEdge = 1;
        case 'PriorCorr'
            PriorCorr = [1,1];
        case 'Length'
            bLength = 1;
        case 'Isolated'
            bIsolated = 1;
        case 'Redundant'
            bRedundant = 1;
    end
end
%%
gphs = cell(1,2);
gph1 = makeGphsRedundant2D(VesData1,bDirected,redundant);
gph2 = makeGphsRedundant2D(VesData2,bDirected,redundant);
gphs{1} = gph1;
gphs{2} = gph2;
    
[n1, m1] = size(gphs{1}.G);
[n2, m2] = size(gphs{2}.G);
%% KP and KQ setting
KP = zeros(n1,n2);

if ~isempty(PriorCorr)
    KP(PriorCorr(1),PriorCorr(2)) = 100;
end
if bPosition == 1
    DP = conDst(gphs{1}.Pt, gphs{2}.Pt);
    KP = KP + normalizeK(sqrt(DP));
end
if bPointType == 1
    ptType1 = repmat(gphs{1}.NodeType',1,n2);
    ptType2 = repmat(gphs{2}.NodeType,n1,1);
    DstType = abs(ptType1-ptType2);
    KP = KP + normalizeK(DstType);
end
if bPtRadius == 1
    ptRadius1 = repmat(gphs{1}.Radius,1,n2);
    ptRadius2 = repmat(gphs{2}.Radius',n1,1);
    DstRadius = abs(ptRadius1-ptRadius2);
    KP = KP + normalizeK(DstRadius);
end

KQ = zeros(m1, m2);
if bIsolated == 0

    if bBranchRadius == 1
        branchRadius1 = repmat(gphs{1}.BranchMeanRadius',1,m2);
        branchRadius2 = repmat(gphs{2}.BranchMeanRadius,m1,1);
        DstRadius= abs(branchRadius1-branchRadius2);
        KQ = KQ + normalizeK(DstRadius);
    end

    if bFrechet == 1 
        KQTemp = zeros(m1, m2);
        for i = 1:m1
            P = gphs{1}.Branch{i};
            for j = 1:m2
                Q = gphs{2}.Branch{j};
                [dF, ~] = DiscreteFrechetDist(P,Q);
                KQTemp(i,j) = dF;
            end
        end
        KQ = KQ + normalizeK(KQTemp);
    end

    if bDTW == 1
        KQTemp = zeros(m1, m2);
        for i = 1:m1
            P = gphs{1}.Branch{i};
            for j = 1:m2
                Q = gphs{2}.Branch{j};
                [~,ix,iy] = dtw(P',Q',1);
                dF = meanDistance(P(ix,:),Q(iy,:));
                KQTemp(i,j) = dF;
            end
        end
        KQ = KQ + normalizeK(KQTemp);
    end

    if bEdge == 1
        Ang1 = repmat(gph1.angs', 1, m2);
        Ang2 = repmat(gph2.angs, m1, 1);
        Ang = abs(Ang1 - Ang2);
        KQ = KQ + normalizeK(Ang);
    end
    if max(KQ(:)) == 0
        KQ = ones(m1, m2);
    end
end
%% modify KQ
GraphRedun = gph2.GraphRedun;
nEdge = length(find(GraphRedun==1));
if nEdge < m2
    KQSimple = KQ;
    [I,J] = find(GraphRedun==1);
    EgSimple = [I,J];
    Eg2 = gph2.Eg;
    record = {};
    for i = 1:length(EgSimple)
        ids = find(ismember(Eg2',EgSimple(i,:),'rows')==1);
        if length(ids)>1 
            record = [record, ids];
        end
    end
    
    colToDelete = [];
    for i = 1:length(record)
        ids = record{i};
        ids = sort(ids);
        n_ids = length(ids);
        for j = 2:n_ids
            colToDelete = [colToDelete,ids(j)];
            KQSimple(:,ids(1)) = KQSimple(:,ids(1)) + KQSimple(:,ids(j));
        end
        KQSimple(:,ids(1)) = KQSimple(:,ids(1)) / n_ids;
    end
    
    KQSimple(:,colToDelete) = [];
    KQ = KQSimple;
    Eg2(:,colToDelete) = [];        
    
    gph2.Eg = Eg2;
    
end
    
%% restricted setting
Ct = ones(size(KP));
for i = 1:size(PriorCorr,1) 
    Eg = PriorCorr(i,:);
    Ct(Eg(1),:) = zeros(1,n2);
    Ct(:,Eg(2)) = zeros(n1,1);
    Ct(Eg(1),Eg(2)) = 1;
end

[Cor_Sparse,~] = FGM_Ct(gph1.Eg,gph2.Eg,KP,KQ,Ct);

end


