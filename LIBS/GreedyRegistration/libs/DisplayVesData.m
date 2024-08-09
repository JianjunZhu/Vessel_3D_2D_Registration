function DisplayVesData(VesData)
VesselPoints = VesData.VesselPoints;
VesselPoints_Sparse = VesData.VesselPoints_Sparse;
E = VesData.Graph;
dim = size(VesselPoints,2);
[counts,~]=size(VesselPoints);


%%

linewidth = 2;
x = VesselPoints;
xx = VesselPoints_Sparse;
figure;hold on; axis off;
if dim == 2
    scsize = 60;
    dispColor = [234, 45, 45]/255;
    
    for i = 1:counts
        for j = 1:counts
            if E(i,j) >= 1
                plot([x(i,1),x(j,1)],[x(i,2),x(j,2)],'Color',dispColor,'LineWidth',linewidth);
            end
        end
    end
    scatter(xx(:,1),xx(:,2),scsize,[0,0,1],'filled');
end

if dim == 3
    scsize = 60;
    dispColor = [67, 204, 128]/255;
    
    for i = 1:counts
        for j = 1:counts
            if E(i,j) >= 1
                plot3([x(i,1),x(j,1)],[x(i,2),x(j,2)],[x(i,3),x(j,3)],'Color',dispColor,'LineWidth',linewidth);
            end
        end
    end
    scatter3(xx(:,1),xx(:,2),xx(:,3),scsize,[0,0,1],'filled');
    view(-60,60);box on;
end

axis equal;    
set(gca,'ydir','reverse');
drawnow;