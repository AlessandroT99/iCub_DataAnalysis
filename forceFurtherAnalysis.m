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

% This software aims to find data from the force signal in order to
% determine a parameter to increase efficience of the interaction

%% TODO: 
% - Give in output something usual for the peaks

function [meanTrend, lowSlope, upSlope, peaksAmplitude] ...
    = forceFurtherAnalysis(synchForceDataSet,numPerson,personParam,BaselineFilesParameters)
    %% SIMULATION PARAMETERS
    frequency = 100;
    IMAGE_SAVING = 1;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");
    PAUSE_TIME = 2;

    cuttedElapsedTime = synchForceDataSet(:,1);

    save ("..\iCub_ProcessedData\ForceFurtherAnalysis");
%     load ..\iCub_ProcessedData\ForceFurtherAnalysis;

    %% PEAKS ANALYSIS
    percentageMean = 5;
    processComplete = 0;
    while processComplete == 0
        try
            meanTrend = behavior(synchForceDataSet(:,2),percentageMean);
            [minPeaksVal,maxPeaksVal,minLocalization,maxLocalization] = peaksFinder(meanTrend,percentageMean,synchForceDataSet(:,2),numPerson);
            processComplete = 1;
        catch err
            fprintf("\n\nSolving the issue: \n%s\n",getReport(err))
            percentageMean = percentageMean + 5;
            if percentageMean > 100
                error("Neither the mean on the whole signal found a correct solution");
            else
                fprintf("\nAdded 5 percent in the range of mean evaluation, now it is solved for each %d percent of the signal.\n",percentageMean)
                processComplete = 0;
            end
        end
    end

    peaksAmplitude = zeros(1,min(length(minLocalization),length(maxLocalization)));
    for j = 1:min(length(minLocalization),length(maxLocalization))
        if minLocalization(1) < maxLocalization(1)
            if j+1 < length(maxPeaksVal) && j < length(minPeaksVal)
                peaksAmplitude(j) = abs(abs(minPeaksVal(j))-abs(maxPeaksVal(j+1)));
            end
        else
            if j < length(maxPeaksVal) && j+1 < length(minPeaksVal)
                peaksAmplitude(j) = abs(abs(maxPeaksVal(j))-abs(minPeaksVal(j+1)));
            end
        end
    end

    %% AMPLITUDE TREND ANALYSIS
    p = polyfit(cuttedElapsedTime(maxLocalization),maxPeaksVal,1);
    upAmplitudeTrend = polyval(p,cuttedElapsedTime);
    upSlope = p(1);
    p = polyfit(cuttedElapsedTime(minLocalization),minPeaksVal,1);
    lowAmplitudeTrend = polyval(p,cuttedElapsedTime);
    lowSlope = p(1);

    % Plot results
    fig1 = figure('Name','Force signal analysis');
    fig1.WindowState = 'maximized';
    subplot(2,1,1), grid on, hold on
    plot(cuttedElapsedTime, synchForceDataSet(:,2), 'k-')
    plot(cuttedElapsedTime, upAmplitudeTrend, 'r-')
    plot(cuttedElapsedTime, lowAmplitudeTrend, 'g-')
    legend("Force signal","Upper envelope trend","Lower envelope trend")
    title("Reconstructed force signal")
    xlabel("Time [ min ]"), ylabel("Force [ N ]")

    subplot(2,1,2), grid on, hold on
    plot(cuttedElapsedTime(1:height(synchForceDataSet)), synchForceDataSet(:,2), 'k:','LineWidth',0.6)
    plot(linspace(cuttedElapsedTime(1),cuttedElapsedTime(end),length(meanTrend)), meanTrend,'b--','LineWidth',1.75)
    plot(cuttedElapsedTime(maxLocalization),maxPeaksVal,'ro','MarkerSize',3,'LineWidth', 1.5)
    plot(cuttedElapsedTime(minLocalization),minPeaksVal,'go','MarkerSize',3, 'LineWidth', 1.5)
    plot(linspace(cuttedElapsedTime(1),cuttedElapsedTime(end),length(meanTrend)), meanTrend,'b--','LineWidth',1.5)
    legend("Force signal","Signal Mean Trend", ...
        strjoin([num2str(length(maxLocalization))," maximum peaks"],""), ...
        strjoin([num2str(length(minLocalization))," minimum peaks"],""))
    title("Force signal analysis")
    xlabel("Time [ min ]"), ylabel("Force [ N ]")
    hold off

    sgtitle(defaultTitleName)

    if numPerson == 26
        pause(1);
    end

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\ForceFurtherAnalysis;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\ForceFurtherAnalysis",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\ForceFurtherAnalysis\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\ForceFurtherAnalysis\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig1,path)
        close(fig1);
    end

    meanTrend = mean(meanTrend);
