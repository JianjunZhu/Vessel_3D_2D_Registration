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
nl= 0;
npts  = 500; % must be a scalar   % [ 6, 8, 10, 15, 20, 35, 50, 75, 100];

% camera's parameters
width   = 640;
height  = 480;
f       = 800;
            
% generate 3d coordinates in camera space
Xc  = [xrand(1,npts,[-2 2]); xrand(1,npts,[-2 2]); xrand(1,npts,[4 8])];
t   = mean(Xc,2);
R   = rodrigues(randn(3,1));
XXw = inv(R)*(Xc-repmat(t,1,npts));

% projection
xx  = [Xc(1,:)./Xc(3,:); Xc(2,:)./Xc(3,:)]*f;
xxn = xx+randn(2,npts)*nl;
xxn = xxn;


[M, Cw, Alph] = PrepareData(XXw,xxn/f);
Km=kernel_noise(M,1); %Compute kernel M

pouts = [0.01:0.01:0.90];
res1 = zeros(1,length(pouts)+1);
res2 = zeros(1,length(pouts)+1);
res3 = zeros(1,length(pouts)+1);

res1(1) = mean(abs(Km' * M(1:200,:)'));
res2(1) = 0;%sum(abs(Km' * M(201:end,:)'));
res3(1) = 0;
res4(1) = 1;

pnout = 0;
for i = 1:length(pouts)
        npt  = npts;
        pout = pouts(i);
        nout = max(1,round((npt * pout)/(1-pout)));
        idx  = randi(npt,1,nout-pnout);
        XXwo = XXw(:,idx);
        
        % assignation of random 2D correspondences
        xxo  = [xrand(1,nout-pnout,[-width/2 width/2]); xrand(1,nout-pnout,[-height/2 height/2])];
            
           
        [M, Cw, Alph] = PrepareData([XXw, XXwo],[xxn, xxo]/f);
        tKm=kernel_noise(M,1); %Compute kernel M  
        
        res1(i+1) = mean(sqrt(sum(reshape(tKm' * M(1:npts*2,:)',2,npts).^2)));
        res2(i+1) = mean(sqrt(sum(reshape(tKm' * M(npts*2+1:end,:)',2,nout).^2)));
        
        res3(i+1) = min(norm(Km - tKm),norm(Km + tKm))*100;
        res4(i+1) = abs(Km' * tKm);
        
        XXw = [XXw, XXwo];
        xxn = [xxn, xxo];
        
        pnout = nout;
        
end

figure;plot([0 pouts*100],res3,'k','LineWidth',2)
set(gcf,'position',[1,100,300,300])
set(gcf,'color','w')
axis([0,90,0,15])
xlabel('% of Outliers')
ylabel('Null Space Differences (%)')

%figure;plot([0 pouts*100],res4,'k','LineWidth',2)

res2 = res2(2:end);
figure;plot([0 pouts],res1,'k','LineWidth',2)
hold on;plot(pouts,res2,'k','LineWidth',2)
set(gcf,'position',[1,100,300,300])
axis([0,0.9,0,0.2])
set(gcf,'color','w')
xlabel('% of Outliers')
ylabel('Median Algebraic Error')

