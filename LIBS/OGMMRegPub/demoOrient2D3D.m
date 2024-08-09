%%=====================================================================
%% Demo for 2D/3D point cloud registration
%% $Author: nbaka $
%% $Date: 2013-11-15 17:16:51 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

% This file will run GMM and OGMM registrations 10 times on randomly created artificial datasets.
% You see each result displayed. Blue is the target dataset, red is the initialization,
% green is the GMM and magenta is the OGMM result.
% A summary at the end shows the convergence rate with both methods, and median point to point accuracies. 

close all;
clear;
for iIter = 1:10
    %% make 3D oriented point clouds (a vessel, with two bifurcations. The scene also has a noise line not present in the model.)
    dim = 3;
    
    % Create 3D point set resembling a vessel with 2 bifurcations
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
    
    % project the 3D point set to plane
    plane.sourcePoint = [0,0,1000];
    plane.planeToWorldMatrix = diag([1,1,1,1]);
    scene2D = projectPointsToPlane(cart2homo(scene'),plane)';
       
    % add a line to the scene that is not present in the 3D point set
    start = .5*ones(1,2);
    dirVec = randn(1,2);
    dirVec = dirVec ./ (norm(dirVec));
    for iPoint = 1:30
        noise(iPoint,:) = start + dirVec * iPoint;
    end
    scene2DNoisy = [scene2D;noise];
    
    % calculate orientation knowing that the point cloud is ordered
    sceneOrient = scene2DNoisy - [scene2DNoisy(2:end,:);zeros(1,2)];
    sizeDirScene = normPerVector(sceneOrient,2);
    troublePoints = find(sizeDirScene > 10);
    if numel(troublePoints)>0
        sceneOrient(troublePoints,:) = sceneOrient(max(2,troublePoints -1),:);
        sizeDirScene(troublePoints,:) = sizeDirScene(max(2,troublePoints -1),:);
    end
    sceneOrient = sceneOrient./repmat(sizeDirScene,1,2);
    
    % moving pointset
    selPoints = [false(50,1);true(50,1);false(10,1);true(10,1);false(20,1)];
    moving = scene(selPoints,:);
    moving = transform_pointset(moving,'rigid',[.05*randn(1),.05*randn(1),.05*randn(1),1,randn(1,3)*5]);
    
    % display configuration
    figure(1); clf; plot(scene2DNoisy(:,1),scene2DNoisy(:,2),'b.');
    moving2D =  projectPointsToPlane(cart2homo(moving'),plane)';
    hold on; plot(moving2D(:,1),moving2D(:,2),'r+');
    
    %% Register the two point sets
    scales = [15,5,.5];
    initParam = [0,0,0,1,0,0,0];
    
    % without orientation
    [param,regPoints] = GMMReg(moving,scene2DNoisy,scales,'rigid',initParam,'orient',0,'projPlane',plane,'objFunWeight',.3);
    regPoints2D =  projectPointsToPlane(cart2homo(regPoints'),plane)';
    accGMM(iIter) = mean(normPerVector(scene2D(selPoints,:) - regPoints2D,2)); % point-to-point distance in 2D
    figure(1);plot(regPoints2D(:,1),regPoints2D(:,2),'g+');
    
    % with orientation
    [paramO,regPointsO] = GMMReg(moving,[scene2DNoisy,scene Orient],scales,'rigid',initParam,'orient',2,'sigmaOrient',.2,'projPlane',plane,'objFunWeight',.3);
    regPoints2DO =  projectPointsToPlane(cart2homo(regPointsO'),plane)';
    accOGMM(iIter) = mean(normPerVector(scene2D(selPoints,:) - regPoints2DO,2)); % point-to-point distance in 2D
    figure(2 );plot(regPoints2DO(:,1),regPoints2DO(:,2),'mx');
    
end
%% Evaluate differences in the method performances
% convergence rate
convRateGMM = sum(accGMM<2)/numel(accGMM)
convRateOGMM = sum(accOGMM<2)/numel(accOGMM)
% median accuracy
medianGMM = median(accGMM)
medianOGMM = median(accOGMM)