end

%% Functions
function [signalBehavior] = behavior(signal, percentageMean)
   ORDER = 1;
   signalBehavior = zeros(1,round(100/percentageMean));
   for i = 0:round(100/percentageMean)-1
        signalBehavior(i+1) = mean(signal(round(i*length(signal)/100*percentageMean)+1:round((i+1)*length(signal)/100*percentageMean))); 
   end
end

function [minPeaksVal,maxPeaksVal,minLocalization,maxLocalization] = peaksFinder(meanTrend,percentageMean,signal,numPerson)
    percentageMean = 100/percentageMean;
    maxPeaksVal = [];
    maxLocalization = [];
    minPeaksVal = [];
    minLocalization = [];
    idxMean = round(length(meanTrend)/percentageMean);
    idxSignal = round(length(signal)/percentageMean);
    lastSignalIdx = 0;
    cnt = 0;
    while lastSignalIdx < length(signal)
        cnt = cnt + 1;
        lastSignalIdx = idxSignal*cnt;
        if lastSignalIdx > length(signal)
            lastSignalIdx = length(signal);
        end
        lastMeanIdx = idxMean*cnt;
        if lastMeanIdx > length(meanTrend)
            lastMeanIdx = length(meanTrend);
        end
        maxPeak = [];
        maxLoc = [];
        if numPerson < 0
            [maxPeaks, maxLoc] = findpeaks(signal((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",meanTrend(lastMeanIdx), 'MinPeakDistance', 5, 'MinPeakProminence', 0.35);
        else
            [maxPeaks, maxLoc] = findpeaks(signal((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",meanTrend(lastMeanIdx), 'MinPeakDistance', 5, 'MinPeakProminence', 3.5);
        end
        idxToRemove = find(maxPeaks<=meanTrend(lastMeanIdx));
        maxLoc(idxToRemove) = [];
        maxPeaks(idxToRemove) = [];
        maxPeaksVal = [maxPeaksVal;maxPeaks];
        maxLocalization = [maxLocalization; maxLoc+(cnt-1)*idxSignal+1];
        minPeaks = [];
        minLoc = [];
        if numPerson < 0
            [minPeaks, minLoc] = findpeaks(-signal((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",-meanTrend(lastMeanIdx),'MinPeakDistance', 5, 'MinPeakProminence', 0.35);
        else
            [minPeaks, minLoc] = findpeaks(-signal((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",-meanTrend(lastMeanIdx),'MinPeakDistance', 5, 'MinPeakProminence', 3.5);
        end
        idxToRemove = find(minPeaks<=-meanTrend(lastMeanIdx));
        minLoc(idxToRemove) = [];
        minPeaks(idxToRemove) = [];
        minPeaks = -minPeaks;
        minPeaksVal = [minPeaksVal; minPeaks];
        minLocalization = [minLocalization; minLoc+(cnt-1)*idxSignal+1];
    end

     % If occurs that two or more maximums/minimums are not separated from
    % the opposite, it will be taken the average of them, both temporarly
    % and position value
    % firstly find the higher density of peaks
    if length(minLocalization) < length(maxLocalization)
        HtmpLocalization = [maxLocalization,maxPeaksVal];
        LtmpLocalization = [minLocalization,minPeaksVal];
    else
        HtmpLocalization = [minLocalization,minPeaksVal];
        LtmpLocalization = [maxLocalization,maxPeaksVal];
    end

    % then with the found maximum analyze all the peaks looking for
    % sovrappositions
    cnt = 1;
    checkCnt = 0;
    newHLocalization = [];
    for i = 1:(size(HtmpLocalization,1)-1)
        if HtmpLocalization(i+1,1) < LtmpLocalization(cnt,1)
            checkCnt = checkCnt + 1;
        else
            if checkCnt > 0
                newHLocalization = [newHLocalization;round(mean(HtmpLocalization(i-checkCnt:i,1))),mean(HtmpLocalization(i-checkCnt:i,2))];
                checkCnt = 0;
            else
                newHLocalization = [newHLocalization;HtmpLocalization(i,1),HtmpLocalization(i,2)];
            end
            cnt = cnt + 1;
        end
    end

    if ~isempty(newHLocalization)
        if LtmpLocalization(1,1) == minLocalization(1)
            maxLocalization = []; % be sure to clear all the old values in the vector
            maxPeaksVal = []; % be sure to clear all the old values in the vector
            maxLocalization = newHLocalization(:,1);
            maxPeaksVal = newHLocalization(:,2);
        else
            minLocalization = []; % be sure to clear all the old values in the vector
            minPeaksVal = []; % be sure to clear all the old values in the vector
            minLocalization = newHLocalization(:,1);
            minPeaksVal = newHLocalization(:,2);
        end
    end
end