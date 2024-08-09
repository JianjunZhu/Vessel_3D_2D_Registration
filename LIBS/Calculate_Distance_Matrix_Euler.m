function disMatrix = Calculate_Distance_Matrix_Euler(points)

% parpool;
% gcp('nocreate');

[counts,~] = size(points);
disMatrix = zeros(counts,counts);

for i = 1:counts
    disMatrix(i,i) = 0;
    pts1 = points(i,:); 
    for j = i+1:counts
%         disMatrix(i,j) = EulerDistanceMetric(pts1,pointsCell{j});
        disMatrix(i,j) = norm(pts1-points(j,:));
    end
end
% delete(gcp);
for i = 1:counts
    for j = i+1:counts
        disMatrix(j,i) = disMatrix(i,j);
    end
end