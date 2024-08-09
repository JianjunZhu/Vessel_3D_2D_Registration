function [distMean, distArray] = DT_Distance(VesData1,VesData2)


img_centerline = centerlineToImage(VesData2.VesselPoints,size(VesData2.img_src));
img_DT = bwdist(img_centerline);
% figure, imshow(img_DT,[]);

ptsIdxs = uint16(VesData1.VesselPoints);
distArray = zeros(length(ptsIdxs),1);
for i = 1:length(ptsIdxs)
    idxs = ptsIdxs(i,:);
    x = idxs(1); y = idxs(2);
    if x < 1
        x = 1;
    elseif x > size(img_DT,2)
        x = size(img_DT,2);
    end

    if y < 1
        y = 1;
    elseif y > size(img_DT,1)
        y = size(img_DT,1);
    end

    distArray(i) = img_DT(y,x);
end
distMean = mean(distArray);