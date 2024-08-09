function VesDataReg= ICPOrient3D2D(VesData3D,VesData2D,scale,strMethod,Trim)
nIteration = 50;
VesDataTrans = VesData3D;
for iter = 1:nIteration
    
    VesData3D_Proj = ProjectVesselData(VesData3D,VesData2D.K);
    [distMean,distArray,idxs] = dist_knn(VesData3D_Proj,VesData2D,scale);

    [B,I] = sort(distArray);
    idxs_3d = I(round(length(I)*Trim):end);
    idxs_2d = idxs(I(round(length(I)*Trim):end));
    pts3d = VesData3D.VesselPoints(idxs_3d,:);
    pts2d = VesData2D.VesselPoints(idxs_2d,:);
    if strcmp(strMethod,'PnP')
        [R,t] = myPnP(pts3d,pts2d,VesData2D.K);
        VesDataTrans = TransVesselData3D(VesData3D,[R,t]);
    elseif strcmp(strMethod,'BackProjection')
        pts2d_BP = BackProjectionNN(pts3d,pts2d,VesData2D.K);
        [R,t] = CalculateTransformation(pts3d,pts2d_BP);
        VesDataTrans = TransVesselData3D(VesData3D,[R,t],'central');
    end

end
VesDataReg = VesDataTrans;