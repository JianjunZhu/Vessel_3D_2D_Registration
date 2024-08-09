function VesData3D_Trans = MyRefinement(VesData3D,VesData2D,RigidOrNot,RefinementParameter)
VesData3D_Trans = VesData3D;
for i = 1:numel(RefinementParameter)
    refine = RefinementParameter{i};
    switch refine
        case 'Tree'
            VesData3D_Trans = tree_topo_3DA2D_registration(VesData3D_Trans,VesData2D,0,[1,1]);
        case 'ICP'
%             VesData3D_Trans = ICP_3D2D(VesData3D_Trans,VesData2D,'BackProjection');
            VesData3D_Trans = ICP_3D2D(VesData3D_Trans,VesData2D,0,'PnP');
        case 'ORGMM'
            VesData3D_Trans = ORGMM_Method(VesData3D_Trans,VesData2D,RigidOrNot);
        case 'DT'
            VesData3D_Trans = DT_3D2DReg(VesData3D_Trans,VesData2D,RigidOrNot);
    end
end