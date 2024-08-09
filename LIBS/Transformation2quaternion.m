function quat = Transformation2quaternion(T)
R = T(1:3,1:3);
t = T(1:3,4)';
S = 'XYZ';
[r1,r2,r3]=dcm2angle(R);
q =angle2quat(r1,r2,r3);

quat = [q t];