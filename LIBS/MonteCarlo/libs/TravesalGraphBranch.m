function branches = TravesalGraphBranch(VesselGraph,startID,isolated)
global g_IdxsFindList;
g_IdxsFindList = [];
idxs_vertex = find(sum(VesselGraph)==1);
if isempty(startID)
    idx_start = idxs_vertex(1);
else
    idx_start = startID;
end
idx_next = find(VesselGraph(idx_start,:)==1);

branches = {};
while 1
    branchesTemp = findNextBranch(idx_start,idx_next,VesselGraph);
    branches = [branches branchesTemp];
    
    if isolated == 0
        idxs = findElementNotIn(idxs_vertex,g_IdxsFindList);
        if isempty(idxs)
            break;
        else
            idx_start = idxs(1);
            idx_next = find(VesselGraph(idx_start,:)==1);
        end
    else
        break;
    end
end

end

function idxs = findElementNotIn(idxs1,idxs2)
idxs = [];
for ii = idxs1
    if isempty(find(idxs2==ii, 1))
        idxs = [idxs, ii];
    end
end

end

function branches = findNextBranch(idx_start,idx_next,G)
global g_IdxsFindList;
sub_branch = [idx_start,idx_next];
idx_s = idx_next;
idx_n = idx_start;
while 1
    idxs_c = find(G(idx_s,:)==1);
    idxs_c(idxs_c==idx_n)=[];
    if size(idxs_c,2) ~= 1
        break;  
    end
    sub_branch = [sub_branch idxs_c];
    idx_n = idx_s;
    idx_s = idxs_c;
end

g_IdxsFindList = [g_IdxsFindList sub_branch];

if isempty(idxs_c)
    branches = {sub_branch};
else
    branches = {};
    for ii = idxs_c
        if isempty(find(g_IdxsFindList == ii, 1))
            branches = [branches findNextBranch(idx_s,ii,G)];
        end
    end
    branches = [sub_branch branches];
end
end