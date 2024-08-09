%% CreatMCTNodeStruct
function Nodes = CreatMCTNodeStruct

Nodes = struct('PairSparse',{},'EdgePair',struct('Edge3D',{},'Edge2D',{}),...
    'PairDense',{},'Trans',{},'QUrgency',{},'QSim',{},'Nvisit',{},'Measure',{},'level',{},...
    'expandable',{});

end
% expandable 应该包含多种情况，自节点是否拓展，子树是否拓展