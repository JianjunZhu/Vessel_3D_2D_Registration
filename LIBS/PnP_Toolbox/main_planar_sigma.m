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

% experimental parameters
nls   = [0:20];
npts  = 30; % must be a scalar
num= 500;

% compared methods
A= zeros(size(npts));
B= zeros(num,1);
name= {'LHM', 'EPnP', 'RPnP', 'DLS',          'OPnP', 'ASPnP',    'PPnP', 'EPPnP', 'REPPnP'};
f= {    @LHM, @EPnP_planar,  @RPnP, @robust_dls_pnp, @OPnP, @ASPnP,     @PPnP, @EPPnP_planar, @REPPnP_planar};
marker= { 'x', 's',      'd',      '^',            '>',   '<',            '*','+','o'};
color= {'r',   'g',      [1,0.5,0],'m',            'c',   'b',            [1,0.5,1],'k','k'};
markerfacecolor=  {'r','g',[1,0.5,0],'m',          'c',   'b',            'n','n','n'};

method_list= struct('name', name, 'f', f, 'mean_r', A, 'mean_t', A,...
    'med_r', A, 'med_t', A, 'std_r', A, 'std_t', A, 'r', B, 't', B,...
    'marker', marker, 'color', color, 'markerfacecolor', markerfacecolor);

% experiments
for i= 1:length(nls)
    
    npt  = npts;
    nl = nls(i);
    fprintf('npt = %d (sg = %d px): ', npt, nl);
   
    
     for k= 1:length(method_list)
        method_list(k).c = zeros(1,num);
        method_list(k).e = zeros(1,num);
        method_list(k).r = zeros(1,num);
        method_list(k).t = zeros(1,num);
    end
    
    index_fail = cell(1,length(name));
    
    for j= 1:num
        
        % camera's parameters
        width= 640;
        height= 480;
        f= 800;
        
        % generate 3d coordinates in camera space
        XXw= [xrand(2,npt,[-2 2]); zeros(1,npt)];
		R= rodrigues(randn(3,1));
        t= [rand-0.5;rand-0.5;rand*8+4];
        Xc= R*XXw+repmat(t,1,npt);
        
        % projection
        xx= [Xc(1,:)./Xc(3,:); Xc(2,:)./Xc(3,:)]*f;
        randomvals = randn(2,npt);
        xxn= xx+randomvals*nl;
		  
        % pose estimation
        for k= 1:length(method_list)
            try
                tic;
                [R1,t1]= method_list(k).f(XXw,xxn/f);
                tcost = toc;
            catch
                disp(['The solver - ',method_list(k).name,' - encounters internal errors!!!']);
                %index_fail = [index_fail, j];
                index_fail{k} = [index_fail{k}, j];
                break;
            end
            
            %no solution
            if size(t1,2) < 1
                disp(['The solver - ',method_list(k).name,' - returns no solution!!!']);
                %index_fail = [index_fail, j];
                index_fail{k} = [index_fail{k}, j];
                break;
            elseif (sum(sum(sum(imag(R1).^2))>0) == size(R1,3) || sum(sum(imag(t1(:,:,1)).^2)>0) == size(t1,2))
                index_fail{k} = [index_fail{k}, j];
                continue;
            end
            %choose the solution with smallest error 
            error = inf;
            for jjj = 1:size(R1,3)
                tempy = cal_pose_err([R1(:,:,jjj) t1(:,jjj)],[R t]);
                if sum(tempy) < error
                    cost  = tcost;
                    ercorr= mean(sqrt(sum((R1(:,:,jjj) * XXw +  t1(:,jjj) * ones(1,npt) - Xc).^2)));
                    y     = tempy;
                    error = sum(tempy);
                end
            end
            
            method_list(k).c(j)= cost * 1000;
            method_list(k).e(j)= ercorr;
            method_list(k).r(j)= y(1);
            method_list(k).t(j)= y(2);
        end

        showpercent(j,num);
    end
    fprintf('\n');
    
    % save result
    for k= 1:length(method_list)
       %results without deleting solutions
            tmethod_list = method_list(k);
            method_list(k).c(index_fail{k}) = [];
            method_list(k).e(index_fail{k}) = [];
            method_list(k).r(index_fail{k}) = [];
            method_list(k).t(index_fail{k}) = [];

            % computational cost should be computed in a separated procedure as
            % in main_time.m
            
            method_list(k).pfail(i) = 100 * numel(index_fail{k})/num;
            
            method_list(k).mean_c(i)= mean(method_list(k).c);
            method_list(k).mean_e(i)= mean(method_list(k).e);
            method_list(k).med_c(i)= median(method_list(k).c);
            method_list(k).med_e(i)= median(method_list(k).e);
            method_list(k).std_c(i)= std(method_list(k).c);
            method_list(k).std_e(i)= std(method_list(k).e);

            method_list(k).mean_r(i)= mean(method_list(k).r);
            method_list(k).mean_t(i)= mean(method_list(k).t);
            method_list(k).med_r(i)= median(method_list(k).r);
            method_list(k).med_t(i)= median(method_list(k).t);
            method_list(k).std_r(i)= std(method_list(k).r);
            method_list(k).std_t(i)= std(method_list(k).t);
           
            %results deleting solutions where not all the methods finds one
            tmethod_list.c(unique([index_fail{:}])) = [];
            tmethod_list.e(unique([index_fail{:}])) = [];
            tmethod_list.r(unique([index_fail{:}])) = [];
            tmethod_list.t(unique([index_fail{:}])) = [];
            
            method_list(k).deleted_mean_c(i)= mean(tmethod_list.c);
            method_list(k).deleted_mean_e(i)= mean(tmethod_list.e);
            method_list(k).deleted_med_c(i)= median(tmethod_list.c);
            method_list(k).deleted_med_e(i)= median(tmethod_list.e);
            method_list(k).deleted_std_c(i)= std(tmethod_list.c);
            method_list(k).deleted_std_e(i)= std(tmethod_list.e);

            method_list(k).deleted_mean_r(i)= mean(tmethod_list.r);
            method_list(k).deleted_mean_t(i)= mean(tmethod_list.t);
            method_list(k).deleted_med_r(i)= median(tmethod_list.r);
            method_list(k).deleted_med_t(i)= median(tmethod_list.t);
            method_list(k).deleted_std_r(i)= std(tmethod_list.r);
            method_list(k).deleted_std_t(i)= std(tmethod_list.t);
    end
end

save planar3DresultsSigma method_list npt nls;

plotPlanar3Dsigmas;