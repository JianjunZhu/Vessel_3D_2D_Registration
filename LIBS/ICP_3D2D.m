function VesData3D_Trans = ICP_3D2D(VesData3D,VesData2D,bNonrigid,strMethod,varargin)
%% we proviede two ICP_3D2D registration strategies, 'PnP' and  'BackProjection'
if isempty(strMethod)
    strMethod = 'PnP';
end
% if strcmp(strMethod,'BackProjection')
%     K = varargin{1};
% end
if numel(varargin) == 1
    Trim = varargin{1};
else
    Trim = 0.05;
end

%%
K = VesData2D.K;
nIteration = 100;
NS = createns(VesData2D.VesselPoints,'NSMethod','kdtree');
VesData3D_Trans = VesData3D;
for i = 1:nIteration
    VesData2D_Proj = ProjectVesselData(VesData3D_Trans,K);
    [idxs, DistArray] = knnsearch(NS,VesData2D_Proj.VesselPoints,'k',1);
    
    if bNonrigid == 0
        [B,I] = sort(DistArray);
        idxs_3d = I(round(length(I)*Trim):end);
        idxs_2d = idxs(I(round(length(I)*Trim):end));

        pts3d = VesData3D_Trans.VesselPoints(idxs_3d,:);
        pts2d = VesData2D.VesselPoints(idxs_2d,:);
        if strcmp(strMethod,'PnP')
            [R,t] = myPnP(pts3d,pts2d, K);
            VesData3D_Trans = TransVesselData3D(VesData3D_Trans,[R,t]);
        elseif strcmp(strMethod,'BackProjection')
            pts2d_BP = BackProjectionNN(pts3d,pts2d,VesData2D.K);
            [R,t] = CalculateTransformation(pts3d,pts2d_BP);
            VesData3D_Trans = TransVesselData3D(VesData3D_Trans,[R,t],'central');
        end
    else
        if ~isfield(VesData3D_Trans,'PriorModel')
            PriorModel = GeneratePriorModel(VesData3D_Trans);
            VesData3D_Trans.PriorModel = PriorModel;
        end
        VesData3D_Trans = UpdateVesselPoints(VesData3D_Trans,VesData3D_Trans.VesselPoints);

        
        pts3d = VesData3D_Trans.VesselPoints;
        pts2d = VesData2D.VesselPoints(idxs,:);
        pts2d_BP = BackProjectionNN(pts3d,pts2d,VesData2D.K);
        
        ssmParam = CalculateModelParam(VesData3D_Trans.PriorModel,pts2d_BP,VesData3D_Trans.quaternionPara);  
        pts3d_fit = GeneratePtsByPriorModel(VesData3D_Trans.PriorModel,ssmParam,VesData3D_Trans.quaternionPara);
        VesData3D_Trans = UpdateVesselPoints(VesData3D_Trans,pts3d_fit);
    end 
end

end
