%% CreatNodeStruct
function Nodes = CreatNodeStruct(varargin)
if numel(varargin) > 1
    disp('Error Input');
    return;
end
if numel(varargin) == 0
    type = 'normal';
else
    type = varargin{1};
end


switch type
    case 'normal'
        Nodes = struct('PairSparse',{},'EdgePair',struct('Edge3D',{},'Edge2D',{}),...
            'PairDense',{},'Trans',{},'Measure',{},'level',{});
    case 'MCT'
        Nodes = struct('PairSparse',{},'EdgePair',struct('Edge3D',{},'Edge2D',{}),...
            'PairDense',{},'Trans',{},'QUrgency',{},'QSim',{},'Nvisit',{},'Measure',{},'level',{},...
            'Expandable',{},'ExpandCurrent',{});
end



end