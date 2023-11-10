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

function plotFurtherAnalysis(experimentDuration, meanHtoR_time, meanRtoH_time, meanHtoR_space, meanRtoH_space, phaseTimeDifference, ...
                                nMaxPeaks, nMinPeaks, maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
                                peaksInitialAndFinalVariation, synchroEfficiency, BASELINE_NUMBER, ...
                                posAPeaksStd, posBPeaksStd, posAPeaksmean, posBPeaksmean, personWhoFeelsFollowerOrLeader, testedPeople, ROM, nearEnd)
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
% nearEnd = near end effect read directly from the excel input file
    
    %% Simulation parameters
    IMAGE_SAVING = 1;
    PAUSE_TIME = 2;
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
    
    %% Phase time durations
    fig2 = figure('Name','Phases duration scatter');
    fig2.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH_time(1:BASELINE_NUMBER).*60./10000,1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(meanHtoR_time(1:BASELINE_NUMBER).*60./10000,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(meanRtoH_time(BASELINE_NUMBER+1:end).*60./10000,BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    scatter(meanHtoR_time(BASELINE_NUMBER+1:end).*60./10000,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    title("Trend of phases time duration")
    xlabel("Elapsed Time [ s ]"), ylabel("# Test")
    desideredPhase = 1.5;
    xline(desideredPhase,'k--','LineWidth',DottedLineWidth)
    legend("BaseLine RtoH","BaseLine HtoR",'Robot to Human','Human to Robot','Desidered duration')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2,"..\ProcessedData\Scatters\PhaseTimeDuration.png")
        close(fig2);
    end

    %% Phase space durations
    fig2b = figure('Name','Phases space duration scatter');
    fig2b.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH_space(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearBlue,'filled')
    scatter(meanHtoR_space(1:BASELINE_NUMBER).*100,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(meanRtoH_space(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'blue','LineWidth',EmptyPointLine)
    scatter(meanHtoR_space(BASELINE_NUMBER+1:end).*100,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    title("Trend of phases space duration")
    xlabel("Space [ cm ]"), ylabel("# Test")
    legend("BaseLine RtoH","BaseLine HtoR",'Robot to Human','Human to Robot')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2b,"..\ProcessedData\Scatters\PhaseSpaceDuration.png")
        close(fig2b);
    end

    %% Phase time difference
    fig2c = figure('Name','Phases time difference scatter');
    fig2c.WindowState = 'maximized';
    grid on, hold on
    scatter(phaseTimeDifference(1:BASELINE_NUMBER).*60./10000,1:BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(phaseTimeDifference(BASELINE_NUMBER+1:end).*60./10000,BASELINE_NUMBER+1:nTest,MarkerDimension,'red','LineWidth',EmptyPointLine)
    title("Trend of human phases and robot phases time differences")
    xlabel("Time [ s ]"), ylabel("# Test")
    legend("BaseLine",'Differences')
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2c,"..\ProcessedData\Scatters\PhaseTimeDifference.png")
        close(fig2c);
    end
    
    %% ROM
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
        exportgraphics(fig5,"..\ProcessedData\Scatters\ROM_NoPhoto.png")
        close(fig5);
    end

     %% Another alternative - ROM INTO TEST NUMBER
    fig5e = figure('Name','Range of Motion [ROM]');
    fig5e.WindowState = 'maximized';
    hold on
    
    % iCub DX hand - max
    scatter(maxPeaksAverage(BASELINE_NUMBER).*100,BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(maxPeaksAverage(logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)>0])).*100, ...
            find((1:nTest).*logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)>0])),MarkerDimension,'red','LineWidth',EmptyPointLine)

    % iCub DX hand - max reference line
    xline(maxPeaksAverage(BASELINE_NUMBER)*100,'r--','LineWidth',0.5)

    % iCub SX hand - max
    scatter(abs(maxPeaksAverage(1).*100),1,MarkerDimension,clearBlue,'filled')
    scatter(abs(maxPeaksAverage(logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)<0])).*100), ...
            find((1:nTest).*logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)<0])),MarkerDimension,'blue','LineWidth',EmptyPointLine)

    % iCub SX hand - max reference line
    xline(abs(maxPeaksAverage(1)*100),'b--','LineWidth',0.5)

    % Plot union lines between points to describe ROM
    plot(abs([maxPeaksAverage(1).*100;minPeaksAverage(1).*100]),[(1);(1)],':','LineWidth',1,'Color',clearBlue)
    plot(abs([maxPeaksAverage(BASELINE_NUMBER).*100;minPeaksAverage(BASELINE_NUMBER).*100]), ...
         [(BASELINE_NUMBER);(BASELINE_NUMBER)],':','LineWidth',1,'Color',clearRed)
    plot(abs([maxPeaksAverage(BASELINE_NUMBER+1:end).*100;minPeaksAverage(BASELINE_NUMBER+1:end).*100]), ...
         [(BASELINE_NUMBER+1:nTest);(BASELINE_NUMBER+1:nTest)],':','LineWidth',1,'Color',clearGreen)

    % max reference line
    %xline(mean(abs([minPeaksAverage(1),maxPeaksAverage(BASELINE_NUMBER)].*100)),'k--','LineWidth',DottedLineWidth)
    % min reference line
    %xline(mean(abs([maxPeaksAverage(1),minPeaksAverage(BASELINE_NUMBER)].*100)),'k--','LineWidth',DottedLineWidth)

    % iCub DX hand - min
    scatter(minPeaksAverage(BASELINE_NUMBER).*100,BASELINE_NUMBER,MarkerDimension,clearRed,'filled')
    scatter(minPeaksAverage(logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)>0])).*100, ...
            find((1:nTest).*logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)>0])), MarkerDimension,'red','LineWidth',EmptyPointLine)
    xline(minPeaksAverage(BASELINE_NUMBER)*100,'r--','LineWidth',0.5)

    % iCub SX hand - min
    scatter(abs(minPeaksAverage(1).*100),1,MarkerDimension,clearBlue,'filled')
    scatter(abs(minPeaksAverage(logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)<0])).*100), ...
            find((1:nTest).*logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)<0])), MarkerDimension,'blue','LineWidth',EmptyPointLine)
    xline(abs(minPeaksAverage(1)*100),'b--','LineWidth',0.5)

    text(abs(minPeaksAverage(1))*100-0.5,1,"Max",'FontSize',8,'HorizontalAlignment','right')
    text(minPeaksAverage(BASELINE_NUMBER)*100+0.5,1,"Min",'FontSize',8,'HorizontalAlignment','left')
    title("Range Of Motion [ROM] of iCub hand")
    legend('DX iCub Baseline','DX iCub interaction','DX Baseline Reference', 'SX iCub Baseline','SX iCub interaction', ...
           'SX Baseline Reference','Range Of Motion [ROM]','Location','northwest')
    xlabel("Peaks value [ cm ]"), ylabel("# Test")
    xShift = -15;
    xSize = 7;
    xlim([xShift-xSize,25]), ylim([0,35])

    iCubImg = imread("..\InputData\images\iCub_back.png");
    iCubImg = flipud(iCubImg);
    image(iCubImg,'xdata',[-xSize/2,xSize/2],'ydata',[0.5,xSize/0.65])

    personImg = imread("..\InputData\images\guy_back.png");
    personImg = flipud(personImg);
    image(personImg,'xdata',[xShift-xSize/2.5,xShift+xSize/2.5],'ydata',[0.8,xSize/0.65])
    
    text(0, xSize/0.65+2.5, "Robot Side", "FontSize", 14, "HorizontalAlignment", "center")
    text(xShift, xSize/0.65+2.5, "Human Side", "FontSize", 14, "HorizontalAlignment", "center")
    
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5e,"..\ProcessedData\Scatters\ROM_TestNumber.png")
        close(fig5e);
    end

    %% Another alternative - ROM INTO NEAR END EFFECT
    fig5d = figure('Name','Range of Motion [ROM]');
    fig5d.WindowState = 'maximized';
    hold on
    
    nearEnd = nearEnd'.*1000;
    baselineYPos = max(nearEnd)+5;
    baselineYPosAdded = -5;
    logicalIntervalPeaks = ~isnan(nearEnd);
    
    % Removing mean from values
    meanROM = (maxPeaksAverage+minPeaksAverage)./2;
    maxPeaksAverage = maxPeaksAverage - meanROM; 
    minPeaksAverage = minPeaksAverage - meanROM;

    % iCub DX hand - max
    scatter(maxPeaksAverage(BASELINE_NUMBER).*100,baselineYPos-baselineYPosAdded,MarkerDimension,clearRed,'filled')
    scatter(maxPeaksAverage(logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)>-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks])).*100, ...
            nearEnd(logical(maxPeaksAverage(BASELINE_NUMBER+1:end)>-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks)), ...
            MarkerDimension,'red','LineWidth',EmptyPointLine)

    % iCub DX hand - max reference line
