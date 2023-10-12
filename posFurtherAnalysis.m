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

function [experimentDuration, meanHtoR, meanRtoH, nMaxPeaks, nMinPeaks, ...
            maxPeaksAverage, minPeaksAverage, stdPos, meanPos] = ...
              posFurtherAnalysis(synchPosDataSet,numPerson,personParam)
% The main aim of this function is to elaborate position signals in order to extract
% some interesting data that would be usefull to compare with the overrall
% test population into some scatter plot or others

    %% Parameters for the simulation     
    frequency = 100;
    IMAGE_SAVING = 0;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");

    %% Phase duration evaluation
    maximumMovementTime = 0.5;
    [envHigh, envLow] = envelope(synchPosDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    maxLocalization = maxLocalization*10e-5;
    minLocalization = minLocalization*10e-5;

    for i = 1:length(maxPeaksVal)
        if strcmp(personParam(5),"DX") == 1
            if i+1 <= length(minLocalization) && i <= length(maxLocalization)
                HtoR(i) = minLocalization(i+1)-maxLocalization(i);
            end
            if i <= length(minLocalization) && i <= length(maxLocalization)
                RtoH(i) = maxLocalization(i)-minLocalization(i);
            end
        else
            if i <= length(minLocalization) && i <= length(maxLocalization)
                RtoH(i) = minLocalization(i)-maxLocalization(i);
            end
            if i <= length(minLocalization) && i+1 <= length(maxLocalization)
                HtoR(i) = maxLocalization(i+1)-minLocalization(i);
            end
        end
    end

    meanHtoR = mean(HtoR);
    meanRtoH = mean(RtoH);

    fig1 = figure;
    fig1.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR.*60,'r-','DisplayName','Human to Robot phase')
    plot(RtoH.*60,'b-','DisplayName','Robot to Human phase')
    yline(meanHtoR.*60,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(meanRtoH.*60,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Time length of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Time [ s ]")
    legend('show')
    hold off

    % Figure saving for phase duration
    if IMAGE_SAVING
        mkdir ..\ProcessedData\PhaseDuration;
        path = strjoin(["..\ProcessedData\PhaseDuration\P",num2str(numPerson),".png"],"");
        exportgraphics(fig1,path)
        close(fig1);
    end

    %% Peaks values
    nMaxPeaks = length(maxPeaksVal);
    nMinPeaks = length(minPeaksVal);

    maxPeaksAverage = mean(maxPeaksVal);
    minPeaksAverage = mean(minPeaksVal);

    %% Std and mean
    stdPos = std(synchPosDataSet(:,2));
    meanPos = mean(synchPosDataSet(:,2));

    %% Duration
    experimentDuration = synchPosDataSet(end,1);

    
end