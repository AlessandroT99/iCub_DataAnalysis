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
% - Save into a folder the results of each test and then before
%   reattempting it, checking for its existance, if already there, skip the
%   procedure and just load it.
% - After the inverse, use the direct to reconduct it to the position to
%   check correctness

function jointError = iKinErrorEvaluation(robot, aik, opts, cuttedPosDataSet, armJoints, torsoJoints, rotMatrix, handInvolved)
% This function is used to test the generated position from direct
% kinematics and understand if using inverse kinematics would be possible
% to get to the desidered joints with a very small error
    
    % To check orthogonormality of the matrix uncomment the following and
    % look for a similar eye(3)
%     rotMatrix'*rotMatrix
%     rotMatrix*rotMatrix'

    pose = [rotMatrix', table2array(cuttedPosDataSet)';zeros(1,3),1];
    initialGuess = homeConfiguration(robot);
    realJoints = [torsoJoints,armJoints];
    
    if strcmp(handInvolved,"DX") == 1
        aik.KinematicGroup = opts(12).KinematicGroup;
%         jointNumber = [13:15,26:32];
    else
        aik.KinematicGroup = opts(10).KinematicGroup;
%         jointNumber = [13:15,16:22];
    end
    
%     expConfig = homeConfiguration(robot);
%     eeBodyName = aik.KinematicGroup.EndEffectorBodyName;
%     baseName = aik.KinematicGroup.BaseName;
%     % Generation of transformation matrix of the end effector pose
%     expEEPose = getTransform(robot,expConfig,eeBodyName,baseName);
            
%     aik.KinematicGroup.BaseName = 'root_link';
    customGroup.links = {'chest','l_shoulder_1','l_shoulder_2','l_shoulder_3','l_elbow_1','l_foreharm','l_wrist_1','r_hand'};
    customGroup.joints = {'torso_yaw','l_shouldere_pitch', 'l_shoulder_roll', 'l_shoulder_yaw', 'l_elbow','l_wrist_prosup','l_wrist_pitch','l_wrist_yaw','l_hand_dh_frame'};
    generateIKFunction(aik,'iCubIK');
    ikConfig = iCubIK(pose,true);
%     eeWorldPose = getTransform(robot,expConfig,eeBodyName);

    generatedConfig = repmat(initialGuess, size(ikConfig,1), 1);
    for i = 1:size(generatedConfig,1)
        for j = 1:size(ikConfig,2)
            generatedConfig(i,aik.KinematicGroupConfigIdx(j)).JointPosition = ikConfig(i,j);
        end
    end

    for i = 1:size(ikConfig,1)
        figure;
        ax = show(robot,generatedConfig(i,:));
        hold all;
        plotTransforms(tform2trvec(eeWorldPose),tform2quat(eeWorldPose),'Parent',ax);
        title(['Solution ' num2str(i)]);
    end
    
    for k = 1:size(ikConfig,1)
        jointSol = ikConfig(k,:);
        jointError = mod((realJoints-jointSol).*180/pi,360); % IN DEGREES
        for i = 1:length(jointError)
            if jointError(i) > 180
                jointError(i) = jointError(i)-360;
            end
        end
    end
end
