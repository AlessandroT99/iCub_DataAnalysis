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
% - Save differences from slope up and low
% - Give in output something usual for the peaks

function [meanTrend, upAmplitudeTrend, lowAmplitudeTrend, minPeaksVal, maxPeaksVal, lowSlope, upSlope] ...
    = forceFurtherAnalysis(synchForceDataSet,numPerson,personParam,BaselineFilesParameters)
    %% SIMULATION PARAMETERS
    frequency = 100;
    IMAGE_SAVING = 1;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");
    PAUSE_TIME = 2;

    cuttedElapsedTime = synchForceDataSet(:,1);

    save ("..\ProcessedData\ForceFurtherAnalysis");
%     load ..\ProcessedData\ForceFurtherAnalysis;
    %% AVERAGE TREND ANALYSIS
    maximumMovementTime = 0.4;
    [envHigh, envLow] = envelope(synchForceDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;

    percentageMean = 5;
    meanTrend = behavior(synchForceDataSet(:,2),percentageMean);
    
    %% PEAKS ANALYSIS
    maxPeaksVal = [];
    maxLocalization = [];
    minPeaksVal = [];
    minLocalization = [];
    idxMean = round(length(meanTrend)/percentageMean);
    idxSignal = round(length(averageEnv)/percentageMean);
    lastSignalIdx = 0;
    cnt = 0;
    while lastSignalIdx < length(averageEnv)
        cnt = cnt +  1;
        lastSignalIdx = idxSignal*cnt;
        if lastSignalIdx > length(averageEnv)
            lastSignalIdx = length(averageEnv);
        end
        lastMeanIdx = idxMean*cnt;
        if lastMeanIdx > length(percentageMean)
            lastMeanIdx = length(percentageMean);
        end
        [maxPeaks, maxLoc] = findpeaks(averageEnv((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",meanTrend(lastMeanIdx));
        idxToRemove = find(maxPeaks<meanTrend(lastMeanIdx));
        maxLoc(idxToRemove) = [];
        maxPeaks(idxToRemove) = [];
        maxPeaksVal = [maxPeaksVal;maxPeaks];
        maxLocalization = [maxLocalization; maxLoc+(cnt-1)*idxSignal+1];
        [minPeaks, minLoc] = findpeaks(-averageEnv((cnt-1)*idxSignal+1:lastSignalIdx),"MinPeakHeight",-meanTrend(lastMeanIdx));
        minPeaks = -minPeaks;
        idxToRemove = find(minPeaks>meanTrend(lastMeanIdx));
        minLoc(idxToRemove) = [];
        minPeaks(idxToRemove) = [];
        minPeaksVal = [minPeaksVal; minPeaks];
        minLocalization = [minLocalization; minLoc+(cnt-1)*idxSignal+1];
    end

    [minPeaksVal, minLocalization, maxPeaksVal, maxLocalization] = maxMinCleaning(minPeaksVal, minLocalization, maxPeaksVal, maxLocalization);

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
        mkdir ..\ProcessedData\ForceFurtherAnalysis;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ForceFurtherAnalysis\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\ProcessedData\ForceFurtherAnalysis\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig1a,path)
        close(fig1a);
    end

end

%% Function
function [signalBehavior] = behavior(signal, percentageMean)
   ORDER = 1;
   signalBehavior = zeros(1,round(100/percentageMean));
   for i = 0:round(100/percentageMean)-1
        signalBehavior(i+1) = mean(signal(round(i*length(signal)/100*percentageMean)+1:round((i+1)*length(signal)/100*percentageMean))); 
   end
end