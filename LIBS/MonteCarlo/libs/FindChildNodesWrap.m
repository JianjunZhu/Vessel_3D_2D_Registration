function NodesChild = FindChildNodesWrap(NodeParent,config)

if isfield(config,'FindChildNodeType')
    type = config.FindChildNodeType;
else
    type = 'coronary';
end

switch type
    case 'coronary'
        NodesChild = FindChildNodes(NodeParent,config);
    case 'aorta'
        NodesChild = FindChildNodesAorta(NodeParent,config);
end