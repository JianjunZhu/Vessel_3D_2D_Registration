function img_centerline = centerlineToImage(VesselPoints,imgsize)
    img_centerline = false(imgsize);
    VesselPoints = uint16(VesselPoints);
    for i = 1:size(VesselPoints,1)
        
        x = VesselPoints(i,1); y = VesselPoints(i,2);
        if x < 1
            x = 1;
        elseif x > imgsize(2)
            x = imgsize(2);
        end
    
        if y < 1
            y = 1;
        elseif y > imgsize(1)
            y = imgsize(1);
        end
        
        img_centerline(y,x) = 1;
    end
end