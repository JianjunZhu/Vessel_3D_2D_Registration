function Display3DA2DVesselData(VesData3D,K,VesData2D,varargin)
%% Parse Input Parameters
Cor_Dense = []; Cor_Sparse = []; Save_Path = []; titleName = ''; label = []; visible = [];
if mod(numel(varargin),2) ~= 0
    disp('Display3DA2DVesselData Input Error \n');
    return;
end
for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'DenseCorr'
            Cor_Dense = varargin{i+1};
        case 'SparseCorr'
            Cor_Sparse = varargin{i+1};
        case 'SavePath'
            Save_Path = varargin{i+1};
        case 'title'
            titleName = varargin{i+1};
        case 'Label'
            label = varargin{i+1};
        case 'visible'
            visible = varargin{i+1};
    end
end

%% Basic Display
color1 = [238,44,44]/256;
color2 = [67,205,128]/256;

VesData2D_Proj = ProjectVesselData(VesData3D,K);

maxv = round(max(VesData2D.VesselPoints,[],1))+5;
minv = round(min(VesData2D.VesselPoints,[],1))-5;
h=figure;
% h=figure('Position',[0,0,maxv(1)-minv(1),maxv(2)-minv(2)]);

% set(gca,'position',[0 0 1 1]);

hold on;axis equal;
title(titleName);

%% basic display

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

% % scatter(VesData2D.VesselPoints(:,1),VesData2D.VesselPoints(:,2));
% counts = size(VesData2D.VesselPoints,1);
% for i = 1:counts
%     for j = 1:counts
%         if VesData2D.Graph(i,j) >= 1
%             plot([VesData2D.VesselPoints(i,1),VesData2D.VesselPoints(j,1)], ...
%                 [VesData2D.VesselPoints(i,2),VesData2D.VesselPoints(j,2)],'Color',color1,'LineWidth',5);
%         end
%     end
% end
% % scatter(VesData2D_Proj.VesselPoints(:,1),VesData2D_Proj.VesselPoints(:,2));
% counts = size(VesData2D_Proj.VesselPoints,1);
% for i = 1:counts
%     for j = 1:counts
%         if VesData2D_Proj.Graph(i,j) >= 1
%             plot([VesData2D_Proj.VesselPoints(i,1),VesData2D_Proj.VesselPoints(j,1)], ...
%                 [VesData2D_Proj.VesselPoints(i,2),VesData2D_Proj.VesselPoints(j,2)],'Color',color2,'LineWidth',5);
%         end
%     end
% end

%% Display label
if ~isempty(label)
    for i = 1:size(VesData2D.NodeIdxs,2)
        id = VesData2D.NodeIdxs(i);
        scatter(VesData2D.VesselPoints(id,1),VesData2D.VesselPoints(id,2));
        text(VesData2D.VesselPoints(id,1),VesData2D.VesselPoints(id,2),num2str(i));
    end
    
    for i = 1:size(VesData2D_Proj.NodeIdxs,2)
        id = VesData2D_Proj.NodeIdxs(i);
        scatter(VesData2D_Proj.VesselPoints(id,1),VesData2D_Proj.VesselPoints(id,2));
        text(VesData2D_Proj.VesselPoints(id,1),VesData2D_Proj.VesselPoints(id,2),num2str(i));
    end
end



%% Display Dense Correspondense
if ~isempty(Cor_Dense)
    cor1 = Cor_Dense(:,1);
    cor2 = Cor_Dense(:,2);
    for i = 1:1:max(size(cor1))
        pt1 = VesData2D_Proj.VesselPoints(cor1(i),:);
        pt2 = VesData2D.VesselPoints(cor2(i),:);
        plot([pt1(1),pt2(1)],[pt1(2),pt2(2)],'Color',[0,0,0]);
    end 
end
%% Display Sparse Correspondense
if ~isempty(Cor_Sparse)
    cor1 = Cor_Sparse(:,1);
    cor2 = Cor_Sparse(:,2);
    for i = 1:max(size(cor1))
        if cor1(i)==0 || cor2(i)==0
            continue;
        end
        pt1 = VesData2D_Proj.VesselPoints_Sparse(cor1(i),:);
        pt2 = VesData2D.VesselPoints_Sparse(cor2(i),:);
        plot([pt1(1),pt2(1)],[pt1(2),pt2(2)],'Color',[0,0,0]);
    end 
end

hold off;
% 
% axis([minv(1) maxv(1) minv(2) maxv(2)]);
% axis off;
set(gca,'ydir','reverse');
drawnow;
%% Save
if ~isempty(Save_Path)
    saveas(gcf,Save_Path);
%     print(h, '-dpng', Save_Path);
end
if visible == 0
    close(gcf);
end
