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
nl= 2;
npts= [10,100:100:2000];
num= 500;

% compared methods
A= zeros(size(npts));
B= zeros(num,1);

name= {'LHM', 'EPnP+GN', 'RPnP', 'DLS',          'OPnP', 'ASPnP', 'SDP',    'PPnP', 'EPPnP', 'REPPnP'};
f= {    @LHM, @EPnP_GN,  @RPnP, @robust_dls_pnp, @OPnP, @ASPnP,   @GOP,     @PPnP, @EPPnP, @REPPnP};
marker= { 'x', 's',      'd',      '^',            '>',   '<',      'v',      '*','+','o'};
color= {'r',   'g',      [1,0.5,0],'m',            'c',   'b',      'y',      [1,0.5,1],'k','k'};
markerfacecolor=  {'r','g',[1,0.5,0],'m',          'c',   'b',      'y',      'n','n','n'};


method_list= struct('name', name, 'f', f, 'mean_r', A, 'mean_t', A,...
    'med_r', A, 'med_t', A, 'std_r', A, 'std_t', A, 'r', B, 't', B,...
    'marker', marker, 'color', color, 'markerfacecolor', markerfacecolor);

% experiments
for i= 1:length(npts)
    
    npt= npts(i);
    fprintf('npt = %d (sg = %d px): ', npt, nl);
   
    
     for k= 1:length(method_list)
        method_list(k).c = zeros(1,num);
        method_list(k).e = zeros(1,num);
        method_list(k).r = zeros(1,num);
        method_list(k).t = zeros(1,num);
    end
    
    %index_fail = [];
    index_fail = cell(1,length(name));
    
    XXw = zeros(3,npts(i),num);
    xxn = zeros(2,npts(i),num);

    for j= 1:num
        
        % camera's parameters
        width= 640;
        height= 480;
        f= 800;
        
        % generate 3d coordinates in camera space
        Xc= [xrand(1,npt,[-2 2]); xrand(1,npt,[-2 2]); xrand(1,npt,[4 8])];
        t= mean(Xc,2);
        R= rodrigues(randn(3,1));
        XXw(:,:,j)= inv(R)*(Xc-repmat(t,1,npt));
        
        % projection
        xx= [Xc(1,:)./Xc(3,:); Xc(2,:)./Xc(3,:)]*f;
        randomvals = randn(2,npt);
        xxn(:,:,j)= xx+randomvals*nl;
    end
    
    
    % pose estimation
    for k= 1:length(method_list)
        tic;
        for j=1:num
            try
                [R1,t1]= method_list(k).f(XXw(:,:,j),xxn(:,:,j)/f);
            catch
            end
        end
        tcost = toc;
        method_list(k).mean_c(i)= tcost * 1000/num;
    
        showpercent(k,length(method_list));
    
    end
    
    
    
    fprintf('\n');
    
end

save ordinary3DresultsTime method_list npts;

plotOrdinary3DTime;