%     xline(maxPeaksAverage(BASELINE_NUMBER)*100,'r--','LineWidth',0.5)

    % iCub SX hand - max
    scatter(maxPeaksAverage(1).*100,baselineYPos,MarkerDimension,clearBlue,'filled')
    scatter(maxPeaksAverage(logical([0,0,maxPeaksAverage(BASELINE_NUMBER+1:end)<-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks])).*100, ...
            nearEnd(logical(maxPeaksAverage(BASELINE_NUMBER+1:end)<-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks)), ...
            MarkerDimension,'blue','LineWidth',EmptyPointLine)

    % iCub SX hand - max reference line
%     xline(abs(maxPeaksAverage(1)*100),'b--','LineWidth',0.5)

    % Plot union lines between points to describe ROM
    plot([maxPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100;minPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100], ...
         [nearEnd(logicalIntervalPeaks);nearEnd(logicalIntervalPeaks)], ...
         ':','LineWidth',1,'Color',clearGreen)
    plot([maxPeaksAverage(1).*100;minPeaksAverage(1).*100],[baselineYPos;baselineYPos],':','LineWidth',1,'Color',clearBlue)
    plot([maxPeaksAverage(BASELINE_NUMBER).*100;minPeaksAverage(BASELINE_NUMBER).*100], ...
         [baselineYPos-baselineYPosAdded;baselineYPos-baselineYPosAdded], ...
         ':','LineWidth',1,'Color',clearRed)
    
    % max reference line
    %xline(mean(abs([minPeaksAverage(1),maxPeaksAverage(BASELINE_NUMBER)].*100)),'k--','LineWidth',DottedLineWidth)
    % min reference line
    %xline(mean(abs([maxPeaksAverage(1),minPeaksAverage(BASELINE_NUMBER)].*100)),'k--','LineWidth',DottedLineWidth)

    % iCub DX hand - min
    scatter(minPeaksAverage(BASELINE_NUMBER).*100,baselineYPos-baselineYPosAdded,MarkerDimension,clearRed,'filled')
    scatter(minPeaksAverage(logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)>-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks])).*100, ...
            nearEnd(logical(minPeaksAverage(BASELINE_NUMBER+1:end)>-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks)),MarkerDimension, ...
            'red','LineWidth',EmptyPointLine)
