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

function [experimentDuration, meanHtoR_time, meanRtoH_time, meanHtoR_space, meanRtoH_space, phaseTimeDifference, ...
            nMaxPeaks, nMinPeaks, maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
            movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
            peaksInitialAndFinalVariation, synchroEfficiency, posAPeaksStd, ...
            posBPeaksStd, posAPeaksmean, posBPeaksmean, ROM, HtoR_relativeVelocity, RtoH_relativeVelocity] = ...
              posFurtherAnalysis(synchPosDataSet,numPerson,personParam,baseline, BaselineFilesParameters)
% The main aim of this function is to elaborate position signals in order to extract
% some interesting data that would be usefull to compare with the overrall
% test population into some scatter plot or others

%% OUTPUT PARAMETERS EXPLANATION
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
% posAPeaksStd = pos A peaks standard deviation
% posBPeaksStd = pos B peaks standard deviation
% posAPeaksmean = pos A peaks average in meters
% posBPeaksmean =  pos B peaks average in meters
% ROM = Range Of Motion, difference in meters between posA and posB

    %% Parameters for the simulation     
    frequency = 100;
    fittingOrder = 4; % Order used into the polyfit functions
    IMAGE_SAVING = 1;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");
    PAUSE_TIME = 2;

    %% Phase duration evaluation
