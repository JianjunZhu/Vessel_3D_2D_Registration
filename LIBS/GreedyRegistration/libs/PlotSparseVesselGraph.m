function PlotSparseVesselGraph(VesData)
[s, t] = find(VesData.Graph_Sparse_Directed==1);
G = digraph(s,t);
figure,plot(G);drawnow;