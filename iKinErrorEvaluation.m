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

% TODO:
% - analyticalInverseKinematics()
% - Save into a folder the results of each test and then before
%   reattempting it, checking for its existance, if already there, skip the
%   procedure and just load it.
% - After the inverse, use the direct to reconduct it to the position to
%   check correctness

function jointError = iKinErrorEvaluation(robot, cuttedPosDataSet, armJoints, torsoJoints, rotMatrix, handInvolved)
% This function is used to test the generated position from direct
% kinematics and understand if using inverse kinematics would be possible
% to get to the desidered joints with a very small error

    maxErrorOrientation = 1;
    maxErrorPosition = 1;

    ik = inverseKinematics('RigidBodyTree',robot);
    ik.SolverAlgorithm = 'LevenbergMarquardt';
    %ik.SolverParameters.MaxIterations = 2000;
    
    % To check orthogonormality of the matrix uncomment the following and
    % look for a similar eye(3)
%     rotMatrix'*rotMatrix
%     rotMatrix*rotMatrix'

    pose = [rotMatrix', table2array(cuttedPosDataSet)';zeros(1,3),1];
    initialGuess = homeConfiguration(robot);
    jointSol = zeros(1,length([torsoJoints,armJoints]));
    realJoints = [torsoJoints,armJoints];
%     jointError = 100*ones(1,length(realJoints));
    
    if strcmp(handInvolved,"DX") == 1
        [configSol, solInfo] = ik('r_hand',pose,[maxErrorOrientation.*ones(1,3),maxErrorPosition.*ones(1,3)],initialGuess);
        jointNumber = [13:15,26:32];
    else
        [configSol, solInfo] = ik('l_hand',pose,[maxErrorOrientation.*ones(1,3),maxErrorPosition.*ones(1,3)],initialGuess);
        jointNumber = [13:15,16:22];
    end

    for j = 1:length(jointNumber)
        jointSol(j) = configSol(jointNumber(j)).JointPosition;
    end
    
    jointError = mod((realJoints-jointSol).*180/pi,360); % IN DEGREES
    for i = 1:length(jointError)
        if jointError(i) > 180
            jointError(i) = jointError(i)-360;
        end
    end
end
