function NodesChild = AssignDensePairsFromSparse(NodesChild,config)
VesData3D = config.VesData3D;
VesData2D = config.VesData2D;

% if isfield(config,'AssignStrategy')
%     strategy = config.AssignStrategy;
% else
%     strategy = 'uniform';
% end
strategy = 'uniform';
PnP = 'ASPnP';
if strcmp(strategy,'uniform')
    for iChild = 1:length(NodesChild)
        EdgePair = NodesChild(iChild).EdgePair;
        PairDense = [];
        for iPair = 1:length(EdgePair)
            Eg1 = EdgePair(iPair).Edge3D;
            Eg2 = EdgePair(iPair).Edge2D;
            if isempty(Eg1)||isempty(Eg2)
                continue;
            end
            branchType1 = FindBranchtype(VesData3D,Eg1);
            branchType2 = FindBranchtype(VesData2D,Eg2);
            if length(branchType1.EdgePointsIDs) < length(branchType2.EdgePointsIDs)
                ratio = length(branchType2.EdgePointsIDs)/length(branchType1.EdgePointsIDs);
                PairDenseTemp = [branchType1.EdgePointsIDs',branchType2.EdgePointsIDs(1:ratio:end)'];            
            else
                ratio = length(branchType1.EdgePointsIDs)/length(branchType2.EdgePointsIDs);
                PairDenseTemp = [branchType1.EdgePointsIDs(1:ratio:end)',branchType2.EdgePointsIDs'];  
            end
            PairDense = [PairDense;PairDenseTemp];
        end
        
        if isempty(PairDense)
            disp('PairDense is empty');
            continue;
        end
        
        NodesChild(iChild).PairDense = PairDense;
        pts3d = VesData3D.VesselPoints(NodesChild(iChild).PairDense(:,1),:);
        pts2d = VesData2D.VesselPoints(NodesChild(iChild).PairDense(:,2),:);
        [R,t,~] = myPnP(pts3d,pts2d,VesData2D.K,PnP);

        VesData3DTrans = TransVesselData3D(VesData3D,[R,t],'normal');
%         VesData3DTrans = MyRefinement(VesData3DTrans,VesData2D,0,{'DT'});
        NodesChild(iChild).Trans = VesData3DTrans;
          
    end
end