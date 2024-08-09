function R = getRotation(rot)

rot = rot.*pi/180;

Rx = [1 0 0; 0 cos(rot(1)) -sin(rot(1)); 0 sin(rot(1)) cos(rot(1))];
Ry = [cos(rot(2)) 0 sin(rot(2)); 0 1 0; -sin(rot(2)) 0 cos(rot(2))];
Rz = [cos(rot(3)) -sin(rot(3)) 0; sin(rot(3)) cos(rot(3)) 0; 0 0 1];

R = Rx*Ry*Rz;