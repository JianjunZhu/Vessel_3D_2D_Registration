function VesselDataRet = processVesselDataWrap(VesselData,varargin)

spacing = []; startID = []; directed = []; filterThr = [];
isolated = 0;
for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'spacing'
            spacing = varargin{i+1};
        case 'startID'
            startID = varargin{i+1};
        case 'directed'
            directed = varargin{i+1}; % directed = 0,no directed graph,
        case 'filter'
            filterThr = varargin{i+1};
        case 'isolated'
            isolated = varargin{i+1};
    end
end
if isempty(spacing)
    spacing = 1;
end
%%

[VesselDataProc,~] = processGraphWrapNew(VesselData.VesselPoints,VesselData.Graph,'spacing',spacing,...
    'startID',startID,'directed',directed,'filter',filterThr,'isolated',isolated);
if size(VesselData.VesselPoints,2) == 2
    VesselDataRet = VesselDataProc;
    VesselDataRet.P = VesselData.P;
    VesselDataRet.K = VesselData.K;
    VesselDataRet.T = VesselData.T;
    VesselDataRet.dicom_dir = VesselData.dicom_dir;
    VesselDataRet.img_src = VesselData.img_src;
    VesselDataRet.img_seg = VesselData.img_seg;
    VesselDataRet.img_centerline = VesselData.img_centerline;
end
if size(VesselData.VesselPoints,2) == 3
    VesselDataRet = VesselDataProc;
end

