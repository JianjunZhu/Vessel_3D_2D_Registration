function [R,t,centroid1] = CalculateTransformation(Pts1,Pts2)
% Transform pts1 to pts2
    %with correspondence£¬calculate R t
    n = max(size(Pts1));
    centroid1 = mean(Pts1);
    centroid2 = mean(Pts2);
    Pts1_demean = Pts1-repmat(centroid1,n,1);
    Pts2_demean = Pts2-repmat(centroid2,n,1);
    H=Pts1_demean'*Pts2_demean;
    [U,S,V]=svd(H);
    R=V*U';
    t = (centroid2-centroid1)';
end