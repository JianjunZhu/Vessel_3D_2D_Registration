function [f,g] = gmmreg_L2_costfunc_(param, config)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================
model = config.model;
scene = config.scene;
motion = config.motion;
scale = config.scale;
modelDim = config.dimModelPoints;
sceneDim = config.dimScenePoints;
orient = config.orient;

% for the translation weighting
 w = config.wTrans;
if modelDim == 2
    paramVal = param .* [w,w,1];
else
    paramVal = param .* [1,1,1,1,w,w,w];
end
[transformed_model] = transform_pointset(model, motion, paramVal);

if ((sceneDim ==2 ) || (sceneDim == 4)) % scene points two dimensional without or with orientation
      
        if modelDim == 2 % 2D/2D registration
            switch lower(config.motion)
                case 'translation'
                    if orient
                        [f,gr] = rigid_costfunc_orient(transformed_model,scene,scale,config);
                        grad = gr(:,1:2)';
                    else
                        [f,grad] = rigid_costfunc(transformed_model, scene, scale);
                        grad = grad';
                    end
                    g(1) = w*sum(grad(1,:));
                    g(2) = w*sum(grad(2,:));
                    g(3) = 0;
                case 'rigid'
                    if orient
                        [f,gr] = rigid_costfunc_orient(transformed_model,scene,scale,config);
                        grad = gr(:,1:2)';
                        A = model;
                        nDimA = size(A,2);
                        dirA = A - [A(2:end,:);zeros(1,nDimA)];
                        sizeDirA = normPerVector(dirA,2);
                        troublePoints = find(sizeDirA > 10);
                        if numel(troublePoints)>0
                            dirA(troublePoints,:) = dirA(max(2,troublePoints -1),:);
                            sizeDirA(troublePoints,:) = sizeDirA(max(2,troublePoints -1),:);
                        end
                        modelOrient = dirA./repmat(sizeDirA,1,nDimA);
                        gm2 = gr(:,3:4)' * modelOrient;
                    else
                        [f,grad] = rigid_costfunc(transformed_model, scene, scale);
                        grad = grad';
                        gm2 = 0;
                    end
                    g(1) = w*sum(grad(1,:));
                    g(2) = w*sum(grad(2,:));
                    grad = grad*model;
                    theta = param(3);
                    r = [-sin(theta) -cos(theta);
                        cos(theta)  -sin(theta)];
                    g(3) = sum(sum(grad.*r))  + sum(sum(gm2.*r));
                case 'affine'
                    if orient
                        [f,gr] = general_costfunc_orient(transformed_model, scene, scale);
                        grad = gr(:,1:3)';
                    else
                        [f,grad] = general_costfunc(transformed_model, scene, scale);
                        grad = grad';
                    end
                    g(1) = w*sum(grad(1,:));
                    g(2) = w*sum(grad(2,:));
                    g(3:6) = reshape(grad*model,1,4);
            end
            
        elseif modelDim == 3 % 2D/3D registration
            %[~,omegas,projMatrix0,norm0] =  projectPointsToPlane(cart2homo(transformed_model'),config.projPlane);
%             projMatrix = config.projMatrix;
%             projMatrix0 = projMatrix(1:2,:);
%             [~,omegas] = projectPointsByProjectMatrix(cart2homo(transformed_model'),config.projMatrix);
            
            if orient % for oriented point clouds
                [f,gr] = rigid_2d3d_costfunc_orient(transformed_model,scene,scale,config);
            else      % for non-oriented point clouds
                [f,gr] = rigid_2d3d_costfunc(transformed_model,scene,scale,config);
            end
            g = zeros(7,1);
            grad = gr(:,1:2);
            [r,gq] = quaternion2rotation(param(1:4));
%             meanPoint = mean(model,1);
%             gm = ((grad.*repmat(omegas',1,2))*projMatrix0(:,1:3))' * add2AllMat(model, - meanPoint); % because centralized rotation
%             grad_R = (projMatrix\cart2homo(grad'));
%             grad_R = grad_R(1:3,:);%./repmat(grad_R(4,:),3,1);
% %             gm = grad_R * model;%add2AllMat(model, - meanPoint);
%             
%             perspTerm1 = norm0(1) * sum((grad.*repmat(omegas'.^2,1,2) .* (projMatrix0 * cart2homo(transformed_model'))'),2);
%             perspTerm2 = norm0(2) * sum((grad.*repmat(omegas'.^2,1,2) .* (projMatrix0 * cart2homo(transformed_model'))'),2);
%             perspTerm3 = norm0(3) * sum((grad.*repmat(omegas'.^2,1,2) .* (projMatrix0 * cart2homo(transformed_model'))'),2);
            
            switch lower(config.motion)
                case 'translation'
                    g(1) = 0;
                    g(2) = 0;
                    g(3) = 0;
                    g(4) = 0;
                case 'rigid'
%                     g(1) = sum(sum(gm.*gq{1})) - sum(sum([perspTerm1,perspTerm2,perspTerm3]' * add2AllMat(model, - meanPoint) .* gq{1}));
%                     g(2) = sum(sum(gm.*gq{2})) - sum(sum([perspTerm1,perspTerm2,perspTerm3]' * add2AllMat(model, - meanPoint) .* gq{2}));
%                     g(3) = sum(sum(gm.*gq{3})) - sum(sum([perspTerm1,perspTerm2,perspTerm3]' * add2AllMat(model, - meanPoint) .* gq{3}));
%                     g(4) = sum(sum(gm.*gq{4})) - sum(sum([perspTerm1,perspTerm2,perspTerm3]' * add2AllMat(model, - meanPoint) .* gq{4}));
%                     g(1) = sum(sum(gm.*gq{1})); 
%                     g(2) = sum(sum(gm.*gq{2})); 
%                     g(3) = sum(sum(gm.*gq{3})); 
%                     g(4) = sum(sum(gm.*gq{4}));     
%                     g(5) = sum(grad_R(1,:));
%                     g(6) = sum(grad_R(2,:));
%                     g(7) = sum(grad_R(3,:));
                case 'affine'
                    error('gmmreg_L2_costfunc: 2D/3D affine registration is not implemented! Use rigid instead.');
            end
            
%             g(5) = w*(sum((grad.*repmat(omegas',1,2))*projMatrix0(:,1)) - sum(perspTerm1));
%             g(6) = w*(sum((grad.*repmat(omegas',1,2))*projMatrix0(:,2)) - sum(perspTerm2));
%             g(7) = w*(sum((grad.*repmat(omegas',1,2))*projMatrix0(:,3)) - sum(perspTerm3));
        end
        
elseif ((sceneDim ==3) ||(sceneDim == 6))  % 3D/3D matching with or without orientation
    switch lower(config.motion)
            case 'translation'
                if orient
                    [f,gr] = rigid_costfunc_orient(transformed_model,scene,scale,config);
                    grad = gr(:,1:3)';
                else
                    [f,grad] = rigid_costfunc(transformed_model, scene, scale);
                    grad = grad';
                end
                g(1) = 0;
                g(2) = 0;
                g(3) = 0;
                g(4) = 0;
                g(5) = w*sum(grad(1,:));
                g(6) = w*sum(grad(2,:));
                g(7) = w*sum(grad(3,:));
                
            case 'rigid'
                if orient
                    [f,gr] = rigid_costfunc_orient(transformed_model,scene,scale,config);
                    grad = gr(:,1:3)';
                    A = model;
                    nDimA = size(A,2);
                    dirA = A - [A(2:end,:);zeros(1,nDimA)];
                    sizeDirA = normPerVector(dirA,2);
                    troublePoints = find(sizeDirA > 10);
                    if numel(troublePoints)>0
                        dirA(troublePoints,:) = dirA(max(2,troublePoints -1),:);
                        sizeDirA(troublePoints,:) = sizeDirA(max(2,troublePoints -1),:);
                    end
                    modelOrient = dirA./repmat(sizeDirA,1,nDimA);
                    gm2 = gr(:,4:6)' * modelOrient;
                else
                    [f,grad] = rigid_costfunc(transformed_model, scene, scale);
                    grad = grad';
                    gm2 = 0;
                end
                [r,gq] = quaternion2rotation(param(1:4));
                meanPoint = mean(model,1);
                gm = grad * add2AllMat(model, - meanPoint); % because centralized rotation
                
                g(1) = sum(sum(gm.*gq{1})) + sum(sum(gm2.*gq{1}));
                g(2) = sum(sum(gm.*gq{2})) + sum(sum(gm2.*gq{2}));
                g(3) = sum(sum(gm.*gq{3})) + sum(sum(gm2.*gq{3}));
                g(4) = sum(sum(gm.*gq{4})) + sum(sum(gm2.*gq{4}));
                g(5) = w*sum(grad(1,:));
                g(6) = w*sum(grad(2,:));
                g(7) = w*sum(grad(3,:));
                
            case 'affine'
                if orient
                    [f,gr] = general_costfunc_orient(transformed_model, scene, scale);
                    grad = gr(:,1:3)';
                else
                    [f,grad] = general_costfunc(transformed_model, scene, scale);
                    grad = grad';
                end
                g(1) = w*sum(grad(1,:));
                g(2) = w*sum(grad(2,:));
                g(3) = w*sum(grad(3,:));
                g(4:12) = reshape(grad*model,1,9);                
                
            otherwise
                error('Unknown motion type');
        end
end




function [f, g] = rigid_costfunc(A, B, scale)
[f, g] =  GaussTransform(A,B,scale);
f = -f; g = -g;


function [f, g] = general_costfunc(A, B, scale)
[f1, g1] = GaussTransform(A,A,scale);
[f2, g2] = GaussTransform(A,B,scale);
f =  f1 - 2*f2;
g = 2*g1 - 2*g2;

function [f,g] = rigid_2d3d_costfunc(A,B,scale,config)
if isempty(config.projMatrix)
    projPlane = config.projPlane;
    projPlane.sourcePoint = projPlane.sourcePoint';
    projA =  projectPointsToPlane(cart2homo(A'),projPlane)';
else
    projA = projectPointsByProjectMatrix(cart2homo(A'),config.projMatrix);
end
[f1, g1] =  GaussTransform(projA,B,scale);
[f2,g2] = GaussTransform(projA,projA,scale);

wF2 = config.wF2;
f = wF2*f2-2*f1;
g = wF2*2*g2-2*g1;
% % for figures
% lw = 2;
% figure(1000); clf; plot(B(:,1),B(:,2),'b.','markersize',10,'linewidth',lw);
% hold on; plot(projA(:,1),projA(:,2),'r+','markersize',10,'linewidth',lw);
% axis ij; axis equal;


function [f,g] = rigid_2d3d_costfunc_orient(A,B,scale,config)
if isempty(config.projMatrix)
    projPlane = config.projPlane;
    projPlane.sourcePoint = projPlane.sourcePoint';
    projA =  projectPointsToPlane(cart2homo(A'),projPlane)';
else
    projA = projectPointsByProjectMatrix(cart2homo(A'),config.projMatrix);
end
dirA2D = projA - [projA(2:end,:);[0,0]];
size2D = normPerVector(dirA2D,2);
troublePoints = find(size2D > 20);
if numel(troublePoints)>0
    dirA2D(troublePoints,:) = dirA2D(max(2,troublePoints -1),:);
    size2D(troublePoints,:) = size2D(max(2,troublePoints -1),:);
end
dirA2D = dirA2D./repmat(size2D,1,2);
combinedA = [projA,dirA2D];
Bmirrored = B;
Bmirrored(:,3:4) = -Bmirrored(:,3:4);

orientScale = config.sigmaOrient;

[f1, g1] = mexkernelInnerProductEuclid(combinedA,[B;Bmirrored],[scale,scale,orientScale,orientScale],[config.weightMatrixCell{1},config.weightMatrixCell{1}]);
[f2,g2] = mexkernelInnerProductEuclid(combinedA,combinedA,[scale,scale,orientScale,orientScale],config.weightMatrixCell{2});
% [f1, g1] = ExtendedkernelInnerProductEuclid(combinedA,[B;Bmirrored],[scale,scale,orientScale,orientScale],[config.weightMatrixCell{1},config.weightMatrixCell{1}]);
% [f2,g2] = ExtendedkernelInnerProductEuclid(combinedA,combinedA,[scale,scale,orientScale,orientScale],config.weightMatrixCell{2});
% [f1, g1] =  ExtendedGaussTransform(combinedA,[B;Bmirrored],[scale,scale,orientScale,orientScale]);
% [f2,g2] = ExtendedGaussTransform(combinedA,combinedA,[scale,scale,orientScale,orientScale]);

wF2 = config.wF2;
f = wF2*f2-2*f1;
g = wF2*2*g2-2*g1;

function [f1,g2]=mexkernelInnerProductEuclid(A,B,scale,WeightMatrix)
[f1,g2,ff] = mex_WeightGaussianTransform(A',B',scale,WeightMatrix');
g2 = g2';


function [f,g] = rigid_costfunc_orient(A,B,scale,config)
nDimA = size(A,2);
dirA = A - [A(2:end,:);zeros(1,nDimA)];
sizeDirA = normPerVector(dirA,2);
troublePoints = find(sizeDirA > 10);
if numel(troublePoints)>0
    dirA(troublePoints,:) = dirA(max(2,troublePoints -1),:);
    sizeDirA(troublePoints,:) = sizeDirA(max(2,troublePoints -1),:);
end
dirA = dirA./repmat(sizeDirA,1,nDimA);
combinedA = [A,dirA];

if config.orient == 2
    combinedB = B;
else
    Bmirrored = B;
    Bmirrored(:,nDimA+1:nDimA*2) = -Bmirrored(:,nDimA+1:nDimA*2);
    combinedB = [B;Bmirrored];
end
orientScale = config.sigmaOrient;
scaleVec = [repmat(scale,1,nDimA),repmat(orientScale,1,nDimA)];

[f1,g1] =  ExtendedGaussTransform(combinedA,combinedB,scaleVec);
f = -f1;
g = -g1;
% % for figures
% lw = 2;
% figure(1000); clf; quiver3(B(:,1),B(:,2),B(:,3),B(:,4),B(:,5),B(:,6),'b','linewidth',lw);
% hold on; quiver3(combinedA(:,1),combinedA(:,2),combinedA(:,3),combinedA(:,4),combinedA(:,5),combinedA(:,6),'r','linewidth',lw);
% axis ij; axis equal;
% for figures
% lw = 2;
% figure(1000); clf; quiver(B(:,1),B(:,2),B(:,3),B(:,4),'b','linewidth',lw);
% hold on; quiver(combinedA(:,1),combinedA(:,2),combinedA(:,3),combinedA(:,4),'r','linewidth',lw);
% axis ij; axis equal;


function [f,g] = general_costfunc_orient(A,B,scale,config)
nDimA = size(A,2);
dirA = A - [A(2:end,:);zeros(1,nDimA)];
sizeDirA = normPerVector(dirA,2);
troublePoints = find(sizeDirA > 10);
if numel(troublePoints)>0
    dirA(troublePoints,:) = dirA(max(2,troublePoints -1),:);
    sizeDirA(troublePoints,:) = sizeDirA(max(2,troublePoints -1),:);
end
dirA = dirA./repmat(sizeDirA,1,nDimA);
combinedA = [A,dirA];
if config.orient == 2
    combinedB = B;
else
    Bmirrored = B;
    Bmirrored(:,nDimA+1:nDimA*2) = -Bmirrored(:,nDimA+1:nDimA*2);
    combinedB = [B;Bmirrored];
end
orientScale = config.sigmaOrient;
scaleVec = [repmat(scale,1,nDimA),repmat(orientScale,1,nDimA)];

[f1,g1] =  ExtendedGaussTransform(combinedA,combinedB,scaleVec);
[f2,g2] = ExtendedGaussTransform(combinedA,combinedA,scaleVec);

f =  f1 - 2*f2;
g = 2*g1 - 2*g2;

