%%=====================================================================
%% Demo for 2D/2D oriented point cloud registration
%% $Author: nbaka $
%% $Date: 2013-11-15 17:16:51 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

% This file will run GMM and OGMM registrations 50 times on a fish dataset with missing and added points. 
% You see each result displayed. Blue is the target dataset, red is the initialization,
% green is the GMM and magenta is the OGMM result.
% A summary at the end shows the convergence rate with both methods, and median point to point accuracies. 


close all;
clear;
whichFish = 1; % please choose between fish 0 and 1
for iIter = 1:50 % make 50 random registrations
    
    %% Create scene and moving point set using the fish data
    if whichFish
        fish_X = load('data\fish_data\fish_X_ordered.txt');
        scene = fish_X;
        selPoints = [false(10,1);true(78,1);false(10,1)]; % headless
    else
        fish_Y = load('data\fish_data\fish_Y_ordered.txt');
        scene = fish_Y;
        selPoints = [true(39,1);false(20,1);true(39,1);]; % tailless
    end
    % add a line to the scene that is not present in the moving point set
    start = .5*ones(1,2);
    dirVec = randn(1,2);
    dirVec = dirVec ./ (30*norm(dirVec));
    for iPoint = 1:30
        noise(iPoint,:) = start + dirVec * iPoint;
    end
    sceneNoisy = [scene;noise];
    
    % calculate orientation of the scene point set knowing that it is ordered
    sceneOrient = sceneNoisy - [sceneNoisy(2:end,:);zeros(1,2)];
    sizeDirScene = normPerVector(sceneOrient,2);
    troublePoints = find(sizeDirScene > 0.04);
    if numel(troublePoints)>0
        sceneOrient(troublePoints,:) = sceneOrient(max(2,troublePoints -1),:);
        sizeDirScene(troublePoints,:) = sizeDirScene(max(2,troublePoints -1),:);
    end
    sceneOrient = sceneOrient./repmat(sizeDirScene,1,2);
    
    % make the moving pointset by transforming part of the noise free scene
    moving = scene(selPoints,:);
    moving = transform_pointset(moving,'rigid',[1*randn(1,2),.5*randn(1)]);
    
    % show starting position of the fishes
    figure(1); clf; plot(sceneNoisy(:,1),sceneNoisy(:,2),'b.');
    hold on; plot(moving(:,1),moving(:,2),'r+');
    axis equal;
    
    %% Register the two pointsets
    scales = [1,.1,0.02];    
    initParam = [0,0,0];
    
    % without orientation
    [param,regPoints] = GMMReg(moving,sceneNoisy,scales,'rigid',initParam,'orient',0);
    acc(iIter) = mean(normPerVector(scene(selPoints,:) - regPoints,2)); % point-to-point accuracy
    figure(1);plot(regPoints(:,1),regPoints(:,2),'g+');
    
    % with orientation
    [paramO,regPointsO] = GMMReg(moving,[sceneNoisy,sceneOrient],scales,'rigid',initParam,'orient',2,'sigmaOrient',.3);
    accO(iIter) = mean(normPerVector(scene(selPoints,:) - regPointsO,2)); % point-to-point accuracy
    figure(1);plot(regPointsO(:,1),regPointsO(:,2),'mx');
    
end
%% Evaluate differences in the method performances
% convergence rate
convRateGMM = sum(acc<.1)/numel(acc)
convRateOGMM = sum(accO<.1)/numel(accO)
% median accuracy
medianGMM = median(acc)
medianOGMM = median(accO)