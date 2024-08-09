function cart = homo2cart(homo)
%%=====================================================================
%% homologue coordinates to cartesian ones
%% homo is a n X m matrix with m points in a n-1 dimensional space
%% $Author: nbaka $
%% $Date: 2013-11-15 16:35:56 +0100 (Fri, 15 Nov 2013) $
%%=====================================================================

cart = homo(1:end-1,:);