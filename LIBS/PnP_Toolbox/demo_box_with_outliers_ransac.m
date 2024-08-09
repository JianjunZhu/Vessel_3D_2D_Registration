%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This toolbox illustrates how to use the REPPnP and EPPnP 
% algorithms described in:
%
%       Luis Ferraz, Xavier Binefa, Francesc Moreno-Noguer.
%       Very Fast Solution to the PnP Problem with Algebraic Outlier Rejection. 
%       In Proceedings of CVPR, 2014. 
%
% Copyright (C) <2014>  <Luis Ferraz, Xavier Binefa, Francesc Moreno-Noguer>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the version 3 of the GNU General Public License
% as published by the Free Software Foundation.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.       
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%
% Luis Ferraz, CMTech-UPF, June 2014.
% luisferrazc@gmail.com,http://cmtech.upf.edu/user/62
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
IniToolbox;

%load data 
load ./data/mymodel model
load ./data/mytest test

%inliers-3D points
U = test.modelcorresp(1:3,:); %set of features matched with the model


%inliers-2D points
pt = test.modelcorresp(6:7,:);
u = model.K \ [pt;ones(1,size(pt,2))];
u = u(1:2,:);

% compared methods
name= {'RNSC P3P','RNSC RP4P RPnP','RNSC P3P OPnP','RNSC P3P ASPnP', 'REPPnP'};
f = {@kP3P,@RPnP,@kP3P,@kP3P,@REPPnP};
f2 = {[],@RPnP,@OPnP,@ASPnP,[]}; %post ransac method
ransacsamples = {3,4,3,3,0}; %number of samples to apply ransac
marker= {'o','d','>','<','o'};
color= {'g',[1,0.5,0],'c','b','k'};
markerfacecolor=  {'g',[1,0.5,0],'c','b','n'};

method_list= struct('name', name, 'f', f,'f2', f2, 'ransac',ransacsamples,...
    'c', 0,...
    'mask_inliers',ones(1,size(u,2)),...
    'marker', marker, 'color', color, 'markerfacecolor', markerfacecolor);


%estimate camera pose 
disp('Each method is evaluated 100 times to compute the mean cost');
for k = 1:length(name)

    try
        %experiments are evaluated 10 times
        for i = 1:100
        if strcmp(method_list(k).name, 'REPPnP')
            sigmaerr = 10;
            coef     = 1.4;
            minerror = (coef * sigmaerr)/model.K(1);
            
            tic;
            mU = U - repmat(mean(U,2),1,size(U,2));
            [R1 t1, mask] = method_list(k).f(mU,u,minerror);
            t1 = t1 - R1 * mean(U,2);
            tcost = toc * 1000;
            method_list(k).mask_inliers = mask;
        else
          if (method_list(k).ransac == 0)
              tic;
              [R1,t1]= method_list(k).f(U,u);
              tcost = toc* 1000;
          else
              thr = 10;
              s = method_list(k).ransac;
              tic;
              [R1, t1, inliers] = ransac(model.K, U,pt, method_list(k).f, s, thr);
              
              if (~isempty(method_list(k).f2) && ~isempty(inliers))

                  [R1,t1]= method_list(k).f2(U(:,inliers),u(:,inliers));
              end
              tcost = toc * 1000;
              
              mask_inliers = zeros(1,size(u,2));
              mask_inliers(inliers) = 1;
              method_list(k).mask_inliers = mask_inliers;
          end
        end
         method_list(k).c = method_list(k).c + tcost;
        end
        
         method_list(k).c = method_list(k).c /100;
         
         percout = round(100 * (size(U,2)-numel(inliers))/size(U,2));
         disp([name{k} ' ->  detected outliers : ' num2str(percout) '% -> cost: ' num2str(method_list(k).c) ' ms ']);
         
    catch
        disp(['The solver - ',method_list(k).name,' - encounters internal errors!!!\n']);
        continue;
    end

    %no solution
    if size(t1,2) < 1
        disp(['The solver - ',method_list(k).name,' - returns no solution!!!\n']);
        continue;
    elseif (sum(sum(sum(imag(R1).^2))>0) == size(R1,3) || sum(sum(imag(t1(:,:,1)).^2)>0) == size(t1,2))
        continue;
    end
   
%     %plot solutions
%     for jjj = 1:size(R1,3)
%         %calculate the projection of vertices
%         v2d_i = model.K*(R1*model.templateV3D+t1*ones(1,8));
%         v2d_i = v2d_i./repmat(v2d_i(end,:),3,1);
%         v2d_i = v2d_i(1:2,:);
% 
%         %draw image
%         plotInlierOutlier([name{k} ' - ' num2str(method_list(k).c) ' ms '],test.modelcorresp(4:5,:),test.modelcorresp(6:7,:),....
%                           model.templateimage,test.inputimage,...
%                           method_list(k).mask_inliers,model.templateV2D,v2d_i,1);
%         
%     end  
end

%plot solution of REPPnP
  
%calculate the projection of vertices
v2d_i = model.K*(R1*model.templateV3D+t1*ones(1,8));
v2d_i = v2d_i./repmat(v2d_i(end,:),3,1);
v2d_i = v2d_i(1:2,:);

%draw image
plotInlierOutlier([name{k} ' - ' num2str(method_list(k).c) ' ms '],test.modelcorresp(4:5,:),test.modelcorresp(6:7,:),....
                          model.templateimage,test.inputimage,...
                          method_list(k).mask_inliers,model.templateV2D,v2d_i,1);
        
