function [R,t,inliers] = myPnP(pts3d,pts2d,K,varargin)

pts2d_homo = cart2homo(pts2d');
pts2d_homo = K\pts2d_homo;
pts2d_nor = pts2d_homo(1:2,:)';

if isempty(varargin)
    method_name = 'ASPnP';
else
    method_name = varargin{1};
end

inliers = ones(1,length(pts3d));

switch method_name
    case 'ASPnP'
        [R,t] = ASPnP(pts3d',pts2d_nor', K);       
    case 'REPPnP'
%         [R,t,inliers, ~, ~] = REPPnP(pts3d',pts2d_nor',0.002);
        [R,t]= efficient_pnp_gauss(pts3d,pts2d,K);
    case 'LHM'
        [R,t] = LHM(pts3d',pts2d_nor');
    case 'EPnP'
        [R,t] = EPnP_GN(pts3d',pts2d_nor');
    case 'EPPnP'
        [R,t] = EPPnP(pts3d',pts2d_nor');
    case 'RPnP'
        [R,t] = RPnP(pts3d',pts2d_nor');
    case 'DLS'
        [R,t] = robust_dls_pnp(pts3d',pts2d_nor'); 
    case 'OPnP'
        [R,t] = OPnP(pts3d',pts2d_nor');
    case 'GOP'
        [R,t] = GOP(pts3d',pts2d_nor');
    case 'PPnP'
        [R,t] = PPnP(pts3d',pts2d_nor');
    otherwise
        [R,t] = ASPnP(pts3d',pts2d_nor', K);  
end

if isempty(R) || isempty(t)
    R = eye(3,3); t = zeros(3,1);
end
if numel(size(R)) == 3
    R = R(:,:,1);
    t = t(:,1);
end

% PointsTrans = TransformPointSet(pts3d,R,t');


end
% 
% function PointsTrans = TransformPointSet(Points,R,t)
%     Points_Mean = mean(Points,1);
%     PointsTrans = add2AllMat(add2AllMat(Points,-Points_Mean)*R',+ t + Points_Mean);
% end