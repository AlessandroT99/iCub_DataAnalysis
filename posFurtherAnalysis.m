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

function [experimentDuration, meanHtoR_time, meanRtoH_time, meanHtoR_space, meanRtoH_space, nMaxPeaks, nMinPeaks, ...
            maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
            movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
            peaksInitialAndFinalVariation, synchroEfficiency, posAPeaksStd, ...
            posBPeaksStd, posAPeaksmean, posBPeaksmean, ROM] = ...
              posFurtherAnalysis(synchPosDataSet,numPerson,personParam,baseline)
% The main aim of this function is to elaborate position signals in order to extract
% some interesting data that would be usefull to compare with the overrall
% test population into some scatter plot or others

%% OUTPUT PARAMETERS EXPLANATION
% experimentDuration = Duration of the experiments in minutes
% meanHtoR = Average time for the Human to Robot phase in minutes
% meanRtoH = Average time for the Robot to Human phase in minutes
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

    %% Parameters for the simulation     
    frequency = 100;
    fittingOrder = 4; % Order used into the polyfit functions
    IMAGE_SAVING = 1;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");
    PAUSE_TIME = 2;

    %% Phase duration evaluation
    maximumMovementTime = 0.5;
    [envHigh, envLow] = envelope(synchPosDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    
    % Cleaning the peaks from doubles
    [minPeaksVal,minLocalization,maxPeaksVal,maxLocalization] = maxMinCleaning(minPeaksVal,minLocalization,maxPeaksVal,maxLocalization);

    if minLocalization(1) < maxLocalization(1)
        % So start before the min to max phase
        if numPerson < 0
            if strcmp(personParam(5),"SX")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = maxLocalization(i)-minLocalization(i);
                    RtoH_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        HtoR_time(i) = minLocalization(i+1)-maxLocalization(i);
                        HtoR_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = maxLocalization(i)-minLocalization(i);
                    HtoR_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        RtoH_time(i) = minLocalization(i+1)-maxLocalization(i);
                        RtoH_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                    end
                end
            end
        else
            if strcmp(personParam(5),"DX")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = maxLocalization(i)-minLocalization(i);
                    RtoH_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        HtoR_time(i) = minLocalization(i+1)-maxLocalization(i);
                        HtoR_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = maxLocalization(i)-minLocalization(i);
                    HtoR_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        RtoH_time(i) = minLocalization(i+1)-maxLocalization(i);
                        RtoH_space(i) =  minPeaksVal(i+1)-maxPeaksVal(i);
                    end
                end
            end
        end
    else
        if numPerson < 0
            if strcmp(personParam(5),"SX")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = minLocalization(i)-maxLocalization(i);
                    RtoH_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        HtoR_time(i) = maxLocalization(i+1)-minLocalization(i);
                        HtoR_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = minLocalization(i)-maxLocalization(i);
                    HtoR_space(i) = minPeaksVal(i)-maxPeaksVal(i); 
                    if i+1 <= length(maxLocalization)
                        RtoH_time(i) = maxLocalization(i+1)-minLocalization(i);
                        RtoH_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                    end
                end
            end
        else
            if strcmp(personParam(5),"DX")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = minLocalization(i)-maxLocalization(i);
                    RtoH_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        HtoR_time(i) = maxLocalization(i+1)-minLocalization(i);
                        HtoR_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = minLocalization(i)-maxLocalization(i);
                    HtoR_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        RtoH_time(i) = maxLocalization(i+1)-minLocalization(i);
                        RtoH_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                    end
                end
            end
        end
    end
    
    %% Plot results for phase time duration
    meanHtoR_time = mean(HtoR_time);
    meanRtoH_time = mean(RtoH_time);

    fig1 = figure('Name','Phases duration');
    fig1.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR_time.*60./10000,'ro','DisplayName','Human to Robot phase')
    plot(RtoH_time.*60./10000,'bo','DisplayName','Robot to Human phase')
    yline(meanHtoR_time.*60./10000,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(meanRtoH_time.*60./10000,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Time length of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Time [ s ]")
    legend('show')
    hold off

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\ProcessedData\PhaseTimeDuration;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\PhaseTimeDuration\B",num2str(3+numPerson),".png"],"");
        else    
            path = strjoin(["..\ProcessedData\PhaseTimeDuration\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig1,path)
    end

    %% Plot results for phase space duration
    meanHtoR_space = mean(HtoR_space);
    meanRtoH_space = mean(RtoH_space);

    fig2 = figure('Name','Phases duration');
    fig2.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR_space.*100,'ro','DisplayName','Human to Robot phase')
    plot(RtoH_space.*100,'bo','DisplayName','Robot to Human phase')
    yline(meanHtoR_space.*100,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(meanRtoH_space.*100,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Range Of Motion of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Phase Range Of Motion [ROM] [ cm ]")
    legend('show')
    hold off

    % Figure saving for phase space duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\ProcessedData\PhaseSpaceDuration;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\PhaseSpaceDuration\B",num2str(3+numPerson),".png"],"");
        else    
            path = strjoin(["..\ProcessedData\PhaseSpaceDuration\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig2,path)
    end

    % Alternative versione with absolute values
    fig3 = figure('Name','Phases duration');
    fig3.WindowState = 'maximized';
    hold on, grid on
    plot(abs(HtoR_space).*100,'ro','DisplayName','Human to Robot phase')
    plot(abs(RtoH_space).*100,'bo','DisplayName','Robot to Human phase')
    yline(abs(meanHtoR_space).*100,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(abs(meanRtoH_space).*100,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Range Of Motion of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Phase Range Of Motion [ROM] [ cm ]")
    legend('show')
    hold off

    % Figure saving for phase space duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\ProcessedData\PhaseSpaceDuration;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\PhaseSpaceDuration\B",num2str(3+numPerson),".png"],"");
        else    
            path = strjoin(["..\ProcessedData\PhaseSpaceDuration\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig3,path)
    end

    close(fig1);
    close(fig2);
    close(fig3);

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

    %% Movement range & Max e Min average distance
    maxMinAverageDistance = 0;
    movementRange = zeros(1,min(length(maxPeaksVal),length(minPeaksVal)));
    for i = 1:min(length(maxPeaksVal),length(minPeaksVal))
        movementRange(i) = abs(maxPeaksVal(i)-minPeaksVal(i));
        maxMinAverageDistance = maxMinAverageDistance + movementRange(i);
    end
    maxMinAverageDistance = maxMinAverageDistance/i;
    p = polyfit(1:length(movementRange),movementRange,fittingOrder);
    ROM = mean(movementRange);
    movementRange = polyval(p,linspace(1,length(movementRange)));

    %% Peaks variation 
    p = polyfit(1:length(maxPeaksVal),maxPeaksVal,fittingOrder);
    maxPeaksVariation = polyval(p,linspace(1,max(length(maxPeaksVal),length(minPeaksVal))));
    p = polyfit(1:length(minPeaksVal),minPeaksVal,fittingOrder);
    minPeaksVariation = polyval(p,linspace(1,max(length(maxPeaksVal),length(minPeaksVal))));
    
    if numPerson < 0
        if strcmp(personParam(5),"SX") == 1
            posAPeaksStd = std(maxPeaksVal);
            posBPeaksStd = std(minPeaksVal);
            posAPeaksmean = mean(maxPeaksVal);
            posBPeaksmean = mean(minPeaksVal);
        else
            posAPeaksStd = std(minPeaksVal);
            posBPeaksStd = std(maxPeaksVal);
            posAPeaksmean = mean(minPeaksVal);
            posBPeaksmean = mean(maxPeaksVal);
        end
    else
        if strcmp(personParam(5),"DX") == 1
            posAPeaksStd = std(maxPeaksVal);
            posBPeaksStd = std(minPeaksVal);
            posAPeaksmean = mean(maxPeaksVal);
            posBPeaksmean = mean(minPeaksVal);
        else
            posAPeaksStd = std(minPeaksVal);
            posBPeaksStd = std(maxPeaksVal);
            posAPeaksmean = mean(minPeaksVal);
            posBPeaksmean = mean(maxPeaksVal);
        end
    end

    %% Peaks initial and final variation
    peaksInitialAndFinalVariation = abs(maxPeaksVariation(end)-minPeaksVariation(end))-abs(maxPeaksVariation(1)-minPeaksVariation(1));

    %% Synchronism efficiency based on positions
    % Baseline signal analysis
    if numPerson >= 0 % The baseline it is skipped        
        maximumMovementTime = 0.5;
        if strcmp(personParam(5),"DX") == 1 
            [envHigh, envLow] = envelope(baseline{1},maximumMovementTime*frequency*0.8,'peak');
        else
            [envHigh, envLow] = envelope(baseline{2},maximumMovementTime*frequency*0.8,'peak');
        end
        averageEnv = (envLow+envHigh)/2;
        
        [maxPeaksVal, ~] = findpeaks(averageEnv);
        [minPeaksVal, ~] = findpeaks(-averageEnv);
        minPeaksVal = -minPeaksVal;
        baseMaxPeaksAverage = mean(maxPeaksVal);
        baseminPeaksAverage = mean(minPeaksVal);
    
        p = polyfit(1:length(maxPeaksVal),maxPeaksVal,fittingOrder);
        baseMaxPeaksVariation = polyval(p,linspace(1,max(length(maxPeaksVal),length(minPeaksVal))));
        p = polyfit(1:length(minPeaksVal),minPeaksVal,fittingOrder);
        baseMinPeaksVariation = polyval(p,linspace(1,max(length(maxPeaksVal),length(minPeaksVal))));
    
        
        upperSynchroEfficiency = 100-abs(baseMaxPeaksVariation-maxPeaksVariation)./abs(baseMaxPeaksAverage-baseminPeaksAverage).*100;
        lowerSynchroEfficiency = 100-abs(baseMinPeaksVariation-minPeaksVariation)./abs(baseMaxPeaksAverage-baseminPeaksAverage).*100;
        
        synchroEfficiency = (upperSynchroEfficiency+lowerSynchroEfficiency)./2;
    else
        synchroEfficiency = zeros(1,100);
    end

end