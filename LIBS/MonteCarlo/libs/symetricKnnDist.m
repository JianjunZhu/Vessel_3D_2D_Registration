function measure = symetricKnnDist(VesData3D,VesData2D,scale)

VesData3D_Proj = ProjectVesselData(VesData3D,VesData2D.K);
[~,distArray1] = dist_knn(VesData3D_Proj,VesData2D,scale);
[~,distArray2] = dist_knn(VesData2D,VesData3D_Proj,scale);
measure = mean(exp(-distArray1))+mean(exp(-distArray2));