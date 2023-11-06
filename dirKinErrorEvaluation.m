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

function [phaseError, moduleError, dirKinError] = dirKinErrorEvaluation(robot, jointSynchDataSet, numPerson, cuttedElapsedTime, cuttedPosDataSet, involvedHand, defaultTitleName)
% This function is used to check the error made from the direct kinematic
% alghoritm making a comparison between the position read from the state:o
% port of iCub and the one evaluated from joint values for baselines

    IMAGE_SAVING = 1;        % Used to save some chosen plots
    PAUSE_TIME = 2;          % Used to let the window of the plot get the full resolution size before saving

    tic
    fprintf("           .Direct kinematics error evaluation...")

    evaluatedPosition = zeros(height(jointSynchDataSet),3);

    for i = 1:height(evaluatedPosition)
        pose = assignJointToPose(robot, table2array(jointSynchDataSet(i,2:end)), [0,0,0], involvedHand, numPerson);
        if numPerson < 0
            if strcmp(involvedHand,"DX") == 1
                T = getTransform(robot,pose,'root_link','r_hand_dh_frame');
            else
                T = getTransform(robot,pose,'l_hand_dh_frame','root_link');
            end
        else
            if strcmp(involvedHand,"SX") == 1
                T = getTransform(robot,pose,'root_link','r_hand_dh_frame');
            else
                T = getTransform(robot,pose,'root_link','l_hand_dh_frame');
            end
        end
        tmpPos = T*[0,0,0,1]';
        evaluatedPosition(i,:) = tmpPos(1:3);
    end

    dirKinError = table2array(cuttedPosDataSet(:,3:5)) - evaluatedPosition;
    fftIdeal = zeros(height(jointSynchDataSet),3);
    fftReal = zeros(height(jointSynchDataSet),3);
    phaseError = zeros(height(jointSynchDataSet),3); 
    moduleError = zeros(height(jointSynchDataSet),3); 
    meanError = zeros(1,3); 
    for k = 1:3
        fftIdeal(:,k) = fft(table2array(cuttedPosDataSet(:,k+2)));
        fftReal(:,k) = fft(evaluatedPosition(:,k));
        phaseError(:,k) = phase(fftIdeal(:,k))-phase(fftReal(:,k));
        moduleError(:,k) = abs(fftIdeal(:,k))-abs(fftReal(:,k));
        meanError(k) = mean(dirKinError(:,k));
    end

    % Plot results
    fig1 = figure('Name','Positions comparison');
    fig1.WindowState = 'maximized';
    subplot(2,3,1), grid on, hold on
    plot(cuttedElapsedTime, cuttedPosDataSet.xPos.*100, 'b-', 'DisplayName','Dumped position')
    plot(cuttedElapsedTime, evaluatedPosition(:,1).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between X positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off
    subplot(2,3,2), grid on, hold on
    plot(cuttedElapsedTime, cuttedPosDataSet.yPos.*100, 'b-', 'DisplayName','Dumped position')
    plot(cuttedElapsedTime, evaluatedPosition(:,2).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between Y positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off
    subplot(2,3,3), grid on, hold on
    plot(cuttedElapsedTime, cuttedPosDataSet.zPos.*100, 'b-', 'DisplayName','Dumped position')
    plot(cuttedElapsedTime, evaluatedPosition(:,3).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between Z positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off

    subplot(2,3,4), grid on, hold on
    plot(cuttedElapsedTime, dirKinError(:,1).*100, 'b-','DisplayName','Error evaluated')
    yline(meanError(1).*100,'k--','LineWidth',2.2,'DisplayName','Mean Error')
    title('Error of the X position calculation')
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    legend('show')
    hold off
    subplot(2,3,5), grid on, hold on
    plot(cuttedElapsedTime, dirKinError(:,2).*100, 'b-','DisplayName','Error evaluated')
    yline(meanError(2).*100,'k--','LineWidth',2.2,'DisplayName','Mean Error')
    title('Error of the Y position calculation')
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    legend('show')
    hold off
    subplot(2,3,6), grid on, hold on
    plot(cuttedElapsedTime, dirKinError(:,3).*100, 'b-','DisplayName','Error evaluated')
    yline(meanError(3).*100,'k--','LineWidth',2.2,'DisplayName','Mean Error')
    title('Error of the Z position calculation')
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    legend('show')
    hold off

    sgtitle(defaultTitleName)

    if IMAGE_SAVING
        mkdir ..\ProcessedData\DirectKinematicsError;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\DirectKinematicsError\B",num2str(3+numPerson),".png"],"");
        else
            path = strjoin(["..\ProcessedData\DirectKinematicsError\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path);
        close(fig1);
    end

    fprintf("                                            Completed in %s minutes with a mean error of %.2f\n",duration(0,0,toc,'Format','mm:ss.SS'),meanError)
end