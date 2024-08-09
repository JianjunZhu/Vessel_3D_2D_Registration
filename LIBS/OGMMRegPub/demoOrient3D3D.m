%%=====================================================================
%% Demo for 3D/3D oriented point cloud registration
%% $Author: nbaka $
%% $Date: 2013-11-15 17:16:51 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

% This file will run GMM and OGMM registrations 50 times on randomly created artificial datasets.
% You see each result displayed. Blue is the target dataset, red is the initialization,
% green is the GMM and magenta is the OGMM result. 
% A summary at the end shows the convergence rate with both methods, and median point to point accuracies. 


close all;
clear;
for iIter = 1:50
    %% make 3D oriented point clouds (a vessel, with two bifurcations. The scene also has a noise line not present in the model.)
    dim = 3;
    
    % scene point set
    sceneStart = zeros(1,dim);
    dirVec = [1,zeros(1,dim-1)];
    % main branch
    for iPoint = 1:80
        sceneMain(iPoint,:) = sceneStart + dirVec * iPoint;
    end
    % side branch 1
    startBranch = sceneMain(ceil(80*rand(1)),:);
    dirVec = randn(1,dim);
    dirVec = dirVec ./ norm(dirVec);
    for iPoint = 1:30
        sceneBranch1(iPoint,:) = startBranch + dirVec * iPoint;
    end
    % side branch 2
    startBranch = sceneMain(ceil(80*rand(1)),:);
    dirVec = randn(1,dim);
    dirVec = dirVec ./ norm(dirVec);
    for iPoint = 1:30
        sceneBranch2(iPoint,:) = startBranch + dirVec * iPoint;
    end
    scene = [sceneMain;sceneBranch1;sceneBranch2];
    % add a line to the scene that is not present in the moving point set
    start = .5*ones(1,3);
    dirVec = randn(1,3);
    dirVec = dirVec ./ (norm(dirVec));
    for iPoint = 1:30
        noise(iPoint,:) = start + dirVec * iPoint;
    end
    sceneNoisy = [scene;noise];
    
    % calculate orientation knowing that the point cloud is ordered
    sceneOrient = sceneNoisy - [sceneNoisy(2:end,:);zeros(1,dim)];
    sizeDirScene = normPerVector(sceneOrient,2);
    troublePoints = find(sizeDirScene > 10);
    if numel(troublePoints)>0
        sceneOrient(troublePoints,:) = sceneOrient(max(2,troublePoints -1),:);
        sizeDirScene(troublePoints,:) = sizeDirScene(max(2,troublePoints -1),:);
    end
    sceneOrient = sceneOrient./repmat(sizeDirScene,1,dim);
    
    % moving pointset
    selPoints = [false(50,1);true(50,1);false(10,1);true(10,1);false(20,1)];
    moving = scene(selPoints,:);
    moving = transform_pointset(moving,'rigid',[.1*randn(1),.1*randn(1),.1*randn(1),1,randn(1,3)*15]);
    
    % display configuration
    figure(1); clf; plot3(sceneNoisy(:,1),sceneNoisy(:,2),sceneNoisy(:,3),'b.');
    hold on; plot3(moving(:,1),moving(:,2),moving(:,3),'r.');
    
    %% Register the two point sets
    scales = [15,5,1];
    initParam = [0,0,0,1,0,0,0];
    
    % without orientation
    [param,regPoints] = GMMReg(moving,sceneNoisy,scales,'rigid',initParam,'orient',0);
    acc(iIter) = mean(normPerVector(scene(selPoints,:) - regPoints,2));
    figure(1);plot3(regPoints(:,1),regPoints(:,2),regPoints(:,3),'g+');
    
    % with orientation
    [paramO,regPointsO] = GMMReg(moving,[sceneNoisy,sceneOrient],scales,'rigid',initParam,'orient',2,'sigmaOrient',.2,'display',1);
    accO(iIter) = mean(normPerVector(scene(selPoints,:) - regPointsO,2));
    figure(1);plot3(regPointsO(:,1),regPointsO(:,2),regPointsO(:,3),'mx');
    
end
%% Evaluate differences in the method performances
% convergence rate
convRateGMM = sum(acc<2)/numel(acc)
convRateOGMM = sum(accO<2)/numel(accO)
% median accuracy
medianGMM = median(acc)
medianOGMM = median(accO)