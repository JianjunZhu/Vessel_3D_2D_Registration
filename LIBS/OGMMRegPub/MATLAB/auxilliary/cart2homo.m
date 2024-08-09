
function homo = cart2homo(cart)
%%=====================================================================
%% cartesian coordinates to homolog ones
%% cart is a nXm matrix of m points in an n dimensional space
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

homo = [cart;ones(1,size(cart,2))];