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
    %% AVERAGE TREND ANALYSIS
    maximumMovementTime = 0.4;
    [envHigh, envLow] = envelope(synchForceDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;

    %% PEAKS ANALYSIS
    percentageMean = 5;
    processComplete = 0;
    while processComplete == 0
        try
            meanTrend = behavior(synchForceDataSet(:,2),percentageMean);
            [minPeaksVal,maxPeaksVal,minLocalization,maxLocalization] = peaksFinder(meanTrend,percentageMean,averageEnv);
            processComplete = 1;
        catch err
            fprintf("\n\nSolving the issue: \n%s",getReport(err))
            percentageMean = percentageMean + 5;
            processComplete = 0;
        end
    end

    [minPeaksVal, minLocalization, maxPeaksVal, maxLocalization] = maxMinCleaning(minPeaksVal, minLocalization, maxPeaksVal, maxLocalization);

    peaksAmplitude = zeros(1,min(length(minLocalization),length(maxLocalization)));
    for j = 1:min(length(minLocalization),length(maxLocalization))
        if minLocalization(1) < maxLocalization(1)
            if j+1 < length(maxLocalization) && j < length(minLocalization)
                peaksAmplitude(j) = abs(abs(minLocalization(j))-abs(maxLocalization(j+1)));
            end
        else
            if j < length(maxLocalization) && j+1 < length(minLocalization)
                peaksAmplitude(j) = abs(abs(maxLocalization(j))-abs(minLocalization(j+1)));
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
    legend("Signal zero mean","Upper envelope trend","Lower envelope trend")
    title("Reconstructed force signal")
    xlabel("Time [ min ]"), ylabel("Force [ N ]")

    subplot(2,1,2), grid on, hold on
    plot(cuttedElapsedTime, averageEnv, 'b-')
    plot(linspace(cuttedElapsedTime(1),cuttedElapsedTime(end),length(meanTrend)), meanTrend,'k--')
    plot(cuttedElapsedTime(maxLocalization),maxPeaksVal,'ro')
    plot(cuttedElapsedTime(minLocalization),minPeaksVal,'go')
    legend("Signal behavior","Signal Mean Trend", ...
        strjoin([num2str(length(maxLocalization))," maximum peaks"],""), ...
        strjoin([num2str(length(minLocalization))," minimum peaks"],""))
    title("Force signal analysis")
    xlabel("Time [ min ]"), ylabel("Force [ N ]")

    sgtitle(defaultTitleName)

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\ForceFurtherAnalysis;
        if numPerson < 0
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

function [minPeaksVal,maxPeaksVal,minLocalization,maxLocalization] = peaksFinder(meanTrend,percentageMean,averageEnv)
    percentageMean = 100/percentageMean;
    maxPeaksVal = [];
    maxLocalization = [];
    minPeaksVal = [];
    minLocalization = [];
    idxMean = round(length(meanTrend)/percentageMean);
    idxSignal = round(length(averageEnv)/percentageMean);
    lastSignalIdx = 0;
    cnt = 0;
    while lastSignalIdx < length(averageEnv)
        cnt = cnt + 1;
        lastSignalIdx = idxSignal*cnt;
        if lastSignalIdx > length(averageEnv)
            lastSignalIdx = length(averageEnv);
        end
        lastMeanIdx = idxMean*cnt;
        if lastMeanIdx > length(meanTrend)
            lastMeanIdx = length(meanTrend);
        end
        maxPeak = [];
        maxLoc = [];
        [maxPeaks, maxLoc] = findpeaks(averageEnv((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",meanTrend(lastMeanIdx));
        idxToRemove = find(maxPeaks<=meanTrend(lastMeanIdx));
        maxLoc(idxToRemove) = [];
        maxPeaks(idxToRemove) = [];
        maxPeaksVal = [maxPeaksVal;maxPeaks];
        maxLocalization = [maxLocalization; maxLoc+(cnt-1)*idxSignal+1];
        minPeaks = [];
        minLoc = [];
        [minPeaks, minLoc] = findpeaks(-averageEnv((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",-meanTrend(lastMeanIdx));
        idxToRemove = find(minPeaks<=-meanTrend(lastMeanIdx));
        minLoc(idxToRemove) = [];
        minPeaks(idxToRemove) = [];
        minPeaks = -minPeaks;
        minPeaksVal = [minPeaksVal; minPeaks];
        minLocalization = [minLocalization; minLoc+(cnt-1)*idxSignal+1];
    end
end