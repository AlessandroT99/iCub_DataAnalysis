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

function [newJoints, newReferenceConfig, newReferencePos, finalJointError, newErrorComputed] = iKinJointEvaluation(robot, aik, referenceConfig, referencePos, cuttedPosDataSet, armJoints, rotMatrix, handInvolved, numPerson, errorComputed)
% This function is used to test the generated position from direct
% kinematics and understand if using inverse kinematics would be possible
% to get to the desidered joints with a very small error
    
    ERROR_ADMITTED = 50; % Number of admitted error for the iKin alghoritm
    newErrorComputed = errorComputed;

    % To check orthogonormality of the matrix uncomment the following and
    % look for a similar eye(3)
    detTollerance = 1e-5;
    if det(rotMatrix'*rotMatrix) - 1 >= detTollerance || det(rotMatrix*rotMatrix') - 1 >= detTollerance
        error("Rotation matrix for iKin Error Evaluation is not orthonormal.");
    end

    eeBodyName = aik.KinematicGroup.EndEffectorBodyName;
    baseName = aik.KinematicGroup.BaseName;


    shoulderPitchJoint = -pi;
    % Check the results and keep cycling until a feasible result is found    
    while (shoulderPitchJoint < pi)
        % The data are from the hand to the OF
        evaluatedT_HtoOF = [rotMatrix,table2array(cuttedPosDataSet)';zeros(1,3),1];
        % Calculate the transformation matrix from the shoulder 1 to the root
        % Up to know seems that as first iteration using an approximation such
        % as referencePos = posA or posB leads to infeasibility for the iKin
        T_S1toOF = getTransform(robot,referencePos,baseName,'root_link');
        % Evaluating the transformation from the hand to the shoulder 1
        evaluatedT_HtoS1 = T_S1toOF\evaluatedT_HtoOF;
        
        % Check on joints possible only for baselines
%         if numPerson < 0
%             expConfig = assignJointToPose(robot,armJoints,[0,0,0],handInvolved,numPerson);
%             T_HtoS1 = getTransform(robot,expConfig,eeBodyName,baseName);
%         
%             cfrTrasl = T_HtoS1-evaluatedT_HtoS1;
%             fprintf("\n           .The difference between generated trasnformation from Euler Angles and generated from joint [from hand frame to shoulder1] is: \n")
%             fprintf("                   %2.4f\t\t%2.4f\t\t%2.4f\t\t%2.4f\n",cfrTrasl.')
%             fprintf("              And has norm: %.4f\n",norm(abs(cfrTrasl)))
%             pause;
%             % if the norm is higher than this tollerance value is very probable
%             % that the result of iKin evaluation will be for sure infeasible
%             if norm(abs(cfrTrasl)) > 0.5
%                 error("The evaluated T matrix from hand frame to shoulder 1 frame has an approximation error too high.")
%             end
%         end
    
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
            if strcmp(handInvolved,"R") == 1
                ikConfig = iCubIK_RArm(evaluatedT_HtoS1,enforceJointLimits,sortByDistance,referenceConfig);
                % Save the new eventual shoulder pitch position into the configuration struct
                referencePos(26).JointPosition = shoulderPitchJoint + referencePos(26).JointPosition;
                finalShoulderPitch = referencePos(26).JointPosition;
            else
                ikConfig = iCubIK_LArm(evaluatedT_HtoS1,enforceJointLimits,sortByDistance,referenceConfig);
                % Save the new eventual shoulder pitch position into the configuration struct
                referencePos(16).JointPosition = shoulderPitchJoint + referencePos(16).JointPosition;
                finalShoulderPitch = referencePos(16).JointPosition;
            end
        else
            if strcmp(handInvolved,"L") == 1
                ikConfig = iCubIK_RArm(evaluatedT_HtoS1,enforceJointLimits,sortByDistance,referenceConfig);
                % Save the new eventual shoulder pitch position into the configuration struct
                referencePos(26).JointPosition = shoulderPitchJoint + referencePos(26).JointPosition;
                finalShoulderPitch = referencePos(26).JointPosition;
            else
                ikConfig = iCubIK_LArm(evaluatedT_HtoS1,enforceJointLimits,sortByDistance,referenceConfig);
                % Save the new eventual shoulder pitch position into the configuration struct
                referencePos(16).JointPosition = shoulderPitchJoint + referencePos(16).JointPosition;
                finalShoulderPitch = referencePos(16).JointPosition;
            end
        end
        
        if isempty(ikConfig) == 1
            % If result is empty increment the angle and keep cycling
            shoulderPitchJoint = shoulderPitchJoint + pi/180;
        else
            % Stop cycling and used the just found solution
            break;
        end
    end

    % Check if at least one results has been found, if not raise an error
    if isempty(ikConfig) == 1
        if ERROR_ADMITTED > newErrorComputed
            newErrorComputed = newErrorComputed + 1;
            ikConfig = referenceConfig;
        else
            error(strjoin(["The result from inverse kinematics is empty - So the configuration of transformation matrix is not a reachable pose for the kinematic chain.",newline, ...
                "This error has been found for 50 times, which is the limit imposed. The simulation has been interrupted."],""));
        end
    end

    % Assign each possible solution to its configuration struct
    generatedConfig = repmat(homeConfiguration(robot), size(ikConfig,1), 1);
    for i = 1:size(generatedConfig,1)
        for j = 1:size(ikConfig,2)
            generatedConfig(i,aik.KinematicGroupConfigIdx(j)).JointPosition = ikConfig(i,j);
        end
    end

    % Plot the resultant pose in order of distance between the starting pose
%     for i = 1:size(ikConfig,1)
%         figure;
%         show(robot,generatedConfig(i,:));
%         title(['Solution ' num2str(i)]);
%     end
    
    % Evaluate the error from all the resultant configurations to confirm
    % that the first one is actually the most correct one
    % ONLY DONE FOR BASELINE FOR WHICH THE REAL JOINTS ARE KNOWN
    jointError = zeros(size(ikConfig,1),size(ikConfig,2));
    if numPerson < 0
        for k = 1:size(ikConfig,1)
            jointSol = ikConfig(k,:).*180/pi;
            jointError(k,:) = mod((armJoints(2:end)-jointSol),360); % IN DEGREES
            for i = 1:size(jointError,2)
                if jointError(k,i) > 180
                    jointError(k,i) = jointError(k,i)-360;
                end
            end
%             fprintf("                   .The iKin solution %d has an average error of: %.2f\n",k,mean(jointError(k,:)))
        end
    end

   % Save the current configuration in order to use it as new starting
   % configuration for the next time instant
   newJoints = [finalShoulderPitch, ikConfig(1,:)]; % IN RADIANTS
   finalJointError = jointError(1,:);
   newReferenceConfig = ikConfig(1,:);
   newReferencePos = generatedConfig(1,:);
end
