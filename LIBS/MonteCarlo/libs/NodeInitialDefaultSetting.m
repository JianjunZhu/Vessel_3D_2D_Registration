function Nodes = NodeInitialDefaultSetting(Nodes,Nvisit)

for i = 1:length(Nodes)
    Nodes(i).Nvisit = Nvisit;
end