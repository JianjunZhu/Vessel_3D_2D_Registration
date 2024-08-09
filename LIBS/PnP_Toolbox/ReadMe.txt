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
%
% How to initialize: 
%	- enter inside the 'PnP_Toolbox' folder
%   - run IniToolbox.m procedure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Scripts to reproduce the synthetic experiment results:
% main_ordinary_3d:         Corresponding to Fig.3(a) Top.
% main_planar:              Corresponding to Fig.3(b) Top.
% main_ordinary_3d_sigma:   Corresponding to Fig.3(a) Down.
% main_planar_sigma:        Corresponding to Fig.3(b) Down.
% main_ordinary_3d_time:	Corresponding to Fig.4 Left.
% main_ordinary_3d_outliers:    	Corresponding to Fig.5 Down.
% main_ordinary_3d_outliers_ransac:	Corresponding to Fig.6 Top, and Fig.4 Right.                
% main_planar_outliers_ransac:      Corresponding to Fig.6 Down.
% plotEffectOutliersKernel:         Corresponding to Fig.5 Top.  
%
%
% Scripts to reproduce the expriments with real images:
% demo_box_with_outliers_ransac:    Corresponding to Fig.7 Top		
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Acknowledgements
%This toolbox is based on the toolbox provided in:
%
%Y. Zheng, Y. Kuang, S. Sugimoto, K. Astro ?m, and M. Oku-
%tomi. Revisiting the pnp problem: A fast, general and opti-
%mal solution. In ICCV, pages 4321?4328, 2013.
%
%Y. Zheng, S. Sugimoto, and M. Okutomi. Aspnp: An accu- 
%rate and scalable solution to the perspective-n-point problem. 
%Trans. on Information and Systems, 96(7):1525?1535, 2013.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

