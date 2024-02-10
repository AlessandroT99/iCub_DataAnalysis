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

function plotPositionFurtherAnalysis(experimentDuration, meanHtoR_time, meanRtoH_time, meanHtoR_space, meanRtoH_space, phaseTimeDifference, ...
                                nMaxPeaks, nMinPeaks, maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
                                peaksInitialAndFinalVariation, synchroEfficiency, BASELINE_NUMBER, HtoR_relativeVelocity, RtoH_relativeVelocity, ...
                                posAPeaksStd, posBPeaksStd, posAPeaksmean, posBPeaksmean, midVelocityMean, midVelocityStd, testedPeople, ROM, nearHand, meanXforce)
% This function takes in input the data generated from the position and
% force further analysis functions and plot usefull scatter and other
% diagrams in order to visualize trends or similars.

%% INPUT PARAMETERS EXPLANATION
% experimentDuration = Duration of the experiments in minutes
% meanHtoR_time = Average time for the Human to Robot phase in minutes
% meanRtoH_time = Average time for the Robot to Human phase in minutes
% meanHtoR_space = Average space for the Human to Robot phase in minutes
% meanRtoH_space = Average space for the Robot to Human phase in minutes
% phaseTimeDifference = mean of the differences between human phase time and robot phase time
% nMaxPeaks = Max peaks number
% nMinPeaks = min peaks number
% maxPeaksAverage = Max peaks value average in meters
% minPeaksAverage = min peaks value average in meters
% stdPos = Standard deviation of the whole position signal in meters
% meanPos = mean value of the whole position signal in meters
% movementRange = Movement range in meters
% maxMinAverageDistance = Average distance between the mean of max and
%                         minimum peaks in meters
% peaksVariation = Curves of peaks average variation in meters
% peaksInitialAndFinalVariation = difference between the initial peaks and
%                                 the last one in meters, this could be helpfull 
%                                 to evaluate the coordination
% synchroEfficiency = efficiency of the synchronism of the movement 
% BASELINE_NUMBER = the number of baseline loaded (=2)
% posAPeaksStd = pos A peaks standard deviation
% posBPeaksStd = pos B peaks standard deviation
% posAPeaksmean = pos A peaks average in centimeters
% posBPeaksmean =  pos B peaks average in centimeters
% personWhoFeelsFollowerOrLeader = points self attribute for the involved status from the testers
% testedPeople = index number of the test considered
% ROM = Range Of Motion, difference in meters between posA and posB
% nearHand = near end effect read directly from the excel input file
    
    %% Simulation parameters
    IMAGE_SAVING = 1; % Put to 1 in order to save the main plots
    PAUSE_TIME = 2; % Used to let the window of the plot get the full resolution size before saving
    nTest = length(experimentDuration); % Number of test analyzed
    TIME_CONVERSION_CONSTANT = 0.01;
    clearGreen = [119,221,119]./255;
    clearRed = [1,0.4,0];
    clearBlue = [0,0.6,1];
    clearYellow = [255,253,116]./255;

    customColors = zeros(36,3);
    customColors(1:9,:) = brewermap(9,'Set1');
    customColors(10:17,:) = brewermap(8,'Set2');
    customColors(18:25,:) = brewermap(8,'Pastel1');
    customColors(26:33,:) = brewermap(8,'Pastel2');
    EmptyPointLine = 1.5;
    MarkerDimension = 80;
    DottedLineWidth = 2;
    ErrorBarCapSize = 12;
    ErrorBarLineWidth = 1;
    ConnectionLineWidthROM = 0.5;
    LineTypeROM = '-';

    rightHandTests = logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)>0]);
    leftHandTests = logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)<0]);

    % Folders and priority order of the subfolders
    mkdir ..\iCub_ProcessedData\Scatters
    mkdir ..\iCub_ProcessedData\Scatters\1.NearHand
    mkdir ..\iCub_ProcessedData\Scatters\2.Symmetry
    mkdir ..\iCub_ProcessedData\Scatters\3.ROM
    mkdir ..\iCub_ProcessedData\Scatters\4.PullingPhases
    mkdir ..\iCub_ProcessedData\Scatters\5.Others

    %% Near end parameters
    nearHand = nearHand'.*1000;
    baselineYPos = max(nearHand)+5;
    baselineYPosAdded = -5;
    logicalIntervalPeaks = ~isnan(nearHand);

    %% Experiment duration - 5. OTHERS
    fig1 = figure('Name','Experiment duration scatter');
    fig1.WindowState = 'maximized';
    grid on, hold on
    scatter(experimentDuration(1),1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(experimentDuration(BASELINE_NUMBER+1:end),BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    xline(4,'k--','LineWidth',DottedLineWidth)
    title("Trend of experiment duration")
    legend("BaseLine","Desidered duration")
    xlabel("Elapsed Time [ min ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig1,"..\iCub_ProcessedData\Scatters\5.Others\ExperimentDuration.png")
        close(fig1);
    end
    
    %% Phase time durations - 4. PULLING PHASES
    fig2aa = figure('Name','Human phases duration scatter');
    fig2aa.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH_time(logical([0,0,logicalIntervalPeaks])).*TIME_CONVERSION_CONSTANT,nearHand(logicalIntervalPeaks),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(1.5,'k--')
    plot_mean_stdError(meanRtoH_time(logical([0,0,logicalIntervalPeaks])),TIME_CONVERSION_CONSTANT,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'b--')
    title("Human pulling phase time duration")
    xlabel("Elapsed Time [ s ]"), ylabel("Near-Hand Effect [ ms ]")
    legend('Human Pulling phase',"Ideal value",'Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2aa,"..\iCub_ProcessedData\Scatters\4.PullingPhases\HumanPhaseTimeDuration.png")
        close(fig2aa);
    end

    fig2ab = figure('Name','Robot phases duration scatter');
    fig2ab.WindowState = 'maximized';
    grid on, hold on
    scatter(meanHtoR_time(logical([0,0,logicalIntervalPeaks])).*TIME_CONVERSION_CONSTANT,nearHand(logicalIntervalPeaks),MarkerDimension,'red','LineWidth',EmptyPointLine)
    xline(1.5,'k--')
    plot_mean_stdError(meanHtoR_time(logical([0,0,logicalIntervalPeaks])),TIME_CONVERSION_CONSTANT,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'r--')
    title("Robot pulling phase time duration")
    xlabel("Elapsed Time [ s ]"), ylabel("Near-Hand Effect [ ms ]")
    legend('Robot Pulling phase',"Ideal value",'Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2ab,"..\iCub_ProcessedData\Scatters\4.PullingPhases\RobotPhaseTimeDuration.png")
        close(fig2ab);
    end

    %% Phase space durations - 4. PULLING PHASES
    fig2ba = figure('Name','Phases space duration scatter');
    fig2ba.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH_space(logical([0,0,logicalIntervalPeaks])).*100,nearHand(logicalIntervalPeaks),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(15,'k--')
    plot_mean_stdError(meanRtoH_space(logical([0,0,logicalIntervalPeaks])),100,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'b--')
    title("Human pulling phase space duration")
    xlabel("Space distance [ cm ]"), ylabel("Near-Hand Effect[ ms ]")
    legend('Human Pulling phase',"Ideal value",'Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2ba,"..\iCub_ProcessedData\Scatters\4.PullingPhases\HumanPhaseSpaceDuration.png")
        close(fig2ba);
    end

    fig2bb = figure('Name','Phases space duration scatter');
    fig2bb.WindowState = 'maximized';
    grid on, hold on
    scatter(meanHtoR_space(logical([0,0,logicalIntervalPeaks])).*100,nearHand(logicalIntervalPeaks),MarkerDimension,'red','LineWidth',EmptyPointLine)
    xline(15,'k--')
    plot_mean_stdError(meanHtoR_space(logical([0,0,logicalIntervalPeaks])),100,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'r--')
    title("Robot pulling phases space duration")
    xlabel("Space distance [ cm ]"), ylabel("Near-Hand Effect[ ms ]")
    legend('Human Pulling phase',"Ideal value",'Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2bb,"..\iCub_ProcessedData\Scatters\4.PullingPhases\RobotPhaseSpaceDuration.png")
        close(fig2bb);
    end

    %% Phase time difference - 4. PULLING PHASES
    fig2c = figure('Name','Phases time difference scatter');
    fig2c.WindowState = 'maximized';
    grid on, hold on
    xScat = phaseTimeDifference(logical([0,0,logicalIntervalPeaks]));
    yScat = nearHand(logicalIntervalPeaks);
    scatter(xScat.*TIME_CONVERSION_CONSTANT,yScat,MarkerDimension,'red','LineWidth',EmptyPointLine)    
    plot_mean_stdError(xScat,TIME_CONVERSION_CONSTANT,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'r--')
    title("Duration Difference of the Pulling Phases")
    xlabel("Pulling Phases Time Difference (H-R) [ s ]"), ylabel("Near-end Effect [ ms ]")
    legend("Subject",'Mean','Trend','Standard Error')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2c,"..\iCub_ProcessedData\Scatters\4.PullingPhases\DurationDifference-PullingPhases.png")
        close(fig2c);
    end

    %% Relative Velocity - 4. PULLING PHASES
    % Evaluate mean of the values
    HtoR_relativeVelocityMean = zeros(1,length(meanHtoR_space));
    for i = 1:length(HtoR_relativeVelocity)
        HtoR_relativeVelocityMean(i) = abs(mean(HtoR_relativeVelocity{i}));
    end
    RtoH_relativeVelocityMean = zeros(1,length(meanHtoR_space));
    for i = 1:length(RtoH_relativeVelocity)
        RtoH_relativeVelocityMean(i) = abs(mean(RtoH_relativeVelocity{i}));
    end
    
    % Plot results
    fig2va = figure('Name','Human phases relative velocity scatter');
    fig2va.WindowState = 'maximized';
    grid on, hold on
    scatter(RtoH_relativeVelocityMean(logical([0,0,logicalIntervalPeaks])).*100,nearHand(logicalIntervalPeaks),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    plot_mean_stdError(RtoH_relativeVelocityMean(logical([0,0,logicalIntervalPeaks])),100,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'b--')
    title("Human pulling phase relative velocity")
    xlabel("Relative Velocity [ cm/s ]"), ylabel("Near-Hand Effect [ ms ]")
    legend('Human Pulling phase','Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2va,"..\iCub_ProcessedData\Scatters\4.PullingPhases\HumanPhaseRelativeVelocity.png")
        close(fig2va);
    end

    fig2vb = figure('Name','Robot phases relative velocity scatter');
    fig2vb.WindowState = 'maximized';
    grid on, hold on
    scatter(HtoR_relativeVelocityMean(logical([0,0,logicalIntervalPeaks])).*100,nearHand(logicalIntervalPeaks),MarkerDimension,'red','LineWidth',EmptyPointLine)
    plot_mean_stdError(HtoR_relativeVelocityMean(logical([0,0,logicalIntervalPeaks])),100,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'r--')
    title("Robot pulling phase relative velocity")
    xlabel("Relative Velocity [ cm/s ]"), ylabel("Near-Hand Effect [ ms ]")
    legend('Robot Pulling phase','Mean','Trend','Standard Error')
    set(gca, 'YDir','reverse')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2vb,"..\iCub_ProcessedData\Scatters\4.PullingPhases\RobotPhaseRelativeVelocity.png")
        close(fig2vb);
    end

    %% PEAKS NUMBER - 5. OTHERS
    fig3 = figure('Name','Number of peaks scatter');
    fig3.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks(1:BASELINE_NUMBER),1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(nMinPeaks(1:BASELINE_NUMBER),1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(nMaxPeaks(BASELINE_NUMBER+1:end),BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(nMinPeaks(BASELINE_NUMBER+1:end),BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(80,'k--','LineWidth',DottedLineWidth)
    title("Trend of peaks number")
    legend('Baseline Maximums','Baseline Minimums','# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig3,"..\iCub_ProcessedData\Scatters\5.Others\PeaksNumber.png")
        close(fig3);
    end
    
    % 5. OTHERS
    fig4 = figure('Name','Number of peaks scatter vs. experiment duration');
    fig4.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks(1:BASELINE_NUMBER),experimentDuration(1:BASELINE_NUMBER),MarkerDimension,clearRed,'filled')
    scatter(nMinPeaks(1:BASELINE_NUMBER),experimentDuration(1:BASELINE_NUMBER),MarkerDimension,clearBlue,'filled')
    scatter(nMaxPeaks(BASELINE_NUMBER+1:end),experimentDuration(BASELINE_NUMBER+1:end),MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(nMinPeaks(BASELINE_NUMBER+1:end),experimentDuration(BASELINE_NUMBER+1:end),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(80,'k--','LineWidth',DottedLineWidth)
    title("Trend of peaks number vs. experiment duration")
    legend('Baseline Maximums','Baseline Minimums','# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("Elapsed Time [ min ]")
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig4,"..\iCub_ProcessedData\Scatters\5.Others\PeaksNumber-ExperimentDuration.png")
        close(fig4);
    end

    %% Peaks values - 3. ROM
    fig5 = figure('Name','Values of peaks scatter');
    fig5.WindowState = 'maximized';
    grid on, hold on
    scatter(maxPeaksAverage(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(minPeaksAverage(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(maxPeaksAverage(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(minPeaksAverage(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(maxPeaksAverage(1:BASELINE_NUMBER)*100,'k--','LineWidth',DottedLineWidth)
    xline(minPeaksAverage(1:BASELINE_NUMBER)*100,'k--','LineWidth',DottedLineWidth)
    % Replot something in order to have the correct legend and the dotted line behind all
    scatter(maxPeaksAverage(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(minPeaksAverage(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(maxPeaksAverage(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(minPeaksAverage(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    text((maxPeaksAverage(1)+minPeaksAverage(1))/2*100,1,"iCub L hand",'FontSize',12,'HorizontalAlignment','center')
    text((maxPeaksAverage(BASELINE_NUMBER)+minPeaksAverage(BASELINE_NUMBER))/2*100,1,"iCub R hand",'FontSize',12,'HorizontalAlignment','center')
    text(minPeaksAverage(1)*100+0.5,1,"Pos B",'FontSize',8,'HorizontalAlignment','left')
    text(maxPeaksAverage(1)*100-0.5,1,"Pos A",'FontSize',8,'HorizontalAlignment','right')
    text(maxPeaksAverage(BASELINE_NUMBER)*100-0.5,1,"Pos B",'FontSize',8,'HorizontalAlignment','right')
    text(minPeaksAverage(BASELINE_NUMBER)*100+0.5,1,"Pos A",'FontSize',8,'HorizontalAlignment','left')
    title("Trend of position peaks values")
    legend('Baseline Maximums average','Baseline Minimums average','Maximums average','Minimums average')
    xlabel("Peaks value [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5,"..\iCub_ProcessedData\Scatters\3.ROM\ROM_NoPhoto.png")
        close(fig5);
    end

    %% Another alternative - ROM INTO NEAR END ZERO POS B - 1. NEAR END
    fig5e = figure('Name','Range of Motion (ROM)');
    fig5e.WindowState = 'maximized';
    hold on
    
    newLeftHandTests = logical([0,0,(maxPeaksAverage(BASELINE_NUMBER+1:end)<0).*logicalIntervalPeaks]);
    newRightHandTests = logical([0,0,(maxPeaksAverage(BASELINE_NUMBER+1:end)>0).*logicalIntervalPeaks]);

    tmpMaxPeaksAverage(newRightHandTests) = maxPeaksAverage(newRightHandTests) - posBPeaksmean(BASELINE_NUMBER)/100;
    tmpMaxPeaksAverage(newLeftHandTests) = abs(maxPeaksAverage(newLeftHandTests)) - abs(posBPeaksmean(1))/100;
    tmpMinPeaksAverage(newRightHandTests) = minPeaksAverage(newRightHandTests) - posBPeaksmean(BASELINE_NUMBER)/100;
    tmpMinPeaksAverage(newLeftHandTests) = abs(minPeaksAverage(newLeftHandTests)) - abs(posBPeaksmean(1))/100;

    % iCub R hand - max
    scatter(tmpMaxPeaksAverage(newRightHandTests).*100, nearHand(logical(newRightHandTests(3:end))), MarkerDimension,'red','filled')

    % iCub L hand - max
    scatter(tmpMaxPeaksAverage(newLeftHandTests).*100, nearHand(logical(newLeftHandTests(3:end))), MarkerDimension,'blue','filled')

    % Plot union lines between points to describe ROM
    plot([tmpMaxPeaksAverage(newLeftHandTests).*100;tmpMinPeaksAverage(newLeftHandTests).*100], ...
         [nearHand(logical(newLeftHandTests(3:end)));nearHand(logical(newLeftHandTests(3:end)))], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[0,0,1])
    plot([tmpMaxPeaksAverage(newRightHandTests).*100;tmpMinPeaksAverage(newRightHandTests).*100], ...
         [nearHand(logical(newRightHandTests(3:end)));nearHand(logical(newRightHandTests(3:end)))], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[1,0,0])

    % iCub R hand - min
    scatter(tmpMinPeaksAverage(newRightHandTests).*100, nearHand(newRightHandTests(3:end)),MarkerDimension, 'red','filled')

    % iCub L hand - min
    scatter(tmpMinPeaksAverage(newLeftHandTests).*100, nearHand(newLeftHandTests(3:end)), MarkerDimension,'blue','filled')

    % Error bars
    minPeaksStandardError = abs(posAPeaksStd)./sqrt(nMinPeaks);
    errorbar(tmpMinPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearHand(logicalIntervalPeaks), ...
             -minPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, minPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    maxPeaksStandardError = abs(posBPeaksStd)./sqrt(nMaxPeaks);
    errorbar(tmpMaxPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearHand(logicalIntervalPeaks), ...
             -maxPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, maxPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)

    xline(0,'k--','LineWidth',DottedLineWidth)

    title("Range Of Motion (ROM) of iCub hand and Near-Hand Effect")
    legend('R Hand of iCub', 'L Hand of iCub','Range Of Motion (ROM)','Location','southwest')
    xlabel("Distance from Baseline Max Point [ cm ]"), ylabel("Near-Hand Effect [ ms ]")
    xlim([-20,2]), ylim([min(nearHand)-3,max(nearHand)+3])
    set(gca, 'YDir','reverse')

    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5e,"..\iCub_ProcessedData\Scatters\1.NearHand\ROM-NearHand_AlignedPosB.png")
        close(fig5e);
    end

    %% Another alternative - ROM INTO NEAR END ZERO POS B FITTING LINES - 1. NEAR END
    save ..\iCub_ProcessedData\data4ROM-AlignedB;
    save snippetOfPlot_4Giulia\data4ROM-AlignedB;

    fig5f = figure('Name','Range of Motion (ROM)');
    fig5f.WindowState = 'maximized';
    hold on

    YLIM_max = max(nearHand)+5;
    YLIM_min = min(nearHand)-5;

    [sorted_NearHand_4_PosA, indicesA] = sort([nearHand(logical(newLeftHandTests(3:end))),nearHand(logical(newRightHandTests(3:end)))]);
    sorted_PosA = [tmpMaxPeaksAverage(newLeftHandTests),tmpMinPeaksAverage(newRightHandTests)].*100;
    sorted_PosA = sorted_PosA(indicesA);
    % iCub min (posA)
    scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')
    p = polyfit(sorted_NearHand_4_PosA, sorted_PosA, 1);
    newYA = polyval(p, linspace(YLIM_min,YLIM_max));
    plot(newYA, linspace(YLIM_min,YLIM_max), 'b-')
    
    [sorted_NearHand_4_PosB, indicesB] = sort([nearHand(logical(newRightHandTests(3:end))),nearHand(logical(newLeftHandTests(3:end)))]);
    sorted_PosB = [tmpMaxPeaksAverage(newRightHandTests),tmpMinPeaksAverage(newLeftHandTests)].*100;
    sorted_PosB = sorted_PosB(indicesB);
    % iCub max (posB)
    scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
    p = polyfit(sorted_NearHand_4_PosB, sorted_PosB, 1);
    newYB = polyval(p, linspace(YLIM_min,YLIM_max));
    plot(newYB, linspace(YLIM_min,YLIM_max), 'r-')
    
    % Vectors containing the ROM middle point coordinates
    Mx = [(tmpMaxPeaksAverage(newRightHandTests)+tmpMinPeaksAverage(newRightHandTests))./2.*100,(tmpMaxPeaksAverage(newLeftHandTests)+tmpMinPeaksAverage(newLeftHandTests))./2.*100];
    My = [nearHand(logical(newRightHandTests(3:end))),nearHand(logical(newLeftHandTests(3:end)))];

    % Plot a single marker and a single line just for legend purposes
    plot([tmpMaxPeaksAverage(3).*100;tmpMinPeaksAverage(3).*100], [nearHand(1);nearHand(1)], '-','LineWidth',1,'Color', [0,0,0])
%     plot(Mx(1),My(1), '^','LineWidth',1,'Color', [0,1,0])

    % Trend Line for middle points
    % [sorted_NearHand_4_PosM, indicesM] = sort(My);
    % sorted_PosM = Mx(indicesM);
    % p = polyfit(sorted_NearHand_4_PosM, sorted_PosM, 1);
    % newYM = polyval(p, linspace(YLIM_min,YLIM_max));
    % plot(newYM, linspace(YLIM_min,YLIM_max), 'g-')

    % Plot union lines between points to describe ROM
    plot([tmpMaxPeaksAverage(newLeftHandTests).*100;tmpMinPeaksAverage(newLeftHandTests).*100], ...
         [nearHand(logical(newLeftHandTests(3:end)));nearHand(logical(newLeftHandTests(3:end)))], ...
         '-','LineWidth',1,'Color', [0,0,0])
    plot([tmpMaxPeaksAverage(newRightHandTests).*100;tmpMinPeaksAverage(newRightHandTests).*100], ...
         [nearHand(logical(newRightHandTests(3:end)));nearHand(logical(newRightHandTests(3:end)))], ...
         '-','LineWidth',1,'Color', [0,0,0])
    
    % Replot for graphycal issues
    scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
    scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')
    
    % Plot triangles to indicate the mean of the ROM of each participant
%     plot(Mx, My, '^','LineWidth',1,'Color', [0,1,0])

    xLineA = ((abs(maxPeaksAverage(1))-abs(minPeaksAverage(1)))+(minPeaksAverage(BASELINE_NUMBER)-maxPeaksAverage(BASELINE_NUMBER)))/2*100; 
    xline(xLineA,'b--','LineWidth',1)
    xline(0,'r--','LineWidth',1)
%     xline(xLineA/2,'g--','LineWidth',1)
    text(xLineA+0.2,31,"A*",'FontSize',12, 'Color', [0,0,1])
    text(0.2,31,"B*",'FontSize',12, 'Color',[1,0,0])
%     text(xLineA/2+0.2,31,"M*",'FontSize',12, 'Color',[0,1,0])

    title("Asymmetry of A position")
    legend('Point A', 'Trend of Point A', 'Point B', 'Trend of point B', "iCub's Hand ROM", 'Location','southwest')
    % legend('Point A', 'Trend of Point A', 'Point B', 'Trend of point B', "iCub's Hand ROM", "ROM Middle Point", "Trend of ROM middle", 'Location','southwest')
    xlabel("Range of Motion (ROM) Of iCub's Hand [cm]"), ylabel("Near-Hand Effect [ms]")
    xlim([-19,1]), ylim([YLIM_min,YLIM_max])
    set(gca, 'YDir','reverse')

    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5f,"..\iCub_ProcessedData\Scatters\1.NearHand\ROM-NearHand_NewAlignedPosB.png")
        close(fig5f);
    end

    %% Another alternative - ROM INTO NEAR END EFFECT ZERO MEAN CENTER - 1. NEAR END
    fig5d = figure('Name','Range of Motion (ROM)');
    fig5d.WindowState = 'maximized';
    hold on

    % Removing mean from values
    meanROM = (maxPeaksAverage+minPeaksAverage)./2;
    maxPeaksAverage = maxPeaksAverage - meanROM; 
    minPeaksAverage = minPeaksAverage - meanROM;

    newLeftHandTests = logical([0,0,(maxPeaksAverage(BASELINE_NUMBER+1:end)<-meanROM(BASELINE_NUMBER+1:end)).*logicalIntervalPeaks]);
    newRightHandTests = logical([0,0,(maxPeaksAverage(BASELINE_NUMBER+1:end)>-meanROM(BASELINE_NUMBER+1:end)).*logicalIntervalPeaks]);

    % iCub R hand - max
    scatter(maxPeaksAverage(BASELINE_NUMBER).*100,baselineYPos-baselineYPosAdded,MarkerDimension,clearRed,'filled')
    scatter(maxPeaksAverage(newRightHandTests).*100, nearHand(logical(newRightHandTests(3:end))), MarkerDimension,'red','filled')

    % Copies for legend
    plot([maxPeaksAverage(6).*100;minPeaksAverage(6).*100], [nearHand(4);nearHand(4)], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[1,0,0])

    % iCub L hand - max
    scatter(maxPeaksAverage(1).*100,baselineYPos,MarkerDimension,clearBlue,'filled')
    scatter(maxPeaksAverage(newLeftHandTests).*100, nearHand(logical(newLeftHandTests(3:end))), MarkerDimension,'blue','filled')

    % Copies for legend
    plot([maxPeaksAverage(3).*100;minPeaksAverage(3).*100], [nearHand(1);nearHand(1)], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[0,0,1])

    [sorted_NH, idx] = sort([nearHand(newLeftHandTests(3:end)),nearHand(newRightHandTests(3:end))]);
    sortedB = maxPeaksAverage(idx+BASELINE_NUMBER).*100;
    p = polyfit(sorted_NH, sortedB, 1);
    newYB = polyval(p, linspace(YLIM_min,40));
    plot(newYB, linspace(YLIM_min,50), 'k-')

    sortedA = minPeaksAverage(idx+BASELINE_NUMBER).*100;
    p = polyfit(sorted_NH, sortedA, 1);
    newYA = polyval(p, linspace(YLIM_min,50));
    plot(newYA, linspace(YLIM_min,50), 'k-')
    

    % Plot union lines between points to describe ROM
    plot([maxPeaksAverage(newLeftHandTests).*100;minPeaksAverage(newLeftHandTests).*100], ...
         [nearHand(logical(newLeftHandTests(3:end)));nearHand(logical(newLeftHandTests(3:end)))], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[0,0,1])
    plot([maxPeaksAverage(newRightHandTests).*100;minPeaksAverage(newRightHandTests).*100], ...
         [nearHand(logical(newRightHandTests(3:end)));nearHand(logical(newRightHandTests(3:end)))], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',[1,0,0])
    plot([maxPeaksAverage(1).*100;minPeaksAverage(1).*100],[baselineYPos;baselineYPos], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',clearBlue)
    plot([maxPeaksAverage(BASELINE_NUMBER).*100;minPeaksAverage(BASELINE_NUMBER).*100], ...
         [baselineYPos-baselineYPosAdded;baselineYPos-baselineYPosAdded], ...
         LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color',clearRed)

    % iCub R hand - min
    scatter(minPeaksAverage(BASELINE_NUMBER).*100,baselineYPos-baselineYPosAdded,MarkerDimension,clearRed,'filled')
    scatter(minPeaksAverage(newRightHandTests).*100, nearHand(newRightHandTests(3:end)),MarkerDimension, 'red','filled')

    % iCub L hand - min
    scatter(minPeaksAverage(1).*100,baselineYPos,MarkerDimension,clearBlue,'filled')
    scatter(minPeaksAverage(newLeftHandTests).*100, nearHand(newLeftHandTests(3:end)), MarkerDimension,'blue','filled')

    % Error bars
%     errorbar(minPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearHand(logicalIntervalPeaks), ...
%              -minPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, minPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, ...
%              'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
%     errorbar(minPeaksAverage(1:BASELINE_NUMBER).*100, [baselineYPos,baselineYPos-baselineYPosAdded], ...
%              -minPeaksStandardError(1:BASELINE_NUMBER)./2, minPeaksStandardError(1:BASELINE_NUMBER)./2, ...
%              'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
%     errorbar(maxPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearHand(logicalIntervalPeaks), ...
%              -maxPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, maxPeaksStandardError(logical([0,0,logicalIntervalPeaks]))./2, ...
%              'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
%     errorbar(maxPeaksAverage(1:BASELINE_NUMBER).*100, [baselineYPos,baselineYPos-baselineYPosAdded], ...
%              -maxPeaksStandardError(1:BASELINE_NUMBER)./2, maxPeaksStandardError(1:BASELINE_NUMBER)./2, ...
%              'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)

    title("Range Of Motion (ROM) of iCub's hand")
    legend('R iCub Baseline','R iCub interaction', 'R Range Of Motion (ROM)', ...
           'L iCub Baseline','L iCub interaction', 'L Range Of Motion (ROM)', ...
           'Participant Trend', 'Location','southeast')
    xlabel("Range of Motion (ROM) with aligned centers [ cm ]"), ylabel("Near-Hand Effect [ ms ]")
    xSize = 1;
    ySize = xSize/0.75*10;
    yDim = baselineYPos + ySize + 4;
    xlim([min(min(maxPeaksAverage),min(minPeaksAverage))*100-2,max(max(maxPeaksAverage),max(minPeaksAverage))*100+2])
    ylim([min(nearHand)-1,yDim+5])
    set(gca, 'YDir','reverse')

    iCubImg = imread("..\iCub_InputData\images\iCub_hand.png");
    iCubImg = flipud(iCubImg);
    vSpace = 2.5;
    xDim = 0;
    image(iCubImg,'xdata',[xDim-xSize/2,xDim+xSize/2],'ydata',[yDim+vSpace,yDim-ySize+vSpace])
    
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5d,"..\iCub_ProcessedData\Scatters\1.NearHand\ROM-NearHand_AlignedCenter.png")
        close(fig5d);
    end

    %% POS A PLOT  
    % Generate y data
    deviationPosfromA = zeros(1,length(posAPeaksmean));
    deviationPosfromA(rightHandTests) = abs(posAPeaksmean(rightHandTests))-abs(posAPeaksmean(BASELINE_NUMBER));
    deviationPosfromA(leftHandTests) = abs(posAPeaksmean(leftHandTests))-abs(posAPeaksmean(1));

    %% POS B PLOT
    % Generate y data
    deviationPosfromB = zeros(1,length(posBPeaksmean));
    deviationPosfromB(rightHandTests) = abs(posBPeaksmean(rightHandTests))-abs(posBPeaksmean(BASELINE_NUMBER));
    deviationPosfromB(leftHandTests) = abs(posBPeaksmean(leftHandTests))-abs(posBPeaksmean(1));

    %% DISTANCE AVERAGE BETWEEN POS A AND POS B PLOT
    % Generate y data
    deviationPosfromAverage = zeros(1,length(meanPos));
    deviationPosfromAverage(rightHandTests) = abs(meanPos(rightHandTests))-abs(meanPos(BASELINE_NUMBER));
    deviationPosfromAverage(leftHandTests) = abs(meanPos(leftHandTests))-abs(meanPos(1));

    %% Saving matrices usefull for statistical analysis
    posAidx = [mean(abs(posAPeaksmean(1:BASELINE_NUMBER))),abs(posAPeaksmean(BASELINE_NUMBER+1:end))]';
    posBidx = [mean(abs(posBPeaksmean(1:BASELINE_NUMBER))),abs(posBPeaksmean(BASELINE_NUMBER+1:end))]';
    devPosAidx = [mean(deviationPosfromA(1:BASELINE_NUMBER)),deviationPosfromA(BASELINE_NUMBER+1:end)]';
    devPosBidx = [mean(deviationPosfromB(1:BASELINE_NUMBER)),deviationPosfromB(BASELINE_NUMBER+1:end)]';
    ROMdeviationCenterFromBaseline = zeros(length(posAidx),1);
    ROMdeviationCenterFromBaseline(leftHandTests(2:end)) = (posAidx(leftHandTests(2:end))+posBidx(leftHandTests(2:end)))./2-abs(posAPeaksmean(1)+posBPeaksmean(1))/2;
    ROMdeviationCenterFromBaseline(rightHandTests(2:end)) = (posAidx(rightHandTests(2:end))+posBidx(rightHandTests(2:end)))./2-abs(posAPeaksmean(BASELINE_NUMBER)+posBPeaksmean(BASELINE_NUMBER))/2;

    % Just for debug
%     tmpMatx = zeros(1,length(ROM));
%     tmpMatx(rightHandTests) = ROM(rightHandTests)'-abs(devPosAidx(rightHandTests(2:end)))+abs(devPosBidx(rightHandTests(2:end)));
%     tmpMatx(leftHandTests) = ROM(leftHandTests)'-abs(devPosAidx(leftHandTests(2:end)))+abs(devPosBidx(leftHandTests(2:end)));
%     tmpBaseline = (abs(posBPeaksmean(1))-abs(posAPeaksmean(1)))*leftHandTests+(abs(posBPeaksmean(2))-abs(posAPeaksmean(2)))*rightHandTests;
%     tmpTable = table(testedPeople',ROM(BASELINE_NUMBER+1:end)',abs(devPosAidx(2:end)),abs(devPosBidx(2:end)),tmpMatx(3:end)',tmpBaseline(3:end)','VariableNames',["ID","ROM","Deviation PosA","Deviation PosB","ROM-a+b","Baseline ROM"]);
%     writetable(tmpTable, "..\iCub_ProcessedData\BaselineROM_checkQuestion.xlsx");

    matx = table([-1;testedPeople'],posBidx,posAidx,devPosBidx,devPosAidx, [mean(ROM(1:BASELINE_NUMBER));ROM(BASELINE_NUMBER+1:end)'], ROMdeviationCenterFromBaseline, ...
                 [mean(phaseTimeDifference(1:BASELINE_NUMBER));phaseTimeDifference(BASELINE_NUMBER+1:end)'].*TIME_CONVERSION_CONSTANT, [0,nearHand]', ...
                 [mean(meanRtoH_time(1:BASELINE_NUMBER));meanRtoH_time(BASELINE_NUMBER+1:end)'].*TIME_CONVERSION_CONSTANT,[mean(meanHtoR_time(1:BASELINE_NUMBER));meanHtoR_time(BASELINE_NUMBER+1:end)'].*TIME_CONVERSION_CONSTANT, ...
                 [mean(meanRtoH_space(1:BASELINE_NUMBER).*100);meanRtoH_space(BASELINE_NUMBER+1:end)'.*100],[mean(meanHtoR_space(1:BASELINE_NUMBER).*100);meanHtoR_space(BASELINE_NUMBER+1:end)'.*100], ...
                 [mean(HtoR_relativeVelocityMean(1:BASELINE_NUMBER));HtoR_relativeVelocityMean(BASELINE_NUMBER+1:end)'].*100, [mean(RtoH_relativeVelocityMean(1:BASELINE_NUMBER));RtoH_relativeVelocityMean(BASELINE_NUMBER+1:end)'].*100, ...
                 [mean(posBPeaksStd(1:BASELINE_NUMBER));posBPeaksStd(BASELINE_NUMBER+1:end)'], [mean(posAPeaksStd(1:BASELINE_NUMBER));posAPeaksStd(BASELINE_NUMBER+1:end)']);

    matx = renamevars(matx, 1:width(matx), ["ID","posB [cm]","posA [cm]", "Deviation from B [cm]","Deviation from A [cm]", ...
                                            "ROM [cm]", "Simmetry [cm]", "Phase Delay [s]", "Near-Hand [ms]", ...
                                            "Human-Phase TimeDomain [s]", "Robot-Phase TimeDomain [s]", "Human-Phase SpaceDomain [cm]", "Robot-Phase SpaceDomain [cm]", ...
                                            "Robot-Phase RelativeVelocity [cm/s]", "Human-Phase RelativeVelocity [cm/s]", "std(posB) [cm]","std(posA) [cm]"]);

    if isfile("..\iCub_ProcessedData\PeaksPositionData.xlsx")
        delete("..\iCub_ProcessedData\PeaksPositionData.xlsx");
    end
    writetable(matx, "..\iCub_ProcessedData\PeaksPositionData.xlsx");

    %% Difference between ROM centers - 1. NEAR END
    fig5n = figure('Name','Difference betweeen ROM centers');
    fig5n.WindowState = 'maximized';
    grid on, hold on

    % R Hand
    scatter(ROM(newRightHandTests), nearHand(newRightHandTests(3:end)), MarkerDimension,'red','LineWidth',EmptyPointLine)
    % L Hand
    scatter(ROM(newLeftHandTests), nearHand(newLeftHandTests(3:end)), MarkerDimension,'blue','LineWidth',EmptyPointLine)

    plot_mean_stdError(ROM(logical([0,0,logicalIntervalPeaks])),1,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'k--')
    limY = [min(nearHand)-2,max(nearHand)+2];
    
    ylim(limY)
    set(gca, 'YDir','reverse')
    title("Correlation ROM / Near-Hand Effect")
    legend('R iCub Hand', 'L iCub Hand','Mean','Trend','Location','southeast')
    xlabel("ROM of iCub's Hand [ cm ]"), ylabel("Near-Hand Effect [ ms ]")
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5n,"..\iCub_ProcessedData\Scatters\1.NearHand\ROM-NearHand_ROMsize.png")
        close(fig5n);
    end

    %% Standard deviation - 5. OTHERS
    fig6 = figure('Name','Standard deviation scatter');
    fig6.WindowState = 'maximized';
    grid on, hold on
    scatter(stdPos(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(stdPos(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    title("Trend of position standard deviation")
    legend("Baseline Std","Std")
    xlabel("Standard deviation [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig6,"..\iCub_ProcessedData\Scatters\5.Others\StandardDeviation.png")
        close(fig6);
    end

    %% Mean values - 5. OTHERS
    fig7 = figure('Name','Mean values scatter');
    fig7.WindowState = 'maximized';
    grid on, hold on
    scatter(meanPos(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(meanPos(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    xline(meanPos(1).*100,'k--','LineWidth',DottedLineWidth)
    xline(meanPos(BASELINE_NUMBER).*100,'k--','LineWidth',DottedLineWidth)
    % Replot something in order to have the correct legend and the dotted line behind all
    scatter(meanPos(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(meanPos(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    title("Trend of position mean values")
    legend("Baseline mean value","Mean values")
    xlabel("Mean [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig7,"..\iCub_ProcessedData\Scatters\5.Others\MeanValues.png")
        close(fig7);
    end

    %% Movement range - 5. OTHERS
    fig8 = figure('Name','Movement range plot');
    fig8.WindowState = 'maximized';
    grid on, hold on
    plot(1:size(movementRange,2),movementRange(1:BASELINE_NUMBER,:).*100,'k--','LineWidth',2.2)
    h = plot(1:size(movementRange,2),movementRange(BASELINE_NUMBER+1:end,:).*100,'LineWidth',1.5);

    legendName(1:BASELINE_NUMBER) = "Baseline";
    for i = 1:size(movementRange,1)-BASELINE_NUMBER
        set(h(i),'Color',customColors(i,:));
        legendName(i+BASELINE_NUMBER) = strjoin(["Test N. ",num2str(i)],"");
    end

    title("Trend of position movement ranges")
    legend(legendName,'Location','eastoutside')
    xlabel("Simulation progress [ % ]")
    ylabel("Movement [ cm ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig8,"..\iCub_ProcessedData\Scatters\5.Others\MovementRange.png")
        close(fig8);
    end

    %% Max e Min average distance - 5. OTHERS
    fig9 = figure('Name','Average distances bewteen MAX e min scatter');
    fig9.WindowState = 'maximized';
    grid on, hold on
    scatter(maxMinAverageDistance(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(maxMinAverageDistance(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    title("Trend of position Average distances bewteen MAX e min")
    legend("Baseline Average distance","Average distances")
    xlabel("Average distance bewteen MAX e min [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig9,"..\iCub_ProcessedData\Scatters\5.Others\MaxMinAverageDistance.png")
        close(fig9);
    end

    %% Peaks variation - 3. ROM
    fig10 = figure('Name','Peaks variation plot');
    fig10.WindowState = 'maximized';
    grid on, hold on
    plot((abs(maxPeaksVariation(1,:))+abs(minPeaksVariation(BASELINE_NUMBER,:)))./2.*100,1:size(maxPeaksVariation,2),'k-.','LineWidth',2.2)
    plot((abs(maxPeaksVariation(BASELINE_NUMBER,:))+abs(minPeaksVariation(1,:)))./2.*100,1:size(minPeaksVariation,2),'k--','LineWidth',2.2)
    hmax = plot(abs(maxPeaksVariation(BASELINE_NUMBER+1:end,:)).*100,1:size(maxPeaksVariation,2),'-','LineWidth',1.5);
    hmin = plot(abs(minPeaksVariation(BASELINE_NUMBER+1:end,:)).*100.,1:size(minPeaksVariation,2),'-','LineWidth',1.5);
    
    legendName(1:BASELINE_NUMBER) = ["Baseline Min","Baseline Max"];
    for i = 1:size(maxPeaksVariation,1)-BASELINE_NUMBER
        set(hmax(i),'Color',customColors(i,:));
        set(hmin(i),'Color',customColors(i,:));
        legendName(i+BASELINE_NUMBER) = strjoin(["Test N. ",num2str(i)," variation"],"");
    end

    title("Range Of Motion (ROM) in time domain")
    legend(legendName,'Location','eastoutside')
    ylabel("Simulation progress [ % ]"), xlabel("Variation [ cm ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig10,"..\iCub_ProcessedData\Scatters\3.ROM\ROM_TimeDomain.png")
        close(fig10);
    end
    
    %% Peaks initial and final variation - 5. OTHERS
    fig11 = figure('Name','Initial and final movement range variation scatter');
    fig11.WindowState = 'maximized';
    grid on, hold on
    scatter(peaksInitialAndFinalVariation(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(peaksInitialAndFinalVariation(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'black','LineWidth',EmptyPointLine)
    title("Trend of position Initial and final movement range variation")
    legend("Baseline variation","Variations")
    xlabel("Average distance bewteen MAX e min [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig11,"..\iCub_ProcessedData\Scatters\5.Others\PeaksInitialFinalVariation.png")
        close(fig11);
    end

    %% Synchronism efficiency based on positions - 5. OTHERS
    synchroEfficiency = synchroEfficiency(BASELINE_NUMBER+1:end,:);
    fig12 = figure('Name','Synchronism efficiency plot');
    fig12.WindowState = 'maximized';
    grid on, hold on
    h = plot(1:size(synchroEfficiency,2),synchroEfficiency,'LineWidth',1.5);

    legendName = strings(1,size(synchroEfficiency,1));
    for i = 1:size(synchroEfficiency,1)
        set(h(i),'Color',customColors(i,:));
        legendName(i) = strjoin(["Test N. ",num2str(i)],"");
    end

    title("Trend of synchronism efficiency")
    legend(legendName,'Location','eastoutside')
    ylim([0,100])
    xlabel("Simulation progress [ % ]")
    ylabel("Efficiency [ % ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig12,"..\iCub_ProcessedData\Scatters\5.Others\SynchroEfficience.png")
        close(fig12);
    end

    %% Simmetry efficience - 2. SIMMETRY
    fig13 = figure('Name','Synchronism efficience plot');
    fig13.WindowState = 'maximized';
    grid on, hold on

    % Number of color changes
    numGradations = length(ROM(3:end));
    % Generation of vector of end and start for colors
    greenColor = [0, 1, 0];  % Green
    redColor = [1, 0, 0];    % Red
    % Create the color vector with all the shades
    colorVector = zeros(numGradations, 3);
    for i = 1:numGradations
        colorVector(i, :) = (1 - i/numGradations) * redColor + (i/numGradations) * greenColor;
    end

    yValue = zeros(1,length(ROM(3:end)));
    yValue(newLeftHandTests(3:end)) = ROM(newLeftHandTests)-ROM(1);
    yValue(newRightHandTests(3:end)) = ROM(newRightHandTests)-ROM(BASELINE_NUMBER);

    scatter(ROMdeviationCenterFromBaseline(2:end)',yValue,50,colorVector,'LineWidth',1.8)
    scatter(mean(ROMdeviationCenterFromBaseline(2:end)),mean(yValue), 150,'black','filled')
    standardError = std(yValue)/sqrt(length(testedPeople));
    errorbar(mean(ROMdeviationCenterFromBaseline(2:end)),mean(yValue),-standardError./2,standardError./2, 'k', 'LineStyle','none','LineWidth',0.8)
    xline(0,'k-','LineWidth',2)
    standardError = std(ROMdeviationCenterFromBaseline(2:end))/sqrt(length(testedPeople));
    errorbar(mean(ROMdeviationCenterFromBaseline(2:end)),mean(yValue),-standardError./2,standardError./2, 'Horizontal', 'k', 'LineStyle','none','LineWidth',0.8)

    text(0,mean(yValue),"BASELINE POSITION",'FontSize',14,'HorizontalAlignment','center','VerticalAlignment','bottom','Rotation',90)

    title("Simmetry efficience","Red = Low Near-Hand   -   Green = High Near-Hand")
    legend("Test samples","Mean of the samples","Standard Error","Baseline",'Location','northwest')
    xlabel("Difference from baseline ROM center [ cm ]")
    ylabel("Similarity to baseline ROM size [ cm ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig13,"..\iCub_ProcessedData\Scatters\2.Symmetry\SimmetryEfficience.png")
        close(fig13);
    end

    %% Velocity analysis - 1. NEAR HAND
    fig14 = figure('Name','Velocity middle peaks trend analysis');
    fig14.WindowState = 'maximized';
    grid on, hold on
    scatter(abs(midVelocityMean(logical([0,0,logicalIntervalPeaks]))).*100, nearHand(logicalIntervalPeaks), MarkerDimension, 'red', 'LineWidth', 1.8, 'DisplayName','Experiments values');
    plot_mean_stdError(abs(midVelocityMean(logical([0,0,logicalIntervalPeaks]))),100,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'b--')
    title("Velocity middle peaks trend analysis")
    legend('Subjects','Mean','Trend','Standard Error','Location','eastoutside')
    xlabel("Mean [ cm/s ]")
    ylabel("Near Hand Effect [ ms ]")
    set(gca, 'YDir','reverse')
    hold off    

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig14,"..\iCub_ProcessedData\Scatters\1.NearHand\NearHand-VelocityMiddleAnalysis.png")
        close(fig14);
    end

    %% Mean of the original force on x axis - 5. OTHERS
    % fig15 = figure('Name','Experiment duration scatter');
    % fig15.WindowState = 'maximized';
    % grid on, hold on
    % scatter(meanXforce(leftHandTests),1:length(meanXforce(leftHandTests)),MarkerDimension,clearBlue,'filled')
    % scatter(meanXforce(rightHandTests),1:length(meanXforce(rightHandTests)),MarkerDimension,clearRed,'filled')
    % leftFmean = mean(meanXforce(leftHandTests));
    % rightFmean = mean(meanXforce(rightHandTests));
    % xline(leftFmean,'k--')
    % xline(rightFmean,'k--')
    % legend("R Hand tests","L Hand tests",strjoin(["Left hand mean: ",num2str(leftFmean)],""),strjoin(["Right hand mean: ",num2str(rightFmean)],""))
    % title("Mean amplitude of the force signal")
    % xlabel("Force [ N ]"), ylabel("# Test")
    % hold off
    % 
    % if IMAGE_SAVING
    %     pause(PAUSE_TIME);
    %     exportgraphics(fig15,"..\iCub_ProcessedData\Scatters\5.Others\OriginalXForceMean.png")
    %     close(fig15);
    % end
end
