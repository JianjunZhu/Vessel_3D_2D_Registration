function measure = MCTSR2Measure(config,Node)

sigma = config.sigma;
VesData2D = config.VesData2D;
VesData3D_Trans = Node.Trans;
VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);

img_DT = VesData2D.img_DT;
ptsIdxs = uint16(VesData3D_Proj.VesselPoints);

ptsIdxs(ptsIdxs<1) = 1;
ptsIdxs(ptsIdxs>size(img_DT,1)) = size(img_DT,1);
distArray = zeros(length(ptsIdxs),1);
for i = 1:length(ptsIdxs)
    idxs = ptsIdxs(i,:);
    x = idxs(1); y = idxs(2);
    distArray(i) = img_DT(y,x);
end
% distMean = mean(distArray);

P = VesData3D_Proj.VesselPoints_Sparse;
Q = VesData2D.VesselPoints_Sparse;
Ps = power(det(P'*P/length(P)),1/(2^size(P,2)));
Qs = power(det(Q'*Q/length(Q)),1/(2^size(Q,2)));

% multi_sigma = config.multi_sigma;
% nSigma = length(multi_sigma);
% 
% distMatrix = repmat(distArray,1,nSigma);
% sigmaMatrix = repmat(multi_sigma,length(distArray),1);
% distTemp = distMatrix./sigmaMatrix;
% distTemp = exp(-distTemp).^2;
% distTemp = sqrt(sum(distTemp,2));
% distTemp = mean(distTemp);
% a = distTemp;

% a = mean(exp(-(distArray/sigma)));
% 
% b = (Ps/Qs+Qs/Ps)*config.lamda1;
measure = mean(exp(-(distArray/sigma))) - (Ps/Qs+Qs/Ps)*config.lamda1;

% disp(['a=',num2str(a),',b=',num2str(b),',m=',num2str(measure)]);

end