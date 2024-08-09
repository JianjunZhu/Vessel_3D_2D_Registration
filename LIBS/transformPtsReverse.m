function result = transformPtsReverse(VesselPoints,quatParam)

r=quat2dcm(quatParam(1:4));
t = quatParam(5:7);
meanPoint = mean(VesselPoints,1);
result = add2AllMat(add2AllMat(VesselPoints,-meanPoint)*r,- t + meanPoint);