%% GreedyFilterNodes
function [NodesChildRet,idBest] = GreedyFilterNodes(NodesChild,nSelect,config)
NodeCounts = length(NodesChild);
Measures = zeros(1,NodeCounts);
for i = 1:NodeCounts
    Measures(i) = NodesChild(i).Measure;
end
% [~,idBest] = max(Measures);
[~,I] = sort(Measures,'descend');
if nSelect <= length(I)
    idBest = I(1:nSelect);
else
    idBest = I;
end

NodesChildRet = NodesChild(idBest);

if nSelect == 1
    VesData3D_Trans = NodesChildRet.Trans;
    VesData2D = config.VesData2D;
    NodesChildRet.Trans = ICPOrient3D2D(VesData3D_Trans,VesData2D,config.scale,'PnP',0.3);
end


end