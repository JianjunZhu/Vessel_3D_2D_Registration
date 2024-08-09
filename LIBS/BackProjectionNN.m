function pts2d_BP = BackProjectionNN(pts3d,pts2d,K)
%% project 2d point to 3d
%% normalize 2D points
pts2d_homo = cart2homo(pts2d');
pts2d_homo = K\pts2d_homo;
pts2d_nor = pts2d_homo(1:2,:)';
%%
nPoints2D = size(pts2d,1);
pts2d_BP = zeros(size(pts3d));
pt_source = [0,0,0];
f = 1;
for i = 1:nPoints2D
    pt_plane = [pts2d_nor(i,:) f];
    pt_3D = pts3d(i,:);
    pt_cross = calculatePointsOntoLine(pt_source,pt_plane,pt_3D);
    pts2d_BP(i,:) = pt_cross;
end
    
end

function pt = calculatePointsOntoLine(pt1,pt2,pt3)
%% calculate pt3 project onto line (pt1,pt2)
%     k *£¨P2   - P1£© =   P0 -   P1
%     k  = (P3 - P1) * (P2 - P1) / (|P2 - P1| * |P2 - P1|)
k = dot((pt3-pt1),(pt2-pt1)) / (norm(pt2-pt1)^2);
pt = k * (pt2-pt1) + pt1;
end