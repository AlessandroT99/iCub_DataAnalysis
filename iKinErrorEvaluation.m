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

function [jointError, newReferenceConfig, newReferencePos] = iKinErrorEvaluation(robot, aik, referenceConfig, referencePos, cuttedPosDataSet, armJoints, rotMatrix, handInvolved, numPerson)
% This function is used to test the generated position from direct
% kinematics and understand if using inverse kinematics would be possible
% to get to the desidered joints with a very small error
    
    % To check orthogonormality of the matrix uncomment the following and
    % look for a similar eye(3)
    detTollerance = 1e-5;
    if det(rotMatrix'*rotMatrix) - 1 >= detTollerance || det(rotMatrix*rotMatrix') - 1 >= detTollerance
        error("Rotation matrix for iKin Error Evaluation is not orthonormal.");
    end

    eeBodyName = aik.KinematicGroup.EndEffectorBodyName;
    baseName = aik.KinematicGroup.BaseName;

    % The data are from the hand to the OF
    evaluatedT_HtoOF = [rotMatrix,table2array(cuttedPosDataSet)';zeros(1,3),1];
    % Calculate the transformation matrix from the shoulder 1 to the root
    T_S1toOF = getTransform(robot,referencePos,'root_link',baseName);
    % Evaluating the transformation from the hand to the shoulder 1
    evaluatedT_HtoS1 = evaluatedT_HtoOF\T_S1toOF;
    
    expConfig = assignJointToPose(robot,armJoints,[0,0,0],handInvolved,numPerson);
    T_HtoS1 = getTransform(robot,expConfig,eeBodyName,baseName);

    cfrTrasl = T_HtoS1-evaluatedT_HtoS1;
    fprintf("\n           .The difference between generated trasnformation from Euler Angles and generated from joint [from hand frame to shoulder1] is: \n")
    fprintf("                   %2.4f\t\t%2.4f\t\t%2.4f\t\t%2.4f\n",cfrTrasl.')
    if norm(abs(cfrTrasl)) > 1e-3
        error("The evaluated T matrix from hand frame to shoulder 1 frame has an approximation error too high.")
    end

    % The variables passed at the IK alghortim are:
    % - pose = the transformation matrix which describes the transformation
    %          from the hand to the OF and than the trasposition to the shoulder
    % - enforceJointLimits = true because the limits of the joints has to
    %                        be respected
    % - sortByDistance = true because the output order of the solution is
    %                    ordered considering the distance from the initial angles
    % - referenceConfig = Inital angles of the joints, associated to the
    %                   previous position giving a sort of trajectory memory
    enforceJointLimits = true;
    sortByDistance = true;
    if numPerson < 0
        if strcmp(handInvolved,"DX") == 1
            ikConfig = iCubIK_DXArm(pose,enforceJointLimits,sortByDistance,referenceConfig);
        else
            ikConfig = iCubIK_SXArm(pose,enforceJointLimits,sortByDistance,referenceConfig);
        end
    else
        if strcmp(handInvolved,"SX") == 1
            ikConfig = iCubIK_DXArm(pose,enforceJointLimits,sortByDistance,referenceConfig);
        else
            ikConfig = iCubIK_SXArm(pose,enforceJointLimits,sortByDistance,referenceConfig);
        end
    end

    if isempty(ikConfig) == 1
        error("The result from inverse kinematics is empty - So the configuration of transformation matrix is not a reachable pose for the kinematic chain.");
    end

    generatedConfig = repmat(homeConfiguration(robot), size(ikConfig,1), 1);
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
        jointSol = ikConfig(k,:).*180/pi;
        jointError = mod((armJoints(2:end)-jointSol),360); % IN DEGREES
        for i = 1:length(jointError)
            if jointError(i) > 180
                jointError(i) = jointError(i)-360;
            end
        end
    end
end