%     xline(minPeaksAverage(BASELINE_NUMBER)*100,'r--','LineWidth',0.5)

    % iCub SX hand - min
    scatter(minPeaksAverage(1).*100,baselineYPos,MarkerDimension,clearBlue,'filled')
    scatter(minPeaksAverage(logical([0,0,minPeaksAverage(BASELINE_NUMBER+1:end)<-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks])).*100, ...
            nearEnd(logical(minPeaksAverage(BASELINE_NUMBER+1:end)<-meanROM(BASELINE_NUMBER+1:end).*logicalIntervalPeaks)), ...
            MarkerDimension,'blue','LineWidth',EmptyPointLine)
%     xline(abs(minPeaksAverage(1)*100),'b--','LineWidth',0.5)

    % Error bars
    minPeaksStandardError = minPeaksAverage./sqrt(length(posAPeaksStd));
    errorbar(minPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearEnd(logicalIntervalPeaks), ...
             minPeaksStandardError(logical([0,0,logicalIntervalPeaks])), ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    errorbar(minPeaksAverage(1:BASELINE_NUMBER).*100, [baselineYPos,baselineYPos-baselineYPosAdded], ...
             minPeaksStandardError(1:BASELINE_NUMBER), ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    maxPeaksStandardError = maxPeaksAverage./sqrt(length(posBPeaksStd));
    errorbar(maxPeaksAverage(logical([0,0,logicalIntervalPeaks])).*100, nearEnd(logicalIntervalPeaks), ...
             maxPeaksStandardError(logical([0,0,logicalIntervalPeaks])), ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    errorbar(maxPeaksAverage(1:BASELINE_NUMBER).*100, [baselineYPos,baselineYPos-baselineYPosAdded], ...
             maxPeaksStandardError(1:BASELINE_NUMBER), ...
             'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)

%     text(abs(minPeaksAverage(1))*100-0.5,baselineYPos-0.25,"Max",'FontSize',8,'HorizontalAlignment','right')
%     text(minPeaksAverage(BASELINE_NUMBER)*100+0.5,baselineYPos-0.25,"Min",'FontSize',8,'HorizontalAlignment','left')
    title("Range Of Motion [ROM] of iCub hand")
    legend('DX iCub Baseline','DX iCub interaction', 'SX iCub Baseline','SX iCub interaction','Range Of Motion [ROM]','Location','eastoutside')
    xlabel("Peaks value [ cm ]"), ylabel("Near End Effect [ ms ]")
    xSize = 1;
    ySize = xSize/0.75*10;
    yDim = baselineYPos + ySize + 4;
    xlim([min(min(maxPeaksAverage),min(minPeaksAverage))-2,max(max(maxPeaksAverage),max(minPeaksAverage))+2])
    ylim([min(nearEnd)-1,yDim+5])
    set(gca, 'YDir','reverse')

    iCubImg = imread("..\InputData\images\iCub_hand.png");
    iCubImg = flipud(iCubImg);
    vSpace = 2.5;
    xDim = 0;
    image(iCubImg,'xdata',[xDim-xSize/2,xDim+xSize/2],'ydata',[yDim+vSpace,yDim-ySize+vSpace])
    
    hold off
    
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig5d,"..\ProcessedData\Scatters\ROM_NearEnd.png")
        close(fig5d);
    end

    %% POS A PLOT  
    % Generate y data
    deviationPosfromA = zeros(1,length(posAPeaksmean));
    deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0])) = abs(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)<0]))-posAPeaksmean(1));
    deviationPosfromA(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0])) = abs(posAPeaksmean(logical([0,0,posAPeaksmean(BASELINE_NUMBER+1:end)>0]))-posAPeaksmean(BASELINE_NUMBER));

    %% POS B PLOT
    % Generate y data
    deviationPosfromB = zeros(1,length(posBPeaksmean));
    deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])) = abs(posBPeaksmean(1)-posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)<0])));
    deviationPosfromB(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])) = abs(posBPeaksmean(BASELINE_NUMBER)-posBPeaksmean(logical([0,0,posBPeaksmean(BASELINE_NUMBER+1:end)>0])));

    %% DISTANCE AVERAGE BETWEEN POS A AND POS B PLOT
    % Generate y data
    deviationPosfromAverage = zeros(1,length(meanPos));
    deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0])) = abs(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)<0]))-meanPos(1));
    deviationPosfromAverage(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0])) = abs(meanPos(logical([0,0,meanPos(BASELINE_NUMBER+1:end)>0]))-meanPos(BASELINE_NUMBER));

    %% Saving matrices usefull for statistical analysis
    posAidx = [mean(posAPeaksmean(1:BASELINE_NUMBER)),posAPeaksmean(BASELINE_NUMBER+1:end)]';
    posBidx = [mean(posBPeaksmean(1:BASELINE_NUMBER)),posBPeaksmean(BASELINE_NUMBER+1:end)]';
    devPosAidx = [mean(deviationPosfromA(1:BASELINE_NUMBER)),deviationPosfromA(BASELINE_NUMBER+1:end)]';
    devPosBidx = [mean(deviationPosfromB(1:BASELINE_NUMBER)),deviationPosfromB(BASELINE_NUMBER+1:end)]';
    ROMdeviationCenterFromBaseline = (posAidx+posBidx)./2-(posAidx(1)+posBidx(1))/2;

    matx = table([-1;testedPeople'],posBidx,posAidx,devPosBidx,devPosAidx, [mean(ROM(1:BASELINE_NUMBER));ROM(BASELINE_NUMBER+1:end)'], ROMdeviationCenterFromBaseline, ...
                 [mean(phaseTimeDifference(1:BASELINE_NUMBER));phaseTimeDifference(BASELINE_NUMBER+1:end)'], ...
                 [mean(meanRtoH_time(1:BASELINE_NUMBER));meanRtoH_time(BASELINE_NUMBER+1:end)'],[mean(meanHtoR_time(1:BASELINE_NUMBER));meanHtoR_time(BASELINE_NUMBER+1:end)'], ...
                 [mean(meanRtoH_space(1:BASELINE_NUMBER));meanRtoH_space(BASELINE_NUMBER+1:end)'],[mean(meanHtoR_space(1:BASELINE_NUMBER));meanHtoR_space(BASELINE_NUMBER+1:end)'], ...
                 [mean(posBPeaksStd(1:BASELINE_NUMBER));posBPeaksStd(BASELINE_NUMBER+1:end)'], [mean(posAPeaksStd(1:BASELINE_NUMBER));posAPeaksStd(BASELINE_NUMBER+1:end)']);

    matx = renamevars(matx, 1:width(matx), ["ID","posB","posA", "Deviation from B","Deviation from A", ...
                                            "ROM", "Simmetry", "Phase Delay", ...
                                            "Human-Phase TimeDomain", "Robot-Phase TimeDomain", "Human-Phase SpaceDomain", "Robot-Phase SpaceDomain", ...
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

    title("Range Of Motion [ROM] in time domain")
    legend(legendName,'Location','eastoutside')
    ylabel("Simulation progress [ % ]"), xlabel("Variation [ cm ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig10,"..\ProcessedData\Scatters\ROM_TimeDomain.png")
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