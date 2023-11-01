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

function [newCuttedSynchForceDataSet] = forceTransformation(robot, aik, opts, initialPosDataSet, cuttedPosDataSet, ...
    cuttedSynchForceDataSet, posStart, posEnd, personParameters, defaultTitleName, numPerson)
% This function is used to evaluate the transformation of the force in order to have the 
% exact value of the force module in the hand RF and the orientation in the OF.
% In the following a brief explanation of the procedure computed:

% Importing the whole body model.urdf we got the reference frame of the F/T
% sensor, know in the model as "l/r_upper_arm". So the procedure will be:
% 1. Get the rotation matrix from the hand to the OF using quaternions in
%    the position file
% 2. Get the trasfrotmation matrix from the F/T sensor to the OF using the .urdf
%    model
% 3. Transform the force from F/T to hand using point 2
% 4. Rotate the force from hand to OF using point 1

% NB: the OF in .urdf model is know as "root link"

    %% Simulation parameters
    IMAGE_SAVING = 1;           % Used to save some chosen plots
    PAUSE_TIME = 8;             % Used to let the window of the plot get the full resolution size before saving
    Y_RANGE = 5;                % Newton absolute range for force plotting
    I_KIN_ERROR_EVALUATION = 1; % If 0 the stated error is not evaluated
    
    %% Input data
    tic
    fprintf("\n       .Reading data files...")
    if numPerson == -2
        jointDataSet = readtable("..\InputData\joints\leftArm\P0_L_Base\data.log");
    else 
        if numPerson == -1
            jointDataSet = readtable("..\InputData\joints\rightArm\P0_R_Base\data.log");
        else
            numPerson = numPerson+3;
            if strcmp(personParameters(5),"DX") == 1
                if numPerson < 10
                    jointDataSet = join(["..\InputData\joints\leftArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    jointDataSet = join(["..\InputData\joints\leftArm\P_000",num2str(numPerson),"\data.log"],'');
                end
            else
                if personSubSet < 10
                    jointDataSet = join(["..\InputData\joints\rightArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    jointDataSet = join(["..\InputData\joints\rightArm\P_000",num2str(numPerson),"\data.log"],'');
                end
            end
        end
    end

    jointDataSet = renamevars(jointDataSet,["Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9"], ...
                                           ["Time","ShoulderPitch","ShoulderRoll","ShoulderYaw","Elbow","WristProsup","WristPitch","WristRoll"]);
    
    % Known a-priori angle of the joints in degrees
    armJointsA = [-30.0 20.0 8.0 70.0 -3.0 -10.0 -5.0];
    armJointsB = [-30.0 36.0 -18.0 50.0 -3.0 -10.0 -5.0];
    torsoJoints = [0,0,0];

    fprintf("                                            Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
    %% Example of setting robot to POS A - WHOLE BODY MODEL
    posA = assignJointToPose(robot, armJointsA, torsoJoints, personParameters(5), numPerson);
%     show(robot,posA);
    
    %% Example of setting robot to POS B - WHOLE BODY MODEL
    posB = assignJointToPose(robot, armJointsB, torsoJoints, personParameters(5), numPerson);
%     show(robot,posB);

    %% Synchronizing joints signal with position
    tic
    fprintf("       .Computing joint data synchronization...")
    % Find the initial delay between the two sampled signals
    initialTimeDelay = initialPosDataSet.Time(1)-jointDataSet.Time(1);
    
    if initialTimeDelay >= 0
        % If the joints have more samples than position, than it has smaller starting time,
        % and a positive difference with the position one, so it needs to be back-shifted
        synchJointDataSet = jointDataSet(jointDataSet.Time>=initialPosDataSet.Time(1),:);
    else
        % The opposite situation, so it will be forward-shifted using some zeros
        zeroMatrix = array2table(zeros(sum(jointDataSet.Time(1)>initialPosDataSet.Time),size(jointDataSet,2)));
        zeroMatrix = renamevars(zeroMatrix,["Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9"], ...
                                           ["Time","ShoulderPitch","ShoulderRoll","ShoulderYaw","Elbow","WristProsup","WristPitch","WristRoll"]);
        synchJointDataSet = [zeroMatrix;jointDataSet];
    end
    
    tmpCuttedSynchJointDataSet = zeros(posEnd-posStart+1,8);
    for j = 2:9
        % Now the joints have to be interpolated in the position time stamp in order
        % to set the same start and stop point
        tmpSynchJointDataSet = interp1(1:height(synchJointDataSet),table2array(synchJointDataSet(:,j)),1:height(initialPosDataSet));
        % Remove greetings and closing
        tmpCuttedSynchJointDataSet(:,j-1) = tmpSynchJointDataSet(posStart:posEnd)';
    end
    cuttedSynchJointDataSet = array2table(tmpCuttedSynchJointDataSet);
    cuttedSynchJointDataSet = renamevars(cuttedSynchJointDataSet,1:width(cuttedSynchJointDataSet),["Time","ShoulderPitch","ShoulderRoll","ShoulderYaw","Elbow","WristProsup","WristPitch","WristRoll"]);
    cuttedElapsedTime = minutesDataPointsConverter(cuttedSynchForceDataSet)';

    fprintf("                          Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
    %% Print shoulder pitch joint dependencies with position axis
    fig2DJointTraj = figure('Name', 'Shoulder pitch joint value w.r.t. position axis');
    fig2DJointTraj.WindowState = 'maximized';
    subplot(1,3,1), grid on, hold on
    plot(cuttedPosDataSet.xPos.*100, cuttedSynchJointDataSet.ShoulderPitch, 'b-')
    ylabel("Joint [ degrees ]"), xlabel("X position [ cm ]")
    title("Shoulder pitch w.r.t. X position")

    subplot(1,3,2), grid on, hold on
    plot(cuttedPosDataSet.yPos.*100, cuttedSynchJointDataSet.ShoulderPitch, 'r-')
    ylabel("Joint [ degrees ]"), xlabel("Y position [ cm ]")
    title("Shoulder pitch w.r.t. Y position")

    subplot(1,3,3), grid on, hold on
    plot(cuttedPosDataSet.zPos.*100, cuttedSynchJointDataSet.ShoulderPitch, 'g-')
    ylabel("Joint [ degrees ]"), xlabel("Z position [ cm ]")
    title("Shoulder pitch w.r.t. Z position")
    
    sgtitle(defaultTitleName)
    
    % Plot joint wrt the XZ plane to further evaluated probabilities -> MAY NOT BE THE RIGHT PROCEDURE
%     fig3DJointTraj = figure('Name', 'Shoulder pitch joint value w.r.t. position axis XZ');
%     fig3DJointTraj.WindowState = 'maximized';
%     grid on, hold on
%     plot3(cuttedPosDataSet.xPos.*100, cuttedPosDataSet.zPos.*100, cuttedSynchJointDataSet.ShoulderPitch, 'k-')
%     zlabel("Joint [ degrees ]"), xlabel("X position [ cm ]"), ylabel("Z position [ cm ]") 
%     title("Shoulder pitch w.r.t. XZ plane")

    if IMAGE_SAVING
        mkdir ..\ProcessedData\ShoulderPitchJointPositionRelation;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ShoulderPitchJointPositionRelation\B",num2str(3+numPerson),".png"],"");
        else
            path = strjoin(["..\ProcessedData\ShoulderPitchJointPositionRelation\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig2DJointTraj,path)
        close(fig2DJointTraj);
    end

    %% Procedure of force transformation
    newCuttedSynchForceDataSet = cuttedSynchForceDataSet;

    if I_KIN_ERROR_EVALUATION
        NUMBER_OF_SAMPLES = height(newCuttedSynchForceDataSet); %1500;
        jointError = zeros(NUMBER_OF_SAMPLES,length(armJointsA)-1);
        if numPerson < 0
            if strcmp(personParameters(5),"SX") % Inverted to DX when not baseline
                aik.KinematicGroup = opts(10).KinematicGroup;
                generateIKFunction(aik,'iCubIK_SXArm');
            else
               aik.KinematicGroup = opts(12).KinematicGroup;
               generateIKFunction(aik,'iCubIK_DXArm');
            end
        else
            if strcmp(personParameters(5),"DX") 
                aik.KinematicGroup = opts(10).KinematicGroup;
                generateIKFunction(aik,'iCubIK_SXArm');
            else
                aik.KinematicGroup = opts(12).KinematicGroup;
                generateIKFunction(aik,'iCubIK_DXArm');
            end
        end
    end

    tic
    fprintf("       .Evaluation of the rotation matrix of the first set of data...")

    for i = 1:height(cuttedSynchForceDataSet)
        % 1. Rotation matrix from hand to OF
        armJoints = table2array(cuttedSynchJointDataSet(i,2:end));
        R_HtoOF = axis2dcm(cuttedPosDataSet.ax(i),cuttedPosDataSet.ay(i),cuttedPosDataSet.az(i),cuttedPosDataSet.theta(i));
        
        % Check on joints possible only for baselines
        if i == 1 && numPerson < 0 % Only on the first iteration
            T_HtoOF = getTransform(robot,assignJointToPose(robot,armJoints,torsoJoints,personParameters(5),numPerson),aik.KinematicGroup.EndEffectorBodyName,'root_link');
            cfrRot = T_HtoOF(1:3,1:3)-R_HtoOF;
            fprintf("\n           .The difference between generated rotation from Euler Angles and generated from joint [from hand frame to root link] is: \n")
            fprintf("                   %2.4f\t\t%2.4f\t\t%2.4f\n",cfrRot.')
            
            if norm(abs(cfrRot)) > 1e-1
                error("The evaluated T matrix from hand frame to root frame has an approximation error too high.")
            end
        end

        % 2. Transformation matrix from T/F sensor to Hand
        newPos = assignJointToPose(robot, armJoints,torsoJoints,personParameters(5),numPerson);
        % Evaluating the transformation matrix for each sample
        if numPerson < 0
            if strcmp(personParameters(5),"SX") % Inverted to DX when not baseline
                T_TFtoH = getTransform(robot,newPos,"l_upper_arm","l_hand_dh_frame");
            else
                T_TFtoH = getTransform(robot,newPos,"r_upper_arm","r_hand_dh_frame");
            end
        else
            if strcmp(personParameters(5),"DX") 
                T_TFtoH = getTransform(robot,newPos,"l_upper_arm","l_hand_dh_frame");
            else
                T_TFtoH = getTransform(robot,newPos,"r_upper_arm","r_hand_dh_frame");
            end
        end
    
        % 3 and 4. Evaluating the force resultant for each sample
        F = [cuttedSynchForceDataSet.Fx(i),cuttedSynchForceDataSet.Fy(i),cuttedSynchForceDataSet.Fz(i),1]*T_TFtoH*[R_HtoOF,zeros(3,1);zeros(1,3),1];
        newCuttedSynchForceDataSet.Fx(i) = F(1);
        newCuttedSynchForceDataSet.Fy(i) = F(2);
        newCuttedSynchForceDataSet.Fz(i) = F(3);
        
        if i == 1 % Only on the first iteration
            fprintf("    Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
        end

        if I_KIN_ERROR_EVALUATION
            if i == 1 % Only on the first iteration
                tic
                fprintf("       .Evaluation of the inverse kinematics of the first set of data...")
                
                if strcmp(personParameters(5),"SX") && numPerson < 0
                    if mean(cuttedPosDataSet.yPos) < cuttedPosDataSet.yPos(1)
                        referenceConfig = getAnglesFromConfiguration(posB,17:22);
                        referencePos = posB;
                    else
                        referenceConfig = getAnglesFromConfiguration(posA,17:22);
                        referencePos = posA;
                    end
                else
                    if strcmp(personParameters(5),"DX") && numPerson < 0
                        if mean(cuttedPosDataSet.yPos) < cuttedPosDataSet.yPos(1)
                            referenceConfig = getAnglesFromConfiguration(posA,27:32);
                            referencePos = posA;
                        else
                            referenceConfig = getAnglesFromConfiguration(posB,27:32);
                            referencePos = posB;
                        end
                    else
                        if strcmp(personParameters(5),"SX") && numPerson >= 0
                            if mean(cuttedPosDataSet.yPos) < cuttedPosDataSet.yPos(1)
                                referenceConfig = getAnglesFromConfiguration(posA,17:22);
                                referencePos = posA;
                            else
                                referenceConfig = getAnglesFromConfiguration(posB,17:22);
                                referencePos = posB;
                            end
                        else
                            if strcmp(personParameters(5),"DX") && numPerson >= 0
                                if mean(cuttedPosDataSet.yPos) < cuttedPosDataSet.yPos(1)
                                    referenceConfig = getAnglesFromConfiguration(posB,27:32);
                                    referencePos = posB;
                                else
                                    referenceConfig = getAnglesFromConfiguration(posA,27:32);
                                    referencePos = posA;
                                end
                            end
                        end
                    end
                end
            end
            
            if i < NUMBER_OF_SAMPLES
                [jointError(i,:), referenceConfig, referencePos] = iKinErrorEvaluation(robot, aik, referenceConfig, referencePos ,cuttedPosDataSet(i,3:5), armJoints, R_HtoOF, personParameters(5), numPerson); 
            end

            if i == 1 % Only on the first iteration
                fprintf(" Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
            end
        end
    end
    
    fig1 = figure('Name','Force transformation');
    fig1.WindowState = 'maximized';
    
    subplot(2,3,1), grid on, hold on, plot(cuttedElapsedTime, cuttedSynchForceDataSet.Fx, 'b-')
    title("Force dumped - X COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(cuttedSynchForceDataSet.Fx)-Y_RANGE,mean(cuttedSynchForceDataSet.Fx)+Y_RANGE])
    
    subplot(2,3,2), grid on, hold on, plot(cuttedElapsedTime, cuttedSynchForceDataSet.Fy, 'r-')
    title("Force dumped - Y COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(cuttedSynchForceDataSet.Fy)-Y_RANGE,mean(cuttedSynchForceDataSet.Fy)+Y_RANGE])
    
    subplot(2,3,3), grid on, hold on, plot(cuttedElapsedTime, cuttedSynchForceDataSet.Fz, 'g-')
    title("Force dumped - Z COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(cuttedSynchForceDataSet.Fz)-Y_RANGE,mean(cuttedSynchForceDataSet.Fz)+Y_RANGE])
    
    subplot(2,3,4), grid on, hold on, plot(cuttedElapsedTime, newCuttedSynchForceDataSet.Fx, 'b-')
    title("Force transformed - X COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(newCuttedSynchForceDataSet.Fx)-Y_RANGE,mean(newCuttedSynchForceDataSet.Fx)+Y_RANGE])
    
    subplot(2,3,5), grid on, hold on, plot(cuttedElapsedTime, newCuttedSynchForceDataSet.Fy, 'r-')
    title("Force transformed - Y COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(newCuttedSynchForceDataSet.Fy)-Y_RANGE,mean(newCuttedSynchForceDataSet.Fy)+Y_RANGE])
    
    subplot(2,3,6), grid on, hold on, plot(cuttedElapsedTime, newCuttedSynchForceDataSet.Fz, 'g-')
    title("Force transformed - Z COORDINATE"), xlabel("Elapsed Time [ min ]"), ylabel("Force [ N ]")
    % ylim([mean(newCuttedSynchForceDataSet.Fz)-Y_RANGE,mean(newCuttedSynchForceDataSet.Fz)+Y_RANGE])
    
    sgtitle(defaultTitleName)
    
    if IMAGE_SAVING
        mkdir ..\ProcessedData\ForceTransformation;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ForceTransformation\B",num2str(3+numPerson),".png"],"");
        else
            path = strjoin(["..\ProcessedData\ForceTransformation\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path)
        close(fig1);
    end

    %% Joint Error plotting
    tic
    fprintf("       .Joint error plotting...")
    if I_KIN_ERROR_EVALUATION
        clearBlue = [0,0.6,1];
        meanError = zeros(size(jointError,2),1);
        standardError = zeros(size(jointError,2),1);
        for i = 1:size(jointError,2)
            meanError(i) = mean(jointError(:,i));
            standardError(i) = std(jointError(:,i))/sqrt(length(jointError(:,i)));
        end

        fig2 = figure("Name",'Joint error');
        fig2.WindowState = 'maximized';
        hold on, grid on
        b1 = bar(1:size(jointError,2),meanError,0.7,'k');
        b1.FaceColor = clearBlue;
        errorbar(1:length(meanError), meanError, standardError, 'k', 'LineStyle','none','CapSize',15,'LineWidth',1.5)
        title("Joint Error Trend",defaultTitleName)
        ylabel('Error [degrees]'), xlabel("Joint number")

        if IMAGE_SAVING
            mkdir ..\ProcessedData\iKinJointsError;
            if numPerson < 0
                path = strjoin(["..\ProcessedData\iKinJointsError\B",num2str(3+numPerson),".png"],"");
            else
                path = strjoin(["..\ProcessedData\iKinJointsError\P",num2str(numPerson),".png"],"");
            end
            pause(PAUSE_TIME);
            exportgraphics(fig2,path)
        end
    end    

    fprintf("                        Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))

    %% DH matrices evaluation for POS A from hand to OF - ONLY HAND REFERENCE SYSTEM - USEFULL FOR GRAPH PLOTTING
%     POS_SHOWING = 0;            % Used to plot some examples
%     if POS_SHOWING
%         figure, title("Definition of POS A")
%     end
%     [~,LpA_T] = WaistLeftArmFwdKin(torsoJoints,armJointsA,POS_SHOWING);
%     [~,RpA_T] = WaistRightArmFwdKin(torsoJoints,armJointsA,POS_SHOWING);
%     
%     % DH matrices evaluation for POS B from hand to OF
% %     if POS_SHOWING
% %         figure, title("Definition of POS B")
% %     end
%     [~,LpB_T] = WaistLeftArmFwdKin(torsoJoints,armJointsB,POS_SHOWING);
%     [~,RpB_T] = WaistRightArmFwdKin(torsoJoints,armJointsB,POS_SHOWING);

end
