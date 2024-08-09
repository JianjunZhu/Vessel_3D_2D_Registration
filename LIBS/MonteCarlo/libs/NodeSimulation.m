function QSim = NodeSimulation(Node,config)

if isempty(FindChildNodesWrap(Node,config))
    Node = AssignDensePairsFromSparse(Node,config);
    Node = EsitmateNodesMeaure(Node,config);
    QSim = Node.Measure;
    return;
end

NodesSimulation = [];
NodeSelect = Node;
% while length(NodesSimulation) < config.SimulationCounts
%     NodesChild = FindChildNodesWrap(NodeSelect,config);
%     if isempty(NodesChild)
%         NodesSimulation = [NodesSimulation,NodeSelect];
%         NodeSelect = Node;
%     else
%         NodeSelect = NodesChild(randi(length(NodesChild)));
%     end
% end

while length(NodesSimulation) < config.SimulationCounts
    NodesChild = FindChildNodesWrap(NodeSelect,config);
    
    if isempty(NodesChild)
        NodeSelect = Node;
    else
        NodeSelect = NodesChild(randi(length(NodesChild)));
        NodesSimulation = [NodesSimulation,NodeSelect];
    end
end

NodesSimulation = AssignDensePairsFromSparse(NodesSimulation,config);
NodesSimulation = EsitmateNodesMeaure(NodesSimulation,config);

QSim = max([NodesSimulation.Measure]);