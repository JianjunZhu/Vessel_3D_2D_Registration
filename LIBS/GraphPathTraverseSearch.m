function Paths = GraphPathTraverseSearch(G,Eg)
% depth-first search
global g_Path; global g_PathFind;
g_Path = []; g_PathFind = {};

idxs_c = find(G(Eg(1),:)==1);
for i = idxs_c
   if i == Eg(2)
       g_PathFind = [g_PathFind,[Eg(1) i]];
   end
   findNextNodeTraverse(G,Eg(1),i,Eg(2));
   g_Path = [];
end
Paths = g_PathFind;
end

function findNextNodeTraverse(G,id_last,id_now,id_tar)
global g_Path; global g_PathFind;

g_Path = [g_Path;id_last,id_now];
if id_now == id_tar
    g_PathFind = [g_PathFind,g_Path];
end

ids_c = find(G(id_now,:)==1);
ids_c(ids_c==id_last) = [];

for i = ids_c;
    if ~isempty(find(g_Path==i, 1))
        continue;
    end
    findNextNodeTraverse(G,id_now,i,id_tar);

    r = find(ismember(g_Path,[id_now,i],'rows')==1);
    g_Path(r:end,:) = [];
end
end