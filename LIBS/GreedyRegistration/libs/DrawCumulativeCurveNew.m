function DrawCumulativeCurveNew(DistMatrix,varargin)
Save_Path = []; visible = 1; titleName = []; Test = [];
for i = 1:2:numel(varargin)
    switch varargin{i}
        case 'SavePath'
            Save_Path = varargin{i+1};
        case 'title'
            titleName = varargin{i+1};
        case 'visible'
            visible = varargin{i+1};
        case 'Test'
            Test = varargin{i+1};
    end
end
nMethods = size(DistMatrix,2);
nPatient = size(DistMatrix,1);

% xVals = 0:1:25;
xVals = 0:0.2:3;
yVals = zeros(length(xVals),nMethods);
for iMethod = 1:nMethods
    Dists = DistMatrix(:,iMethod);
    for k = 1:length(xVals)
        yVals(k,iMethod) = sum(Dists<xVals(k))/nPatient; 
    end
end
yVals = yVals.*100;

h = figure;
plot(...
    xVals,yVals(:,1),'b-+',...
    xVals,yVals(:,2),'r--x',...
    xVals,yVals(:,3),'m-s',...
    xVals,yVals(:,4),'c:v',...
    xVals,yVals(:,5),'k-o',...
    xVals,yVals(:,6),'k-.+'...
    );
set(gca,'Fontname','Times New Roman','FontWeight','bold','FontSize',14);

legend('ICP-BP','DT','OGMM','Tree','GTSR','HTSR');

set(legend,'Position',[0.16 0.58 0.16 0.32],'Fontname','Times New Roman','FontWeight','bold','FontSize',14);
xlabel('Mean projected distance (mm)','Fontname','Times New Roman','FontWeight','bold','FontSize',15.6);
ylabel('Percentage (%)','Fontname','Times New Roman','FontWeight','bold','FontSize',15.6);
title(titleName,'Fontname','Times New Roman','FontWeight','bold','FontSize',15.6);
axis([0 3 0 100]);
grid on;
if ~isempty(Save_Path)
%     print(h, '-dpng', Save_Path);
    saveas(gcf,Save_Path);
end
if visible == 0
    close(gcf);
end
drawnow;