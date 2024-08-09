function diG = GenerateDirectedGraph(G,startID)
%% generate directed sparse graph
diG = zeros(size(G));

[s, t] = find(G==1); %Graph_Sparse_Directed
GG = digraph(s,t);
V = bfsearch(GG,startID);

for i = 1:size(diG,1)
    i_child = find(G(i,:)==1);
    for ii = i_child
        if find(V==i)<find(V==ii)
            diG(i,ii) = 1;
        end
    end
end

end