%     maximumMovementTime = 0.1;
%     [envHigh, envLow] = envelope(synchPosDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
%     averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(synchPosDataSet(:,2),'MinPeakHeight',mean(synchPosDataSet(:,2))-mean(synchPosDataSet(:,2))*0.05, 'MinPeakDistance', 40, 'MinPeakProminence', 0.01);
    [minPeaksVal, minLocalization] = findpeaks(-synchPosDataSet(:,2),'MinPeakHeight',-mean(synchPosDataSet(:,2))+mean(synchPosDataSet(:,2))*0.05, 'MinPeakDistance', 40, 'MinPeakProminence', 0.01);
    minPeaksVal = -minPeaksVal;
    
    % If occurs that two or more maximums/minimums are not separated from
    % the opposite, it will be taken the average of them, both temporarly
    % and position value
    % firstly find the higher density of peaks
    maxFlag = 0;
    if length(minLocalization) < length(maxLocalization)
        HtmpLocalization = [maxLocalization,maxPeaksVal];
        LtmpLocalization = [minLocalization,minPeaksVal];
        maxFlag = 1;
    else
        HtmpLocalization = [minLocalization,minPeaksVal];
        LtmpLocalization = [maxLocalization,maxPeaksVal];
        maxFlag = 0;
    end

    % then with the found maximum analyze all the peaks looking for
    % sovrappositions
    cnt = 1;
    if HtmpLocalization(1,1) > LtmpLocalization(1,1)
        cnt = cnt + 1;
    end
    checkCnt = 0;
    newHLocalization = [];
    for i = 1:(size(HtmpLocalization,1)-1)
        if size(LtmpLocalization,1) >= cnt
            if HtmpLocalization(i+1,1) < LtmpLocalization(cnt,1)
                checkCnt = checkCnt + 1;
            else
                if checkCnt > 0
                    newHLocalization = [newHLocalization;mean(HtmpLocalization(i-checkCnt:i,1)),mean(HtmpLocalization(i-checkCnt:i,2))];
                    checkCnt = 0;
                else
                    newHLocalization = [newHLocalization;HtmpLocalization(i,1),HtmpLocalization(i,2)];
                end
                cnt = cnt + 1;
            end
        end
    end
    newHLocalization = [newHLocalization;HtmpLocalization(end,1),HtmpLocalization(end,2)];

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

    % Now do the same but inverting the parts
    
%     repeatFiltering = 1;
    for k = 1:2
%         repeatFiltering = 0;
        % Now do the same but inverting the parts
        if maxFlag == 0
            HtmpLocalization = [maxLocalization,maxPeaksVal];
            LtmpLocalization = [minLocalization,minPeaksVal];
            maxFlag = 1;
        else if maxFlag == 1
            HtmpLocalization = [minLocalization,minPeaksVal];
            LtmpLocalization = [maxLocalization,maxPeaksVal];
            maxFlag = 0;
        end, end
    
        % then with the found minimum analyze all the peaks looking for
        % sovrappositions
        cnt = 1;
        if HtmpLocalization(1,1) > LtmpLocalization(1,1)
            cnt = cnt + 1;
        end
        checkCnt = 0;
        newHLocalization = [];
        for i = 1:(size(HtmpLocalization,1)-1)
            if size(LtmpLocalization,1) >= cnt
                if HtmpLocalization(i+1,1) < LtmpLocalization(cnt,1)
                    checkCnt = checkCnt + 1;
                else
                    if checkCnt > 0
                        newHLocalization = [newHLocalization;mean(HtmpLocalization(i-checkCnt:i,1)),mean(HtmpLocalization(i-checkCnt:i,2))];
                        checkCnt = 0;
                    else
                        newHLocalization = [newHLocalization;HtmpLocalization(i,1),HtmpLocalization(i,2)];
                    end
                    cnt = cnt + 1;
                end
            end
        end
        newHLocalization = [newHLocalization;HtmpLocalization(end,1),HtmpLocalization(end,2)];
    
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
%             repeatFiltering = 1;
        end
    end

%     % Cleaning the peaks from doubles
%     [minPeaksVal,minLocalization,maxPeaksVal,maxLocalization] = maxMinCleaning(minPeaksVal,minLocalization,maxPeaksVal,maxLocalization);

    if minLocalization(1) < maxLocalization(1)
        % So start before the min to max phase
        if numPerson < 0
            if strcmp(personParam(5),"L")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = maxLocalization(i)-minLocalization(i);
                    RtoH_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        HtoR_time(i) = minLocalization(i+1)-maxLocalization(i);
                        HtoR_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = maxLocalization(i)-minLocalization(i);
                    HtoR_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        RtoH_time(i) = minLocalization(i+1)-maxLocalization(i);
                        RtoH_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                        if RtoH_time(i) > 200 || HtoR_time(i) > 200
                            fprintf("")
                        end
                    end
                end
            end
        else
            if strcmp(personParam(5),"R")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = maxLocalization(i)-minLocalization(i);
                    RtoH_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        HtoR_time(i) = minLocalization(i+1)-maxLocalization(i);
                        HtoR_space(i) = minPeaksVal(i+1)-maxPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end                    
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = maxLocalization(i)-minLocalization(i);
                    HtoR_space(i) = maxPeaksVal(i)-minPeaksVal(i);
                    if i+1 <= length(minLocalization)
                        RtoH_time(i) = minLocalization(i+1)-maxLocalization(i);
                        RtoH_space(i) =  minPeaksVal(i+1)-maxPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end
                end
            end
        end
    else
        if numPerson < 0
            if strcmp(personParam(5),"L")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = minLocalization(i)-maxLocalization(i);
                    RtoH_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        HtoR_time(i) = maxLocalization(i+1)-minLocalization(i);
                        HtoR_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = minLocalization(i)-maxLocalization(i);
                    HtoR_space(i) = minPeaksVal(i)-maxPeaksVal(i); 
                    if i+1 <= length(maxLocalization)
                        RtoH_time(i) = maxLocalization(i+1)-minLocalization(i);
                        RtoH_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end 
                end
            end
        else
            if strcmp(personParam(5),"R")
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    RtoH_time(i) = minLocalization(i)-maxLocalization(i);
                    RtoH_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        HtoR_time(i) = maxLocalization(i+1)-minLocalization(i);
                        HtoR_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end
                end
            else
                for i = 1:min(length(minLocalization),length(maxLocalization))
                    HtoR_time(i) = minLocalization(i)-maxLocalization(i);
                    HtoR_space(i) = minPeaksVal(i)-maxPeaksVal(i);
                    if i+1 <= length(maxLocalization)
                        RtoH_time(i) = maxLocalization(i+1)-minLocalization(i);
                        RtoH_space(i) = maxPeaksVal(i+1)-minPeaksVal(i);
                        if RtoH_time(i) > 300 || HtoR_time(i) > 300
                            fprintf("")
                        end
                    end
                end
            end
        end
    end
    
    RtoH_relativeVelocity = RtoH_space./(RtoH_time./100);
    HtoR_relativeVelocity = HtoR_space./(HtoR_time./100);

    timePhasesNumber = min(length(HtoR_time),length(RtoH_time));
    velocityDifference = abs(RtoH_relativeVelocity(1:timePhasesNumber))-abs(HtoR_relativeVelocity(1:timePhasesNumber));
    differenceDerivative = zeros(1,timePhasesNumber-1);
    RtoH_relativeAcceleration = zeros(1,timePhasesNumber-1);
    HtoR_relativeAcceleration = zeros(1,timePhasesNumber-1);
    for i = 1:timePhasesNumber-1
        differenceDerivative(i) = (velocityDifference(i+1)-velocityDifference(i))/HtoR_time(i)*100;
        RtoH_relativeAcceleration(i) = (RtoH_relativeVelocity(i+1)-RtoH_relativeVelocity(i))/RtoH_time(i)*100;
        HtoR_relativeAcceleration(i) = (HtoR_relativeVelocity(i+1)-HtoR_relativeVelocity(i))/HtoR_time(i)*100;
    end
    initialHvelocity = abs(RtoH_relativeVelocity(1));
    initialRvelocity = abs(HtoR_relativeVelocity(1));
    mkdir ..\iCub_ProcessedData\AbsoluteRelativeVelocity\DifferenceDerivative
    if numPerson > 0
        save(strjoin(["..\iCub_ProcessedData\AbsoluteRelativeVelocity\DifferenceDerivative\",num2str(numPerson)],""),"HtoR_relativeVelocity","RtoH_relativeVelocity","HtoR_relativeAcceleration","RtoH_relativeAcceleration","RtoH_time","HtoR_time");
    end
    
    %% Evaluation of phase time difference
%     fprintf("Difference of number of phases: %d",length(HtoR_time)-length(RtoH_time))
    phaseTimeDifference = mean(RtoH_time(1:timePhasesNumber)-HtoR_time(1:timePhasesNumber));
    
    fig1a = figure('Name','Phases duration');
    fig1a.WindowState = 'maximized';
    hold on, grid on
    plot((RtoH_time(1:timePhasesNumber)-HtoR_time(1:timePhasesNumber))./100,'ro','DisplayName','Time difference')
    yline(phaseTimeDifference./100,'b--','DisplayName',"Mean",'LineWidth',2)
    title("Simmetry index - Difference in time between H and R phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Time [ s ]")
    legend('show')
    hold off

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\PhaseTimeDifference;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\PhaseTimeDifference",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\PhaseTimeDifference\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\PhaseTimeDifference\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig1a,path)
        close(fig1a);
    end


    %% Plot results for phase time duration
    meanHtoR_time = mean(HtoR_time);
    meanRtoH_time = mean(RtoH_time);

    fig1 = figure('Name','Phases duration');
    fig1.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR_time./100,'ro','DisplayName','Human to Robot phase')
    plot(RtoH_time./100,'bo','DisplayName','Robot to Human phase')
    yline(meanHtoR_time./100,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(meanRtoH_time./100,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Time length of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Time [ s ]")
    legend('show')
    hold off

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\PhaseTimeDuration;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\PhaseTimeDuration",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\PhaseTimeDuration\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\PhaseTimeDuration\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig1,path)
    end

    %% Plot results for phase space duration
    fig2 = figure('Name','Phases duration');
    fig2.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR_space.*100,'ro','DisplayName','Human to Robot phase')
    plot(RtoH_space.*100,'bo','DisplayName','Robot to Human phase')
    yline(mean(HtoR_space).*100,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(mean(RtoH_space).*100,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Range Of Motion of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Phase Range Of Motion [ROM] [ cm ]")
    legend('show')
    hold off

    meanHtoR_space = mean(abs(HtoR_space));
    meanRtoH_space = mean(abs(RtoH_space));

    % Figure saving for phase space duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\PhaseSpaceDuration;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration\P",num2str(numPerson),".png"],"");
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
        mkdir ..\iCub_ProcessedData\PhaseSpaceDuration;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\PhaseSpaceDuration\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig3,path)
    end

    close(fig1);
    close(fig2);
    close(fig3);

    %% Plot results for relative velocity
    fig4 = figure('Name','Phases relative velocity');
    fig4.WindowState = 'maximized';
    hold on, grid on
    plot(HtoR_relativeVelocity.*100,'ro','DisplayName','Human to Robot phase')
    plot(RtoH_relativeVelocity.*100,'bo','DisplayName','Robot to Human phase')
    yline(mean(HtoR_relativeVelocity).*100,'r--','DisplayName',"HtoR_{mean}",'LineWidth',2)
    yline(mean(RtoH_relativeVelocity).*100,'b--','DisplayName',"RtoH_{mean}",'LineWidth',2)
    title("Relative velocity of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Velocity [ cm/s ]")
    legend('show','Location','east')
    hold off

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\RelativeVelocity;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\RelativeVelocity",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\RelativeVelocity\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\RelativeVelocity\P",num2str(numPerson),".png"],"");
        end
        exportgraphics(fig4,path)
        close(fig4);
    end

    fig4a = figure('Name','Phases relative velocity');
    fig4a.WindowState = 'maximized';
    hold on, grid on
    plot(abs(HtoR_relativeVelocity).*100,'ro','DisplayName','Robot phase velocity')
    plot(abs(RtoH_relativeVelocity).*100,'bo','DisplayName','Human phase velocity')
    yline(abs(mean(HtoR_relativeVelocity)).*100,'r--','DisplayName',"v^{Robot}_{mean}",'LineWidth',2)
    yline(abs(mean(RtoH_relativeVelocity)).*100,'b--','DisplayName',"v^{Human}_{mean}",'LineWidth',2)
    title("Absolute relative velocity of phases",defaultTitleName)
    xlabel("Phase number")
    ylabel("Velocity [ cm/s ]")
    legend('show','Location','east')
    hold off

    % Figure saving for phase time duration
    if IMAGE_SAVING
        pause(PAUSE_TIME);
        mkdir ..\iCub_ProcessedData\AbsoluteRelativeVelocity;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\AbsoluteRelativeVelocity",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\AbsoluteRelativeVelocity\",BaselineFilesParameters(3),".png"],"");
        else    
            path = strjoin(["..\iCub_ProcessedData\AbsoluteRelativeVelocity\P",num2str(numPerson),".png"],"");
            % Load the existing Excel file
            file = '..\iCub_ProcessedData\AbsoluteRelativeVelocity\AbsoluteRelativeVelocity.xlsx';
            interpSize = 200;
            % Check if the file exists
            if exist(file, 'file') == 2
                if numPerson == 2
                    delete(file);
                    data = table;
                else
                    % File exists, so read the existing data
                    data = readtable(file);
                end
            else
                % File does not exist, create an empty table
                data = table;
            end
            varLen = min(length(HtoR_relativeVelocity),length(RtoH_relativeVelocity));
            new_columns_data = [abs(RtoH_relativeVelocity(1:varLen)).*100;abs(HtoR_relativeVelocity(1:varLen)).*100]';
            Hy = interp1(linspace(1,interpSize,varLen),new_columns_data(:,1),1:interpSize);
            Ry = interp1(linspace(1,interpSize,varLen),new_columns_data(:,2),1:interpSize);
            new_columns_data = [Hy',Ry'];
            % Create a table with the new column and title
            new_data = array2table(new_columns_data);
            new_columns_titles = [strjoin(["Human Test N.",num2str(numPerson)],""),strjoin(["Robot Test N.",num2str(numPerson)],"")];
            new_data = renamevars(new_data,1:width(new_data),new_columns_titles);
            % Concatenate the new table with the existing data table
            data = [data, new_data];
            % Write the updated table back to the Excel file
            writetable(data, file);
        end
        exportgraphics(fig4a,path)
        close(fig4a);
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
        if strcmp(personParam(5),"L") == 1
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
        if strcmp(personParam(5),"R") == 1
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
        if strcmp(personParam(5),"R") == 1 
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