% Copyright: (C) 2023 Department of COgNiTive Architecture for Collaborative Technologies
%                     Istituto Italiano di Tecnologia
% Author: Alessandro Tiozzo
% email: alessandro.tiozzo@iit.it
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

% NOTICE THAT THE "jointError" IS IN DEGREES

function jointError = iKinErrorEvaluation(robot, cuttedPosDataSet, armJoints, torsoJoints, rotMatrix, handInvolved)
% This function is used to test the generated position from direct
% kinematics and understand if using inverse kinematics would be possible
% to get to the desidered joints with a very small error

    maxErrorOrientation = 1e-1;
    maxErrorPosition = 1e-3;

    ik = inverseKinematics('RigidBodyTree',robot);
    ik.SolverParameters.MaxIterations = 1000;
    
    % To check orthogonormality of the matrix uncomment the following and
    % look for a similar eye(3)
%     rotMatrix'*rotMatrix
%     rotMatrix*rotMatrix'

    pose = [rotMatrix', table2array(cuttedPosDataSet)';zeros(1,3),1];
    initialGuess = homeConfiguration(robot);
    
    if strcmp(handInvolved,"DX") == 1
        [configSol, solInfo] = ik('r_hand',pose,[maxErrorOrientation.*ones(1,3),maxErrorPosition.*ones(1,3)],initialGuess);
        jointNumber = [13:15,26:32];
    else
        [configSol, solInfo] = ik('l_hand',pose,[maxErrorOrientation.*ones(1,3),maxErrorPosition.*ones(1,3)],initialGuess);
        jointNumber = [13:15,16:22];
    end

    jointSol = zeros(1,length([torsoJoints,armJoints]));
    for j = 1:length(jointNumber)
        jointSol(j) = configSol(jointNumber(j)).JointPosition;
    end
    
    realJoints = [torsoJoints,armJoints];
    jointError = mod((realJoints-jointSol).*180/pi,360); % IN DEGREES
    for i = 1:length(jointError)
        if jointError(i) > 180
            jointError(i) = jointError(i)-360;
        end
    end
end
