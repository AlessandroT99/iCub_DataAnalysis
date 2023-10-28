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

% TODO:
% - Adust the number of the tests visualized in the legend

function plotFurtherAnalysis(experimentDuration, meanHtoR, meanRtoH, nMaxPeaks, nMinPeaks, ...
                                maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
                                peaksInitialAndFinalVariation, synchroEfficiency, BASELINE_NUMBER, ...
                                posAPeaksStd, posBPeaksStd, posAPeaksmean, posBPeaksmean, personWhoFeelsFollowerOrLeader, testedPeople)
% This function takes in input the data generated from the position and
% force further analysis functions and plot usefull scatter and other
% diagrams in order to visualize trends or similars.
    
    %% Simulation parameters
    IMAGE_SAVING = 1;
    PAUSE_TIME = 1;
    nTest = length(experimentDuration); % Number of test analyzed
    clearGreen = [119,221,119]./255;
    clearRed = [1,0.4,0];
    clearBlue = [0,0.6,1];
    clearYellow = [255,253,116]./255;

    customColors = zeros(36,3);
    customColors(1:9,:) = brewermap(9,'Set1');
    customColors(10:17,:) = brewermap(8,'Set2');
    customColors(18:25,:) = brewermap(8,'Pastel1');
    customColors(26:33,:) = brewermap(8,'Pastel2');
    textFont = 16;
    EmptyPointLine = 1.5;
    MarkerDimension = 80;
    DottedLineWidth = 2;
    ErrorBarCapSize = 12;
    ErrorBarLineWidth = 0.8;

    mkdir ..\ProcessedData\Scatters

    %% Experiment duration
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
        exportgraphics(fig1,"..\ProcessedData\Scatters\ExperimentDuration.png")
        close(fig1);
    end
    
    %% Phase durations
    fig2 = figure('Name','Phases duration scatter');
    fig2.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH(1:BASELINE_NUMBER)*60,1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(meanHtoR(1:BASELINE_NUMBER)*60,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(meanRtoH(BASELINE_NUMBER+1:end)*60,BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    scatter(meanHtoR(BASELINE_NUMBER+1:end)*60,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    xline(1.5,'k--','LineWidth',DottedLineWidth)
    title("Trend of phases duration")
    legend("BaseLine RtoH","BaseLine HtoR",'Robot to Human','Human to Robot','Desidered duration')
    xlabel("Elapsed Time [ s ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2,"..\ProcessedData\Scatters\PhaseDuration.png")
        close(fig2);
    end
    
    %% Peaks number
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
        exportgraphics(fig3,"..\ProcessedData\Scatters\PeaksNumber.png")
        close(fig3);
    end
    
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
        exportgraphics(fig4,"..\ProcessedData\Scatters\PeaksNumber-ExperimentDuration.png")
        close(fig4);
    end

    %% Peaks values
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
    text((maxPeaksAverage(1)+minPeaksAverage(1))/2*100,1,"iCub SX hand",'FontSize',12,'HorizontalAlignment','center')
    text((maxPeaksAverage(BASELINE_NUMBER)+minPeaksAverage(BASELINE_NUMBER))/2*100,1,"iCub DX hand",'FontSize',12,'HorizontalAlignment','center')
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
        exportgraphics(fig5,"..\ProcessedData\Scatters\PeaksValues.png")
        close(fig5);
    end

    % Also plotting scatters with mean and variance as axis
    %% POS A PLOT
    fig5a = figure('Name','Values of peaks posA, mean and variance');
    fig5a.WindowState = 'maximized';
    subplot(1,2,1), grid on, hold on
    
    % Generate y data
    deviationPosfromA = zeros(1,length(posAPeaksmean));
    deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])) = abs(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0]))-posAPeaksmean(1));
    deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])) = abs(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0]))-posAPeaksmean(BASELINE_NUMBER));
    
    scatter(posAPeaksmean(1),deviationPosfromA(1),MarkerDimension,clearRed,'filled')
    scatter(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])),deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])),MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(posAPeaksmean(BASELINE_NUMBER),deviationPosfromA(BASELINE_NUMBER),MarkerDimension,clearBlue,'filled')
    scatter(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])),deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    
    scatter(posAPeaksmean(logical([0,0,personWhoFeelsFollowerOrLeader==-1])),deviationPosfromA(logical([0,0,personWhoFeelsFollowerOrLeader==-1])),MarkerDimension/3,clearGreen,'filled')
    scatter(posAPeaksmean(logical([0,0,personWhoFeelsFollowerOrLeader==1])),deviationPosfromA(logical([0,0,personWhoFeelsFollowerOrLeader==1])),MarkerDimension/3,clearYellow,'filled')
    
    xline(posAPeaksmean(1:BASELINE_NUMBER),'k--','LineWidth', DottedLineWidth)
    
    % Replot something in order to have the correct legend and the dotted line behind all
    scatter(posAPeaksmean(1),deviationPosfromA(1),MarkerDimension,clearRed,'filled')
    scatter(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])),deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])),MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(posAPeaksmean(BASELINE_NUMBER),deviationPosfromA(BASELINE_NUMBER),MarkerDimension,clearBlue,'filled')
    scatter(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])),deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    
    posAStandardError = posAPeaksStd./sqrt(length(posAPeaksStd));
    errorbar(posAPeaksmean, deviationPosfromA, posAStandardError, 'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    
    title("Position A peaks values")
    xlabel("Mean [ cm ]")
    ylabel("Deviation from baseline [ cm ]")
    legend('Baseline iCub-SX','Collected data iCub-SX','Baseline iCub-DX','Collected data iCub-DX', 'Felt Follower', 'Felt Leader','Location','southoutside')
    hold off

    %% POS B PLOT
    subplot(1,2,2), grid on, hold on

    % Generate y data
    deviationPosfromB = zeros(1,length(posBPeaksmean));
    deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])) = abs(posBPeaksmean(1)-posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])));
    deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])) = abs(posBPeaksmean(BASELINE_NUMBER)-posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])));
    
    scatter(posBPeaksmean(1),deviationPosfromB(1),MarkerDimension,clearBlue,'filled')
    scatter(posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])),deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])),MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(posBPeaksmean(BASELINE_NUMBER),deviationPosfromB(BASELINE_NUMBER),MarkerDimension,clearRed,'filled')
    scatter(posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])),deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    
    scatter(posBPeaksmean(logical([0,0,personWhoFeelsFollowerOrLeader==-1])),deviationPosfromB(logical([0,0,personWhoFeelsFollowerOrLeader==-1])),MarkerDimension/3,clearGreen,'filled')
    scatter(posBPeaksmean(logical([0,0,personWhoFeelsFollowerOrLeader==1])),deviationPosfromB(logical([0,0,personWhoFeelsFollowerOrLeader==1])),MarkerDimension/3,clearYellow,'filled')
    
    xline(posBPeaksmean(1:BASELINE_NUMBER),'k--','LineWidth', DottedLineWidth)
    
    % Replot something in order to have the correct legend and the dotted line behind all
    scatter(posBPeaksmean(1),deviationPosfromB(1),MarkerDimension,clearBlue,'filled')
    scatter(posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])),deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])),MarkerDimension,'red','LineWidth',EmptyPointLine)
    scatter(posBPeaksmean(BASELINE_NUMBER),deviationPosfromB(BASELINE_NUMBER),MarkerDimension,clearRed,'filled')
    scatter(posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])),deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])),MarkerDimension,'blue','LineWidth',EmptyPointLine)
    
    posBStandardError = posBPeaksStd./sqrt(length(posBPeaksStd));
    errorbar(posBPeaksmean, deviationPosfromB, posBStandardError, 'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)

    title("Position B peaks values")
    xlabel("Mean [ cm ]")
    ylabel("Deviation from baseline [ cm ]")
    legend('Baseline iCub-SX','Collected data iCub-SX','Baseline iCub-DX','Collected data iCub-DX', 'Felt Follower', 'Felt Leader','Location','southoutside')
    hold off

    sgtitle("Evaluation of position deviation for boundaries position")

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5a,"..\ProcessedData\Scatters\PeaksPosBoundariesDeviation.png")
        close(fig5a);
    end

    %% DISTANCE AVERAGE BETWEEN POS A AND POS B PLOT
    fig5b = figure('Name','Values of average peaks, mean and variance');
    fig5b.WindowState = 'maximized';
    grid on, hold on
    
    % Generate y data
    deviationPosfromAverage = zeros(1,length(meanPos));
    deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])) = abs(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0]))-meanPos(1));
    deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])) = abs(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0]))-meanPos(BASELINE_NUMBER));
    
    scatter(meanPos(1).*100,deviationPosfromAverage(1).*100,MarkerDimension,clearRed,'filled')
    scatter(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])).*100,deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])).*100,MarkerDimension,'black','LineWidth',EmptyPointLine)
    
    scatter(meanPos(logical([0,0,personWhoFeelsFollowerOrLeader==-1])).*100,deviationPosfromAverage(logical([0,0,personWhoFeelsFollowerOrLeader==-1])).*100,MarkerDimension/3,clearGreen,'filled')
    scatter(meanPos(logical([0,0,personWhoFeelsFollowerOrLeader==1])).*100,deviationPosfromAverage(logical([0,0,personWhoFeelsFollowerOrLeader==1])).*100,MarkerDimension/3,clearYellow,'filled')

    scatter(meanPos(BASELINE_NUMBER).*100,deviationPosfromAverage(BASELINE_NUMBER).*100,MarkerDimension,clearRed,'filled')
    scatter(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])).*100,deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])).*100,MarkerDimension,'black','LineWidth',EmptyPointLine)
    
    xline(meanPos(1:BASELINE_NUMBER).*100,'k--','LineWidth', DottedLineWidth)
    text((minPeaksAverage(1)+maxPeaksAverage(1))./2.*100+1,1,"iCub SX",'FontSize',12,'HorizontalAlignment','left')
    text((maxPeaksAverage(BASELINE_NUMBER)+minPeaksAverage(BASELINE_NUMBER))./2.*100-1,1,"iCub DX",'FontSize',12,'HorizontalAlignment','right')
    
    % Replot something in order to have the correct legend and the dotted line behind all
    scatter(meanPos(1).*100,deviationPosfromAverage(1).*100,MarkerDimension,clearRed,'filled')
    scatter(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])).*100,deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])).*100,MarkerDimension,'black','LineWidth',EmptyPointLine)
    scatter(meanPos(BASELINE_NUMBER).*100,deviationPosfromAverage(BASELINE_NUMBER).*100,MarkerDimension,clearRed,'filled')
    scatter(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])).*100,deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])).*100,MarkerDimension,'black','LineWidth',EmptyPointLine)
    
    posStandardError = stdPos.*100./sqrt(length(stdPos));
    errorbar(meanPos.*100, deviationPosfromAverage.*100, posStandardError, 'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)

    xlabel("Mean [ cm ]")
    ylabel("Deviation from baseline [ cm ]")
    legend('Baseline iCub','Collected data', 'Felt Follower', 'Felt Leader','Location','eastoutside')
    hold off

    sgtitle("Evaluation of position deviation for average position")

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5b,"..\ProcessedData\Scatters\PeaksPosAverageDeviation.png")
        close(fig5b);
    end

    %% Saving matrices usefull for statistical analysis
    posADX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    posASX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    posBSX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    posBDX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    devPosADX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    devPosASX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    devPosBSX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);
    devPosBDX = zeros(length(posAPeaksStd)-BASELINE_NUMBER,1);

    for i = BASELINE_NUMBER+1:length(posAPeaksStd)
        if posAPeaksmean(i) > 0
            posADX(i-BASELINE_NUMBER) = posAPeaksmean(i);
            posASX(i-BASELINE_NUMBER) = 1000;
            posBSX(i-BASELINE_NUMBER) = posBPeaksmean(i);
            posBDX(i-BASELINE_NUMBER) = 1000;
            devPosADX(i-BASELINE_NUMBER) = deviationPosfromA(i);
            devPosASX(i-BASELINE_NUMBER) = 1000;
            devPosBSX(i-BASELINE_NUMBER) = deviationPosfromB(i);
            devPosBDX(i-BASELINE_NUMBER) = 1000;
        else
            posADX(i-BASELINE_NUMBER) = 1000;
            posASX(i-BASELINE_NUMBER) = posAPeaksmean(i);
            posBSX(i-BASELINE_NUMBER) = 1000;
            posBDX(i-BASELINE_NUMBER) = posBPeaksmean(i);
            devPosADX(i-BASELINE_NUMBER) = 1000;
            devPosASX(i-BASELINE_NUMBER) = deviationPosfromA(i);
            devPosBSX(i-BASELINE_NUMBER) = 1000;
            devPosBDX(i-BASELINE_NUMBER) = deviationPosfromB(i);
        end
    end

    matx = table(testedPeople',posBSX,posASX,posADX,posBDX,devPosBSX,devPosASX,devPosADX,devPosBDX,posBPeaksStd(BASELINE_NUMBER+1:end)',posAPeaksStd(BASELINE_NUMBER+1:end)');

    matx = renamevars(matx, 1:width(matx), ["Test number","posB SX","posA SX","posA DX","posB DX", ...
                                            "Deviation from B SX","Deviation from A SX","Deviation from A DX","Deviation from B DX", ...
                                            "std(posB)","std(posA)"]);

    writetable(matx, "..\ProcessedData\PeaksPositionData.xlsx");

    %% Standard deviation
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
        exportgraphics(fig6,"..\ProcessedData\Scatters\StandardDeviation.png")
        close(fig6);
    end

    %% Mean values
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
        exportgraphics(fig7,"..\ProcessedData\Scatters\MeanValues.png")
        close(fig7);
    end

    %% Movement range
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
        exportgraphics(fig8,"..\ProcessedData\Scatters\MovementRange.png")
        close(fig8);
    end

    %% Max e Min average distance
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
        exportgraphics(fig9,"..\ProcessedData\Scatters\MaxMinAverageDistance.png")
        close(fig9);
    end

    %% Peaks variation 
    fig10 = figure('Name','Peaks variation plot');
    fig10.WindowState = 'maximized';
    grid on, hold on
    plot(1:size(maxPeaksVariation,2),maxPeaksVariation(1:BASELINE_NUMBER,:).*100,'k--','LineWidth',2.2)
    hmax = plot(1:size(maxPeaksVariation,2),maxPeaksVariation(BASELINE_NUMBER+1:end,:).*100,'-','LineWidth',1.5);
    plot(1:size(minPeaksVariation,2),minPeaksVariation(1:BASELINE_NUMBER,:).*100,'k--','LineWidth',2.2)
    hmin = plot(1:size(minPeaksVariation,2),minPeaksVariation(BASELINE_NUMBER+1:end,:).*100.,'-','LineWidth',1.5);
    plot(1:size(maxPeaksVariation,2),maxPeaksVariation(1:BASELINE_NUMBER,:).*100,'k--','LineWidth',2.2)
    plot(1:size(minPeaksVariation,2),minPeaksVariation(1:BASELINE_NUMBER,:).*100,'k--','LineWidth',2.2)
    
    legendName(1:BASELINE_NUMBER) = "Baseline variation";
    for i = 1:size(maxPeaksVariation,1)-BASELINE_NUMBER
        set(hmax(i),'Color',customColors(i,:));
        set(hmin(i),'Color',customColors(i,:));
        legendName(i+BASELINE_NUMBER) = strjoin(["Test N. ",num2str(i)," variation"],"");
    end

    text(50,-15,"HUMAN DX HAND",'HorizontalAlignment','center','FontSize', textFont)
    text(50,15,"HUMAN SX HAND",'HorizontalAlignment','center','FontSize', textFont)
    title("Trend of position movement ranges")
    legend(legendName,'Location','eastoutside')
    xlabel("Simulation progress [ % ]")
    ylabel("Variation [ cm ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig10,"..\ProcessedData\Scatters\PeaksVariation.png")
        close(fig10);
    end
    
    %% Peaks initial and final variation
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
        exportgraphics(fig11,"..\ProcessedData\Scatters\PeaksInitialFinalVariation.png")
        close(fig11);
    end

    %% Synchronism efficiency based on positions
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
        exportgraphics(fig12,"..\ProcessedData\Scatters\SynchroEfficience.png")
        close(fig12);
    end

end