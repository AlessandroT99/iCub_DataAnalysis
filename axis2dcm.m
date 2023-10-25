% Copyright: (C) 2023 Istituto Italiano di Tecnologia
%
% Source: yarp::math::axis2dcm()
%
% Permission is granted to copy, distribute, and/or modify this program
% under the terms of the GNU General Public License, version 2 or any
% later version published by the Free Software Foundation.
% 
% A copy of the license can be found at
% http://www.robotcub.org/icub/license/gpl.txt
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details

function rotMatrix = axis2dcm(ax,ay,az,theta)
% This function is used to transform the axis/angle format used to pack
% this data into the rotation matrix needed
    rotMatrix = eye(3);
    v = [ax,ay,az,theta];

    c = cos(theta);
    s = sin(theta);
    C = 1-c;

    xs =v(1)*s;
    ys =v(2)*s;
    zs =v(3)*s;
    xC =v(1)*C;
    yC =v(2)*C;
    zC =v(3)*C;
    xyC=v(1)*yC;
    yzC=v(2)*zC;
    zxC=v(3)*xC;
 
    rotMatrix(1,1)=v(1)*xC+c;
    rotMatrix(1,2)=xyC-zs;
    rotMatrix(1,3)=zxC+ys;
    rotMatrix(2,1)=xyC+zs;
    rotMatrix(2,2)=v(2)*yC+c;
    rotMatrix(2,3)=yzC-xs;
    rotMatrix(3,1)=zxC-ys;
    rotMatrix(3,2)=yzC+xs;
    rotMatrix(3,3)=v(3)*zC+c;
end
