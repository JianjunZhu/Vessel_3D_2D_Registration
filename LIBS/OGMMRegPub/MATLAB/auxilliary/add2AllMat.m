function res = add2AllMat(a,b)
%%=====================================================================
%% $Author: nbaka $
%% $Date: 2013-11-15 12:51:37 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

n1 = size(a,1);
n2 = size(a,2);

nb1 = size(b,1);
nb2 = size(b,2);

if n1 == nb1
    if n2 == nb2
        res = a + b;
    else
        res = a + repmat(b,1,n2);
    end
elseif n2 == nb2
    res = a + repmat(b,n1,1);
else
    error('add2All: one of the dimensions of the inputs has to be the same!');
end