% Makefile.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-20-2012
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-07-2013

path0 = cd;

cd 'lib/cell';
mex cellss.cpp;
mex oness.cpp;
mex zeross.cpp;
cd(path0);

cd 'src/asg/fgm/matrix';
mex multGXH.cpp;
mex multGXHS.cpp;
mex multGXHSQ.cpp;
mex multGXHSQTr.cpp;
cd(path0);

% cd 'src/asg/smac/graph_matching_SMAC';
% compileDir;
% cd(path0);
cd 'src/asg/smac/graph_matching_SMAC/cpp';
mex -largeArrayDims mex_ICM_graph_matching.cpp
mex -largeArrayDims mex_classes2indexes.cpp
mex -largeArrayDims mex_computeRowSum.cpp
mex -largeArrayDims mex_find_next_nonzero.cpp
mex -largeArrayDims mex_ind2rgb8.cpp
mex -largeArrayDims mex_ind2sub.cpp
mex -largeArrayDims mex_istril.cpp
mex -largeArrayDims mex_matchingW2.cpp
mex -largeArrayDims mex_normalizeColumns.cpp
mex -largeArrayDims mex_normalizeMatchingW.cpp
mex -largeArrayDims mex_projection_QR_symmetric.cpp
mex -largeArrayDims mex_projection_affine_symmetric.cpp
mex -largeArrayDims mex_w_times_x_symmetric_tril.cpp
mex -largeArrayDims spmtimesd.cpp
cd(path0);

cd 'src/asg/hun';
mex assignmentoptimal.cpp;
mex mex_normalize_bistochastic.cpp;
cd(path0);
