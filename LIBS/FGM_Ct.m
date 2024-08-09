function [Cor_Sparse,X] = FGM_Ct(Eg1,Eg2,KP,KQ,Ct)

n = size(KP,1);
[G, H] = gphEg2IncA_zjj(Eg1, n);
gph1.Eg = Eg1;
gph1.G = G;
gph1.H = H;


n = size(KP,2);
[G, H] = gphEg2IncA_zjj(Eg2, n);
gph2.Eg = Eg2;
gph2.G = G;
gph2.H = H;

gphs{1} = gph1;
gphs{2} = gph2;

%% algorithm parameter
[pars, algs] = gmPar(2);
asgT.alg = 'truth';
asgT.X = Ct;

%% FGM-D
asgFgmD = fgmD(KP, KQ, Ct, gphs, asgT, pars{9}{:});
% showCor(gphs,asgFgmD);
X = asgFgmD.X;
[idxs_3d, idxs_2d] = find(X == 1);
Cor_Sparse = [idxs_3d,idxs_2d];