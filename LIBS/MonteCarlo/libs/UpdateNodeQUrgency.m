function Nodes = UpdateNodeQUrgency(Nodes,config,iter)
for i = 1:length(Nodes)
    Nodes(i).QUrgency = Nodes(i).QSim/config.Qnorm + config.urgency_sigma*sqrt(2*log10(iter)/Nodes(i).Nvisit);
end
    