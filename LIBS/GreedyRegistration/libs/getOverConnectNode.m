%% getOverConnectNode
function [nodes,Paths] = getOverConnectNode(Graph,nodeid,redun)
global g_redun;global g_Path; global g_PathFind;
g_redun = redun; g_Path = []; g_PathFind = {};

nodes = [];
idnow = nodeid;

idsnext = find(Graph(idnow,:)==1);
for i = idsnext
    findNextNodeTraverse(Graph,idnow,i);
    g_Path = [];
end

for i = 1:length(g_PathFind)
    path = g_PathFind{i};
    nodes = [nodes,path(end,2)];
end

Paths = g_PathFind;
end

function findNextNodeTraverse(G,id_last,id_now)
global g_redun;global g_Path; global g_PathFind;

g_Path = [g_Path;id_last,id_now];
if size(g_Path,1) <= g_redun
    g_PathFind = [g_PathFind,g_Path];
else
    return;
end

ids_c = find(G(id_now,:)==1);
ids_c(ids_c==id_last) = [];

for i = ids_c;
    if ~isempty(find(g_Path==i, 1))
        continue;
    end
    findNextNodeTraverse(G,id_now,i);

    r = find(ismember(g_Path,[id_now,i],'rows')==1);
    g_Path(r:end,:) = [];
end
end