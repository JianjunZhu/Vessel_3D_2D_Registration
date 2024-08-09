%% customMeasure 
function measure = fastMeasure(config,Node)
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
%     if x < 1
%         x = 1;
%     elseif x > size(img_DT,2)
%         x = size(img_DT,2);
%     end
% 
%     if y < 1
%         y = 1;
%     elseif y > size(img_DT,1)
%         y = size(img_DT,1);
%     end
    distArray(i) = img_DT(y,x);
end
% distMean = mean(distArray);

P = VesData3D_Proj.VesselPoints_Sparse;
Q = VesData2D.VesselPoints_Sparse;
Ps = power(det(P'*P/length(P)),1/(2^size(P,2)));
Qs = power(det(Q'*Q/length(Q)),1/(2^size(Q,2)));

measure = mean(exp(-distArray/sigma)) + exp(-(Ps/Qs+Qs/Ps-2))*5;