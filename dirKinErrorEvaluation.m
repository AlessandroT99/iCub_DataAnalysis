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

function [time_lag, dirKinError] = dirKinErrorEvaluation(robot, jointSynchDataSet, numPerson, cuttedElapsedTime, cuttedPosDataSet, involvedHand, defaultTitleName, BaselineFilesParameters)
% This function is used to check the error made from the direct kinematic
% alghoritm making a comparison between the position read from the state:o
% port of iCub and the one evaluated from joint values for baselines

    IMAGE_SAVING = 1;        % Used to save some chosen plots
    PAUSE_TIME = 4;          % Used to let the window of the plot get the full resolution size before saving

    tic
    fprintf("           .Direct kinematics error evaluation...")

    evaluatedPosition = zeros(height(jointSynchDataSet),3);

    for i = 1:height(evaluatedPosition)
        pose = assignJointToPose(robot, table2array(jointSynchDataSet(i,2:end)), [0,0,0], involvedHand, numPerson);
        if numPerson < 0
            if strcmp(involvedHand,"DX") == 1
                T = getTransform(robot,pose,'r_hand_dh_frame','root_link');
            else
                T = getTransform(robot,pose,'l_hand_dh_frame','root_link');
            end
        else
            if strcmp(involvedHand,"SX") == 1
                T = getTransform(robot,pose,'r_hand_dh_frame','root_link');
            else
                T = getTransform(robot,pose,'l_hand_dh_frame','root_link');
            end
        end
        tmpPos = T*[0,0,0,1]';
        evaluatedPosition(i,:) = tmpPos(1:3);
    end

    dirKinError = table2array(cuttedPosDataSet(:,3:5)) - evaluatedPosition;
    time_lag = zeros(1,3); 
    meanError = zeros(1,3); 
    meanAbsStd = zeros(1,3); 
    fs = 200; % Sampling frequency
    for k = 1:3
        Ideal = table2array(cuttedPosDataSet(:,k+2))-mean(table2array(cuttedPosDataSet(:,k+2)));
        Real = evaluatedPosition(:,k)-mean(evaluatedPosition(:,k));
        % Calculate the cross-correlation between the two signals
        cross_corr = xcorr(Ideal, Real);
        % Find the index of the maximum correlation value
        [~, idx_max] = max(abs(cross_corr));
        % Calculate the time lag corresponding to the maximum correlation
        time_lag(k) = (idx_max - length(Ideal)) / fs;
        meanError(k) = mean(dirKinError(:,k));
        meanAbsStd(k) = mean(std(abs(dirKinError(:,k))));
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
    meanLegend = strjoin(["Mean error: ",num2str(meanError(1)*100), " cm"],"");
    yline(meanError(1).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(1)*100), " cm"],"");
    yline(meanAbsStd(1).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(1))," s"],"");
    title('Error of the X position calculation',titleName)    
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-3,1])
    legend('show')
    hold off
    subplot(2,3,5), grid on, hold on
    plot(cuttedElapsedTime, dirKinError(:,2).*100, 'b-','DisplayName','Error evaluated')
    meanLegend = strjoin(["Mean error: ",num2str(meanError(2)*100), " cm"],"");
    yline(meanError(2).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(2)*100), " cm"],"");
    yline(meanAbsStd(2).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(2))," s"],"");
    title('Error of the Y position calculation',titleName)    
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-7,10])
    legend('show')
    hold off
    subplot(2,3,6), grid on, hold on
    plot(cuttedElapsedTime, dirKinError(:,3).*100, 'b-','DisplayName','Error evaluated')
    meanLegend = strjoin(["Mean error: ",num2str(meanError(3)*100), " cm"],"");
    yline(meanError(3).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(3)*100), " cm"],"");
    yline(meanAbsStd(3).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(3))," s"],"");
    title('Error of the Z position calculation',titleName)    
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-2,2])
    legend('show')
    hold off

    sgtitle(defaultTitleName)

    if IMAGE_SAVING
        mkdir ..\ProcessedData\DirectKinematicsError;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\DirectKinematicsError\",BaselineFilesParameters(3),".png"],"");
        else
            path = strjoin(["..\ProcessedData\DirectKinematicsError\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path);
        close(fig1);
    end

    %% Evaluated error correction
    fixedMeanError = meanError;
    fixedTimeShift = time_lag;
    fixedIndexShift = round(mean(fixedTimeShift*100));
    if fixedIndexShift <= 0
        fixedIndexShift = 1;
    end
    adjustedPosition = table2array(cuttedPosDataSet(fixedIndexShift:end,3:5));
    adjustedPosition = adjustedPosition - fixedMeanError;
    indexShift = length(evaluatedPosition)-length(adjustedPosition);
    adjustedCuttedTime = cuttedElapsedTime(1:end-indexShift);

    dirKinError = adjustedPosition - evaluatedPosition(1:end-indexShift,:);
    time_lag = zeros(1,3); 
    meanError = zeros(1,3); 
    meanAbsStd = zeros(1,3); 
    fs = 200; % Sampling frequency
    for k = 1:3
        Ideal = adjustedPosition(:,k)-mean(adjustedPosition(:,k));
        Real = evaluatedPosition(1:end-indexShift,k)-mean(evaluatedPosition(1:end-indexShift,k));
        % Calculate the cross-correlation between the two signals
        cross_corr = xcorr(Ideal, Real);
        % Find the index of the maximum correlation value
        [~, idx_max] = max(abs(cross_corr));
        % Calculate the time lag corresponding to the maximum correlation
        time_lag(k) = (idx_max - length(Ideal)) / fs;
        meanError(k) = mean(dirKinError(:,k));
        meanAbsStd(k) = mean(std(abs(dirKinError(:,k))));
    end

    % Plot results
    fig2 = figure('Name','Positions correction comparison');
    fig2.WindowState = 'maximized';
    subplot(2,3,1), grid on, hold on
    plot(adjustedCuttedTime, adjustedPosition(:,1).*100, 'b-', 'DisplayName','Corrected dumped position')
    plot(adjustedCuttedTime, evaluatedPosition(1:end-indexShift,1).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between corrected X positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off
    subplot(2,3,2), grid on, hold on
    plot(adjustedCuttedTime, adjustedPosition(:,2).*100, 'b-', 'DisplayName','Corrected dumped position')
    plot(adjustedCuttedTime, evaluatedPosition(1:end-indexShift,2).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between corrected Y positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off
    subplot(2,3,3), grid on, hold on
    plot(adjustedCuttedTime, adjustedPosition(:,3).*100, 'b-', 'DisplayName','Corrected dumped position')
    plot(adjustedCuttedTime, evaluatedPosition(1:end-indexShift,3).*100, 'k-', 'LineWidth', 1.2, 'DisplayName','Evaluated position')
    title('Comparison between corrected Z positions')
    xlabel("Time [ min ]"), ylabel("position [ cm ]")
    legend('show')
    hold off

    subplot(2,3,4), grid on, hold on
    plot(adjustedCuttedTime, dirKinError(:,1).*100, 'b-','DisplayName','Error evaluated')
    meanLegend = strjoin(["Mean error: ",num2str(meanError(1)*100), " cm"],"");
    yline(meanError(1).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(1)*100), " cm"],"");
    yline(meanAbsStd(1).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(1))," s"],"");
    title('Error of the X position calculation',titleName)    
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-3,1])
    legend('show')
    hold off
    subplot(2,3,5), grid on, hold on
    plot(adjustedCuttedTime, dirKinError(:,2).*100, 'b-','DisplayName','Error evaluated')
    meanLegend = strjoin(["Mean error: ",num2str(meanError(2)*100), " cm"],"");
    yline(meanError(2).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(2)*100), " cm"],"");
    yline(meanAbsStd(2).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(2))," s"],"");
    title('Error of the Y position calculation',titleName)    
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-7,10])
    legend('show')
    hold off
    subplot(2,3,6), grid on, hold on
    plot(adjustedCuttedTime, dirKinError(:,3).*100, 'b-','DisplayName','Error evaluated')
    meanLegend = strjoin(["Mean error: ",num2str(meanError(3)*100), " cm"],"");
    yline(meanError(3).*100,'k--','LineWidth',2.2,'DisplayName',meanLegend)
    meanLegend = strjoin(["Mean absoluted std: ",num2str(meanAbsStd(3)*100), " cm"],"");
    yline(meanAbsStd(3).*100,'r--','LineWidth',2.2,'DisplayName',meanLegend);
    titleName = strjoin(["Phase shift: ",num2str(time_lag(3))," s"],"");
    title('Error of the Z position calculation',titleName)
    xlabel("Time [ min ]"), ylabel("error [ cm ]")
    ylim([-2,2])
    legend('show')
    hold off

    sgtitle(defaultTitleName)

    if IMAGE_SAVING
        mkdir ..\ProcessedData\DirectKinematicsError;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\DirectKinematicsError\",BaselineFilesParameters(3),"_Corrected.png"],"");
        else
            path = strjoin(["..\ProcessedData\DirectKinematicsError\P",num2str(numPerson),"_Corrected.png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig2,path);
        close(fig2);
    end

    fprintf("                                Completed in %s minutes with a mean error of [%.2f,%.2f,%.2f] cm\n",duration(0,0,toc,'Format','mm:ss.SS'),meanError(1)*100,meanError(2)*100,meanError(3)*100)
end
