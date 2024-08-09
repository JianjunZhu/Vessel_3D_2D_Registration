function DisplayRealRegResultNew(VesData3D,VesData2D,varargin)
%%
titleName = [];Save_Path = []; visible = [];
for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'title'
            titleName = varargin{i+1};
        case 'SavePath'
            Save_Path = varargin{i+1};
        case 'visible'
            visible = varargin{i+1};
    end
end
%% Basic Display
VesData2D_Proj = ProjectVesselData(VesData3D,VesData2D.K);
h = figure;imshow(VesData2D.img_src,'border','tight','initialmagnification','fit');
img_size = size(VesData2D.img_src);

hold on;axis equal;
color1 = [238,44,44]/256;
color2 = [67,205,128]/256;

branches = TravesalGraphBranch(VesData2D.Graph,1,0);
for i = 1:numel(branches)
    branchIDs = branches{i};
    X = []; Y = [];
    for j = 1:length(branchIDs)
        X = [X,VesData2D.VesselPoints(branchIDs(j),1)];
        Y = [Y,VesData2D.VesselPoints(branchIDs(j),2)];
    end
    plot(X,Y,'Color',color1,'LineWidth',5);
end

branches = TravesalGraphBranch(VesData2D_Proj.Graph,1,0);
for i = 1:numel(branches)
    branchIDs = branches{i};
    X = []; Y = [];
    for j = 1:length(branchIDs)
        X = [X,VesData2D_Proj.VesselPoints(branchIDs(j),1)];
        Y = [Y,VesData2D_Proj.VesselPoints(branchIDs(j),2)];
    end
    plot(X,Y,'Color',color2,'LineWidth',5);
end

hold off;
axis([0 img_size(1) 0 img_size(2)]);
set (gcf,'Position',[0,0,img_size(1),img_size(2)]);
axis normal;
%% 
if ~isempty(titleName)
    title(titleName);
end
drawnow;
%% Save
if ~isempty(Save_Path)
    print(h, '-dpng', Save_Path);
end
if visible == 0
    close(gcf);
end


