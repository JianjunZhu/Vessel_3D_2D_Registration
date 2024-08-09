function [distMean,distArray,idxs] = dist_knn(VesData1,VesData2,scale)
Pts1 = VesData1.VesselPoints;
Pts2 = VesData2.VesselPoints;
G1 = VesData1.Graph_Directed;
G2 = VesData2.Graph_Directed;
%% calculate direction VesData1
nextIDs = zeros(1,length(Pts1));
troublePoints = [];
for i = 1:length(Pts1)
    ic = find(G1(i,:) == 1);
    if isempty(ic) || length(ic) >1
        nextIDs(i) = i;
        troublePoints = [troublePoints, i];
    else
        nextIDs(i) = ic;
    end
end
dir1 = Pts1 - Pts1(nextIDs,:);
size2D = normPerVector(dir1,2);
troublePoints = [troublePoints, find(size2D' > 20)];
troublePoints = unique(troublePoints);
for i = troublePoints
    ic = find(G1(:,i) == 1);
    if isempty(ic) || length(ic) >1
        dir1(i,:) = [0,0];
        size2D(i) = 1;
    else
        dir1(i,:) = dir1(ic,:);
        size2D(i) = size2D(ic);
    end
end
dir1 = dir1./(repmat(size2D,1,2)+eps);
combined1 = [Pts1,dir1];
%% calculate direction VesData2
nextIDs = zeros(1,length(Pts2));
troublePoints = [];
for i = 1:length(Pts2)
    ic = find(G2(i,:) == 1);
    if isempty(ic) || length(ic) >1
        nextIDs(i) = i;
        troublePoints = [troublePoints, i];
    else
        nextIDs(i) = ic;
    end
end
dir2 = Pts2 - Pts2(nextIDs,:);
size2D = normPerVector(dir2,2);
troublePoints = [troublePoints, find(size2D' > 20)];
troublePoints = unique(troublePoints);
for i = troublePoints
    ic = find(G2(:,i) == 1);
    if isempty(ic) || length(ic) >1
        dir2(i,:) = [0,0];
        size2D(i) = 1;
    else
        dir2(i,:) = dir2(ic,:);
        size2D(i) = size2D(ic);
    end
end
dir2 = dir2./(repmat(size2D,1,2)+eps);
combined2 = [Pts2,dir2];
%% knn search
k = 1;
w = [scale(1);scale(1);scale(2);scale(2)];
w = w.^-1;
customdis = @(x,Z)sqrt((bsxfun(@minus,x,Z).^2)*w);
[idxs,distArray] = knnsearch(combined2,combined1,'Distance',customdis,'k',k);
distMean = mean(distArray);
end

