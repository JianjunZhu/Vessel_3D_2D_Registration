%% AssignDensePairs
function NodesChild = AssignDensePairs(NodesChild,NodeLeaf,config)

if isfield(config,'AssignStrategy')
    strategy = config.AssignStrategy;
else
    strategy = 'uniform';
end


switch strategy
    case 'uniform'
        NodesChild = uniformPairing(NodesChild,NodeLeaf,config);
    case 'projected'
        NodesChild = projectedPairing(NodesChild,NodeLeaf,config);
    case 'mixture'
        NodesChild = mixturePairing(NodesChild,NodeLeaf,config);
    otherwise
        NodesChild = uniformPairing(NodesChild,NodeLeaf,config);
end

end

function NodesChild = uniformPairing(NodesChild,NodeLeaf,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
PnP = 'ASPnP';
for iChild = 1:length(NodesChild)
    Eg1 = NodesChild(iChild).EdgePair(end).Edge3D;
    Eg2 = NodesChild(iChild).EdgePair(end).Edge2D;
    if isempty(Eg1)||isempty(Eg2)
        NodesChild(iChild).PairDense = NodeLeaf.PairDense;
        NodesChild(iChild).Trans = NodeLeaf.Trans;
    else
        branchType1 = FindBranchtype(VesData3D,Eg1);
        branchType2 = FindBranchtype(VesData2D,Eg2);

        if length(branchType1.EdgePointsIDs) < length(branchType2.EdgePointsIDs)
            ratio = length(branchType2.EdgePointsIDs)/length(branchType1.EdgePointsIDs);
            PairDense = [branchType1.EdgePointsIDs',branchType2.EdgePointsIDs(1:ratio:end)'];            
        else
            ratio = length(branchType1.EdgePointsIDs)/length(branchType2.EdgePointsIDs);
            PairDense = [branchType1.EdgePointsIDs(1:ratio:end)',branchType2.EdgePointsIDs'];  
        end
        NodesChild(iChild).PairDense = [NodeLeaf.PairDense;PairDense];

        pts3d = VesData3D.VesselPoints(NodesChild(iChild).PairDense(:,1),:);
        pts2d = VesData2D.VesselPoints(NodesChild(iChild).PairDense(:,2),:);
        [R,t,~] = myPnP(pts3d,pts2d,VesData2D.K,PnP);

        VesData3DTrans = TransVesselData3D(VesData3D,[R,t],'normal');
%         VesData3DTrans = MyRefinement(VesData3DTrans,VesData2D,0,{'DT'});
        NodesChild(iChild).Trans = VesData3DTrans;
    end  
end

end

function NodesChild = projectedPairing(NodesChild,NodeLeaf,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
PnP = 'ASPnP';
for iChild = 1:length(NodesChild)
    Eg1 = NodesChild(iChild).EdgePair(end).Edge3D;
    Eg2 = NodesChild(iChild).EdgePair(end).Edge2D;

    if isempty(Eg1)||isempty(Eg2)
        NodesChild(iChild).PairDense = NodeLeaf.PairDense;
        NodesChild(iChild).Trans = NodeLeaf.Trans;
    else
        if isempty(NodeLeaf.Trans)
            VesData3D_Trans = VesData3D;
        else
            VesData3D_Trans = NodeLeaf.Trans;
        end
        VesData3D_Proj= ProjectVesselData(VesData3D_Trans,VesData2D.K);
        branchType1 = FindBranchtype(VesData3D_Proj,Eg1);
        branchType2 = FindBranchtype(VesData2D,Eg2);

        [cm,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints');   
        ixu = ix; iyu = iy;
%         [ixu,iyu] = uniqueCorr(ix,iy,branchType1.EdgePoints,branchType2.EdgePoints);
        PairDense = [branchType1.EdgePointsIDs(ixu)',branchType2.EdgePointsIDs(iyu)'];

        NodesChild(iChild).PairDense = [NodeLeaf.PairDense;PairDense];

        pts3d = VesData3D_Trans.VesselPoints(NodesChild(iChild).PairDense(:,1),:);
        pts2d = VesData2D.VesselPoints(NodesChild(iChild).PairDense(:,2),:);
        [R,t,~] = myPnP(pts3d,pts2d,VesData2D.K,PnP);
        VesData3D_Trans = TransVesselData3D(VesData3D_Trans,[R,t],'normal');
%         VesData3DTrans = MyRefinement(VesData3DTrans,VesData2D,0,{'DT'});
        NodesChild(iChild).Trans = VesData3D_Trans;

    end   
end
end

function NodesChild = mixturePairing(NodesChild,NodeLeaf,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;
PnP = 'ASPnP';
for iChild = 1:length(NodesChild)
    Eg1 = NodesChild(iChild).EdgePair(end).Edge3D;
    Eg2 = NodesChild(iChild).EdgePair(end).Edge2D;

    if isempty(Eg1)||isempty(Eg2)
        NodesChild(iChild).PairDense = NodeLeaf.PairDense;
        NodesChild(iChild).Trans = NodeLeaf.Trans;
    else
        if isempty(NodeLeaf.Trans)
            VesData3D_Trans = VesData3D;
        else
            VesData3D_Trans = NodeLeaf.Trans;
        end
        VesData3D_Proj= ProjectVesselData(VesData3D_Trans,VesData2D.K);
        branchType1 = FindBranchtype(VesData3D_Proj,Eg1);
        branchType2 = FindBranchtype(VesData2D,Eg2);

        %% 1
        [~,ix,iy] = dtw(branchType1.EdgePoints',branchType2.EdgePoints');   
        ixu = ix; iyu = iy;
        PairDense1 = [branchType1.EdgePointsIDs(ixu)',branchType2.EdgePointsIDs(iyu)'];
        PairDense1 = [NodeLeaf.PairDense;PairDense1];
        pts3d = VesData3D_Trans.VesselPoints(PairDense1(:,1),:);
        pts2d = VesData2D.VesselPoints(PairDense1(:,2),:);
        [R,t,~] = myPnP(pts3d,pts2d,VesData2D.K,PnP);
        VesData3D_Trans1 = TransVesselData3D(VesData3D_Trans,[R,t],'normal');

        %% 2
        if length(branchType1.EdgePointsIDs) < length(branchType2.EdgePointsIDs)
            ratio = length(branchType2.EdgePointsIDs)/length(branchType1.EdgePointsIDs);
            PairDense2 = [branchType1.EdgePointsIDs',branchType2.EdgePointsIDs(1:ratio:end)'];            
        else
            ratio = length(branchType1.EdgePointsIDs)/length(branchType2.EdgePointsIDs);
            PairDense2 = [branchType1.EdgePointsIDs(1:ratio:end)',branchType2.EdgePointsIDs'];  
        end
        PairDense2 = [NodeLeaf.PairDense;PairDense2];
        pts3d = VesData3D.VesselPoints(PairDense2(:,1),:);
        pts2d = VesData2D.VesselPoints(PairDense2(:,2),:);
        [R,t,~] = myPnP(pts3d,pts2d,VesData2D.K,PnP);
        VesData3D_Trans2 = TransVesselData3D(VesData3D,[R,t],'normal');
        
        %%

        measure1 = symetricKnnDist(VesData3D_Trans1,VesData2D,[5,0.2]);
        measure2 = symetricKnnDist(VesData3D_Trans2,VesData2D,[5,0.2]);
        
        if measure1 > measure2
            NodesChild(iChild).PairDense = PairDense1;
            NodesChild(iChild).Trans = VesData3D_Trans1;
        else
            NodesChild(iChild).PairDense = PairDense2;
            NodesChild(iChild).Trans = VesData3D_Trans2;
        end
        
    end   
end
end



