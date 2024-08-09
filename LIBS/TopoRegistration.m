function [VesData3D_Reg_Rigid,VesData3D_Reg_Nonrigid,R,t]  = TopoRegistration(VesData3D,VesData2D,config)
%%
global g_CorrCell;
g_CorrCell = {};
if isfield(config,'redundant')
    redundant = config.redundant;
else
    redundant = 1;
end
%%
VesData3D_Reg_Rigid = [];
VesData3D_Reg_Nonrigid = [];
K = VesData2D.K;
VesData3D_Trans = VesData3D;

%% Rigid registration
if strcmp(config.Rigid,'On')
    for iter = 1:config.RigidnIteration
        
        disp(['--------------------- Rigid ',num2str(iter,'%02d'),'/',num2str(config.RigidnIteration,'%02d'),'------------------']);
       
        PnP = config.PnP;
        RigidParamterList = config.RigidParamterList;
        
        VesData3D_Proj = ProjectVesselData(VesData3D_Trans,VesData2D.K);
        VesData3D_Temp = VesData3D_Trans;
        Cor_Sparse= redundantMatching(VesData3D_Proj,VesData2D,redundant,RigidParamterList);
        Cor_Dense = fineGraphMatch(VesData3D_Proj,VesData2D,Cor_Sparse,RigidParamterList);
       
        [pts3d,pts2d,~] = GetCorrPoints(Cor_Dense,Cor_Sparse,VesData3D_Temp,VesData2D);
        [R,t,~] = myPnP(pts3d,pts2d,K,PnP);
        VesData3D_Trans = TransVesselData3D(VesData3D,[R,t],'normal');
        %% Display
        titleName = ['Rigid - ' num2str(iter)];
        if strcmp(config.Display,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'title',titleName);
        end
        if strcmp(config.DisplaySparseCorr,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'SparseCorr',Cor_Sparse,'title',titleName,'Label',1);
        end
        if strcmp(config.DisplayDenseCorr,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'DenseCorr',Cor_Dense,'title',titleName);
        end
 
    end
end
VesData3D_Trans = MyRefinement(VesData3D_Trans,VesData2D,0,{'ICP'});
VesData3D_Reg_Rigid = VesData3D_Trans;


%% Non-rigid Registration
if strcmp(config.Nonrigid,'On')
    
    %% build SSM
    if ~isfield(VesData3D_Trans,'PriorModel')
        PriorModel = GeneratePriorModel(VesData3D_Trans);
        VesData3D_Trans.PriorModel = PriorModel;
    end
    VesData3D_Trans = UpdateVesselPoints(VesData3D_Trans,VesData3D_Trans.VesselPoints);

    for iter = 1:config.NonrigidnIteration
        
        disp(['--------------------- NonRigid ',num2str(iter,'%02d'),'/',num2str(config.NonrigidnIteration,'%02d'),'------------------']);

        NonrigidParamterList = config.NonrigidParamterList;
       
       %% Matching
        Cor_Sparse = redundantMatching(VesData3D_Proj,VesData2D,redundant,NonrigidParamterList);
        Cor_Dense = fineGraphMatch(VesData3D_Proj,VesData2D,Cor_Sparse,[NonrigidParamterList,'Unique']);

        if isempty(Cor_Dense)
            continue;
        end

        pts3d = VesData3D_Temp.VesselPoints(Cor_Dense(:,1),:);
        pts2d = VesData2D.VesselPoints(Cor_Dense(:,2),:);
        pts2d_BP = BackProjectionNN(pts3d,pts2d,K);

        pts3dCorr = VesData3D_Temp.VesselPoints;
        pts3dCorr(Cor_Dense(:,1),:) = pts2d_BP;

        ssmParam = CalculateModelParam(VesData3D_Temp.PriorModel,pts3dCorr,VesData3D_Temp.quaternionPara);  
        pts3d_fit = GeneratePtsByPriorModel(VesData3D_Temp.PriorModel,ssmParam,VesData3D_Temp.quaternionPara);
        VesData3D_Trans = UpdateVesselPoints(VesData3D_Temp,pts3d_fit);

%         VesData3D_Trans = MyRefinement(VesData3D_Trans,VesData2D,0,{'DT'});
        %% Display
        titleName = ['NonRigid - ' num2str(iter)];
        if strcmp(config.Display,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'title',titleName);
        end
        if strcmp(config.DisplaySparseCorr,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'SparseCorr',Cor_Sparse,'title',titleName,'Label',1);
        end
        if strcmp(config.DisplayDenseCorr,'On')
            Display3DA2DVesselData(VesData3D_Trans,K,VesData2D,'DenseCorr',Cor_Dense,'title',titleName);
        end
          
    end
    VesData3D_Reg_Nonrigid = VesData3D_Trans;
end
