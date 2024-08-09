%% EsitmateNodesMeaure
function NodesChild = EsitmateNodesMeaure(NodesChild,config)

VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
if isfield(config,'FilterStrategy')
    FilterStrategy = config.FilterStrategy;
else
    FilterStrategy = 'GMM';
end


if strcmp(FilterStrategy,'GMM')
    for iChild = 1:length(NodesChild)
        VesData3D_Trans = NodesChild(iChild).Trans;
        VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);
        NodesChild(iChild).Measure = -costfunc_OGMM_Points2D(VesData3D_Proj.VesselPoints,VesData2D.VesselPoints,config.scale);
    end
end
if strcmp(FilterStrategy,'Frechet')
    for iChild = 1:length(NodesChild)
        EdgePair = NodesChild(iChild).EdgePair;
        CumDis = 0;
        VesData3D_Trans = NodesChild(iChild).Trans;
        VesData3D_Proj= ProjectVesselData(VesData3D_Trans,VesData2D.K);
        skipped = 0;
        for iPair = 1:length(EdgePair)
            Eg3D = EdgePair(iPair).Edge3D;
            Eg2D = EdgePair(iPair).Edge2D;
            if isempty(Eg3D)||isempty(Eg2D)
                skipped = skipped + 1;
                continue;
            end
            
            branchType1 = FindBranchtype(VesData3D_Proj,Eg3D);
            branchType2 = FindBranchtype(VesData2D,Eg2D);
            
            [cm, cSq] = DiscreteFrechetDist(branchType1.EdgePoints,branchType2.EdgePoints);
            CumDis = CumDis + cm;
        end
        NodesChild(iChild).Measure = -CumDis / (length(EdgePair)-skipped);
    end
end 

if strcmp(FilterStrategy,'DT')
    for iChild = 1:length(NodesChild)
        VesData3D_Trans = NodesChild(iChild).Trans;
        VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);
        
        [distMean, ~] = DT_Distance(VesData3D_Proj,VesData2D);
        
        
        NodesChild(iChild).Measure = -mean(distMean);
    end
end

if strcmp(FilterStrategy,'knn')
    for iChild = 1:length(NodesChild)
        VesData3D_Trans = NodesChild(iChild).Trans;
        VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);
        
        NodesChild(iChild).Measure = -dist_knn(VesData3D_Proj,VesData2D,config.scale);
    end
end

if strcmp(FilterStrategy,'custom')
    for iChild = 1:length(NodesChild)
        NodesChild(iChild).Measure = customMeasure(config,NodesChild(iChild));
    end
end

if strcmp(FilterStrategy,'fast')
    for iChild = 1:length(NodesChild)
        NodesChild(iChild).Measure = fastMeasure(config,NodesChild(iChild));
    end
end

if strcmp(FilterStrategy,'MCTSR2')
    for iChild = 1:length(NodesChild)
        NodesChild(iChild).Measure = MCTSR2Measure(config,NodesChild(iChild));
    end
end

if strcmp(FilterStrategy,'heuristic')
    for iChild = 1:length(NodesChild)
        NodesChild(iChild).Measure = customMeasure(config,NodesChild(iChild));
%         NodesChild(iChild).Measure = heuristicMeasure(config,NodesChild(iChild));
    end
end

end