% Copyright: (C) 2023 Department of COgNiTive Architecture for Collaborative Technologies
%                     Istituto Italiano di Tecnologia
% Author: Alessandro Tiozzo
% email: alessandro.tiozzo@iit.it
% Permission is granted to copy, distribute, and/or modify this program
% under the terms of the GNU General Public License, version 2 or any
% later version published by the Free Software Foundation.
% 
% A copy of the license can be found at
% http://www.robotcub.org/robot/license/gpl.txt
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details

function [newPose] = assignJointToPose(robot, armJoints, torsoJoints, personArm, numPerson)
% Function used just to assign the values of the joint into the pose
% variable
    % Creating the pose variable
    newPose = homeConfiguration(robot);
    
    % THE ANGLE HAS TO BE ASSIGNED IN RADIANTS
    armJoints = armJoints.*pi./180;
    torsoJoints = torsoJoints.*pi./180;

    % Assiging the torso joints values
    newPose(13).JointPosition = torsoJoints(1);
    newPose(14).JointPosition = torsoJoints(2);
    newPose(15).JointPosition = torsoJoints(3);

    % Assigning the arm joints values
    if numPerson < 0
        if strcmp(personArm,"L")
            newPose(16).JointPosition = armJoints(1);
            newPose(17).JointPosition = armJoints(2);
            newPose(18).JointPosition = armJoints(3);
            newPose(19).JointPosition = armJoints(4);
            newPose(20).JointPosition = armJoints(5);
            newPose(21).JointPosition = armJoints(6);
            newPose(22).JointPosition = armJoints(7);
        else
            newPose(26).JointPosition = armJoints(1);
            newPose(27).JointPosition = armJoints(2);
            newPose(28).JointPosition = armJoints(3);
            newPose(29).JointPosition = armJoints(4);
            newPose(30).JointPosition = armJoints(5);
            newPose(31).JointPosition = armJoints(6);
            newPose(32).JointPosition = armJoints(7);
        end
    else
        if strcmp(personArm,"R")
            newPose(16).JointPosition = armJoints(1);
            newPose(17).JointPosition = armJoints(2);
            newPose(18).JointPosition = armJoints(3);
            newPose(19).JointPosition = armJoints(4);
            newPose(20).JointPosition = armJoints(5);
            newPose(21).JointPosition = armJoints(6);
            newPose(22).JointPosition = armJoints(7);
        else
            newPose(26).JointPosition = armJoints(1);
            newPose(27).JointPosition = armJoints(2);
            newPose(28).JointPosition = armJoints(3);
            newPose(29).JointPosition = armJoints(4);
            newPose(30).JointPosition = armJoints(5);
            newPose(31).JointPosition = armJoints(6);
            newPose(32).JointPosition = armJoints(7);
        end
    end
end
