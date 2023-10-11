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

function [ultimateSynchPosDataSet, ultimateSynchForceDataSet] = ...
    synchSignalsData(posDataSet, forceDataSet, numPerson, personParameters, pausePeople)
% This function is responsible for detecting the initial point of each signal wave
% and cut everything before that instant during the greetings, than knowing the experiment
% duration, is evaluated the total signal wave and then cutted the excess
% registered into the experiment closing phase, and allign them in order to
% print at last a unique plot with both the final elaborated signals.

% NOTE THIS: the output is not composed as the input of a whole dataset, but is only
%            composed of [ultimateTimeStamp,ultimateSignal], where each
%            data is a column vector.

% personParameters DETAILS: this array contains a quantity of string, make sure
%                           to apply strjoin() before use in a text context.

% pausePerson DETAILS: this variable = 0 for normal working, but if is a
%                      value ~ 0, then it stop at the test equal to this value without closing
%                      the graphs, in order to can handle them
%                      It also can be an array of people!

% TODO: 
% - Add the boundaries of position in order to recognise human side and
%   robot side

    %% Parameters for the simulation 
    DEBUG = 0;                  % Debug binary variable, use it =1 to unlock some parts of the code, normally unusefull
    IMAGE_SAVING = 1;           % Put to 1 in order to save the main plots
    axisYLimMultiplier = 1.5;   % Multiplies the chosen y limits for axis plotting
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParameters],"");
    
    if IMAGE_SAVING
        mkdir ProcessedData;
    end

    %% A priori informations
    experimentDuration = 24000;
    frequency = 100;
    
    %% POSITION ANALYSIS
    % Firstly the signal is enveloped on the max and min, and the average is
    % evaluated
    elapsedTime = minutesDataPointsConverter(posDataSet);
    maximumMovementTime = 0.1;
    [envHigh, envLow] = envelope(posDataSet.yPos,maximumMovementTime*frequency*0.8,'peak');
    firstAverageEnv = (envLow+envHigh)/2;
    
    % Plot results
    fig1 = figure('Name','Position visualization');
    fig1.WindowState = 'maximized';
    subplot(2,1,1), hold on, grid on
    plot(elapsedTime,posDataSet.yPos,'k-','DisplayName', 'y position')
    plot(elapsedTime,firstAverageEnv,'r--','DisplayName','Average signal')
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    ylabel("Position [ m ]")
    title("Original signal")
    legend('show','Location','eastoutside')
    hold off
    
    % The signal derivative is evaluated
    posDerivative = zeros(1,length(firstAverageEnv)-1);
    for i = 2:length(firstAverageEnv)
        posDerivative(i) = (firstAverageEnv(i)-firstAverageEnv(i-1))/10e-5;
    end
    
    % Plot results
    fig2 = figure('Name','Position processing through derivative and filtering');
    fig2.WindowState = 'maximized';
    subplot(4,1,1), hold on, grid on
    plot(elapsedTime,posDerivative)
    title("Derivative of the original signal")
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    hold off
    
    %% Low pass filter
    % Removing noise in the force signal implies the use of a lowpass filter,
    % which introduce a phase shift to the signal. In order to avoid this
    % shift, a chebyshev filter is designed, and then its coefficient are
    % re-elaborated in order to remove the shift using a zero phase digital
    % filter funct (filtfilt())
    fc = 2;
    gain = 1;
    
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Plot the filter properties
%     fvtool(sos,'Fs',fs)
    % Remove the pahse shifting and compute the output
    filteredPosDerivative = filtfilt(sos,gain,posDerivative);
    
    % Plot results
    subplot(4,1,2), hold on, grid on
    plot(elapsedTime,filteredPosDerivative)
    title("Filtered signal")
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    hold off
    
    %% Identification of starting
    % Average slope of the position signal in the first robot phase
%     slopeRequired = 1e3;
    stdRequired = 0.9; % Estimated graphycally looking at the plots into \ProcessedData\PositionDerivativeSTD
    subSetDimension = 25;

    findedFlag = 0;
    % This flag let find just one time the start position but let
    % evaluating the slope for the whole signal
    
    for i = subSetDimension+1:subSetDimension:length(firstAverageEnv)
%         % The following method has been removed due to lower preceision
%         % Trying to catch an high slope and save the point
%         slope(i) = (abs(filteredPosDerivative(i)-filteredPosDerivative(i-subSetDimension)))/10e-5;
%         if (slope(i) > slopeRequired && findedFlag == 0)
%             posStart = i-25;
%             findedFlag = 1;
%         end

        posStd(i) = std(filteredPosDerivative(i-subSetDimension:i));
        if (posStd(i) > stdRequired && findedFlag == 0)
            derivativePosStart = i-25;
            findedFlag = 1;
        end
    end

    if DEBUG
%         figure, hold on, grid on, plot(slope), hold off
%         mkdir ProcessedData\PositionDerivativeSlope;
%         path = strjoin(["ProcessedData\PositionDerivativeSlope\P",num2str(numPerson),".png"],"");
%         exportgraphics(gcf,path)
%         close(gcf);

        figure, hold on, grid on, plot(posStd), hold off
%         mkdir ProcessedData\PositionDerivativeSTD;
%         path = strjoin(["ProcessedData\PositionDerivativeSTD\P",num2str(numPerson),".png"],"");
%         exportgraphics(gcf,path)
%         close(gcf);

        % Define any derivativePosStart just to run the code for image savings
        derivativePosStart = 300;
    end
    

    %% Identification of ending point
    % Finally the ending point is firstly found only adding the experiment time
    % but knowing that the conclusion include a rotation of the chest during
    % the last robot phase, we need to esclude that last part of the signal.
    initialPosEnd = derivativePosStart+experimentDuration;
    cuttedFilteredPosDerivative = filteredPosDerivative(derivativePosStart:initialPosEnd);
    
    % So the peaks of the experiment time derivative are evaluated and the
    % mean of them is calculated
    [maxPeaksVal, maxLocalization] = findpeaks(cuttedFilteredPosDerivative);
    [minPeaksVal, minLocalization] = findpeaks(-cuttedFilteredPosDerivative);
    minPeaksVal = -minPeaksVal;
    upperPeaksBound = mean(maxPeaksVal);
    lowerPeaksBound = mean(minPeaksVal);

    %% Middle peaks removal
    % Sometimes, middle peaks can appear during phase transition, but not
    % being interested on them, using the just evaluated boundaries, a second peaks evaluation is done in the
    % following
    [maxPeaksVal, maxLocalization] = findpeaks(cuttedFilteredPosDerivative,'MinPeakHeight',mean([upperPeaksBound,mean(cuttedFilteredPosDerivative)]));
    [minPeaksVal, minLocalization] = findpeaks(-cuttedFilteredPosDerivative,'MinPeakHeight',-mean([mean(cuttedFilteredPosDerivative),lowerPeaksBound]));
    minPeaksVal = -minPeaksVal;
    secureUpperPeaksBound = mean(maxPeaksVal);
    secureLowerPeaksBound = mean(minPeaksVal);
    % Basically in the lines above a new boundary is evaluated,
    % considering the mean between the upper boundary and the mean of the
    % signal, used as lower treshold for peaks finding
    
    maxLocalization = maxLocalization*10e-5;
    minLocalization = minLocalization*10e-5;

    % The just got boundaries are used to check for a period including the last
    % robot phase, and choosing the end point just outside this boundaries
    for i = initialPosEnd-150:initialPosEnd
        if filteredPosDerivative(i) > secureUpperPeaksBound || filteredPosDerivative(i) < secureLowerPeaksBound
            derivativePosEnd = i;
            break;
        else
            derivativePosEnd = initialPosEnd;
        end
    end

    %% Check for incorrect lenghth of the experiment
    % In this section are corrected the signals which length is lower than
    % the expected 4 minute, due to reading or savings error, or too late
    % dumping request. This could be evaluated looking at the just evaluated ending
    % position, which has been always registered in this cases leaning onto a
    % constant line of the derivative (which is the iCub talk ending phase of the
    % experiment).
    % So in order to solve out his problem, we can check the std of the end
    % point, which is surely lower than a safe threshold if caught in this
    % phase. Then we go back in the time looking for a good std value and
    % we repeat the whole process of "Identification of ending point" and
    % "Middle peaks removal"
    safeThreshold = 0.5;
    shortSignalFirstEndPoint = 0; % Used for plot printing, if remains 0 will not be printed
    if posStd(derivativePosEnd) < safeThreshold
        shortSignalFirstEndPoint = derivativePosEnd;
        for i = derivativePosEnd:-1:derivativePosStart
            if posStd(i) > stdRequired
                newDerivativePosEnd = i;
                break;
            end
        end
        if newDerivativePosEnd == derivativePosEnd
            % Then in this case the shortening did not work or something bad happend, 
            % and makes no sense to continue to evaluate this signal. So an error is thrown,
            % choice of who is analyzing this data to decide if remove the
            % test from the list of "analyzable" or find a new code fix
            error('The signal N. %d is shorter than 4 minutes and the end position shortening went wrong.',numPerson);
        end

        cuttedFilteredPosDerivative = []; % Cleaning the vector before re-use it
        cuttedFilteredPosDerivative = filteredPosDerivative(derivativePosStart:newDerivativePosEnd);
    
        % So the peaks of the experiment time derivative are evaluated and the
        % mean of them is calculated
        [maxPeaksVal, maxLocalization] = findpeaks(cuttedFilteredPosDerivative);
        [minPeaksVal, minLocalization] = findpeaks(-cuttedFilteredPosDerivative);
        minPeaksVal = -minPeaksVal;
        upperPeaksBound = mean(maxPeaksVal);
        lowerPeaksBound = mean(minPeaksVal);
    
        % Sometimes, middle peaks can appear during phase transition, but not
        % being interested on them, using the just evaluated boundaries, a second peaks evaluation is done in the
        % following
        [maxPeaksVal, maxLocalization] = findpeaks(cuttedFilteredPosDerivative,'MinPeakHeight',mean([upperPeaksBound,mean(cuttedFilteredPosDerivative)]));
        [minPeaksVal, minLocalization] = findpeaks(-cuttedFilteredPosDerivative,'MinPeakHeight',-mean([mean(cuttedFilteredPosDerivative),lowerPeaksBound]));
        minPeaksVal = -minPeaksVal;
        secureUpperPeaksBound = mean(maxPeaksVal);
        secureLowerPeaksBound = mean(minPeaksVal);
        % Basically in the lines above a new boundary is evaluated,
        % considering the mean between the upper boundary and the mean of the
        % signal, used as lower treshold for peaks finding
        
        maxLocalization = maxLocalization*10e-5;
        minLocalization = minLocalization*10e-5;
    
        % The just got boundaries are used to check for a period including the last
        % robot phase, and choosing the end point just outside this boundaries
        for i = newDerivativePosEnd-150:newDerivativePosEnd
            if filteredPosDerivative(i) > secureUpperPeaksBound || filteredPosDerivative(i) < secureLowerPeaksBound
                derivativePosEnd = i;
                break;
            else
                derivativePosEnd = newDerivativePosEnd;
            end
        end
    end


    %% Savings cutted derivative dataSet
    cuttedFilteredPosDerivative = filteredPosDerivative(derivativePosStart:derivativePosEnd);
    derivativeCuttedElapsedTime = elapsedTime(derivativePosStart:derivativePosEnd)-elapsedTime(derivativePosStart);
    
    %% Plot results
    subplot(4,1,3), hold on, grid on
    plot(elapsedTime,filteredPosDerivative,'DisplayName','y_{filtered}')
    plot(elapsedTime(derivativePosStart),filteredPosDerivative(derivativePosStart),'ro','DisplayName','Starting point')
    plot(elapsedTime(initialPosEnd),filteredPosDerivative(initialPosEnd),'go','DisplayName','Initial ending point')
    if shortSignalFirstEndPoint ~= 0
        plot(elapsedTime(shortSignalFirstEndPoint),filteredPosDerivative(shortSignalFirstEndPoint),'yo','DisplayName','Short signal ending point')
    end
    plot(elapsedTime(derivativePosEnd),filteredPosDerivative(derivativePosEnd),'bo','DisplayName','Ending point')
    yline(upperPeaksBound,'k--','DisplayName','Higher bound')
    yline(lowerPeaksBound,'k--','DisplayName','Lower bound')
    title("Evaluation of the starting and ending points")
    legend('show','Location','eastoutside')
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    hold off
    
    subplot(4,1,4), hold on, grid on
    plot(derivativeCuttedElapsedTime,cuttedFilteredPosDerivative,'DisplayName','y_{cutted}')
    plot(maxLocalization,maxPeaksVal,'ro','DisplayName','Maximum peaks')
    plot(minLocalization,minPeaksVal,'go','DisplayName','Minimum peaks')
    yline(upperPeaksBound,'k--','DisplayName','Higher bound')
    yline(lowerPeaksBound,'k--','DisplayName','Lower bound')
    yline(secureUpperPeaksBound,'r--','DisplayName','Secure Higher bound')
    yline(secureLowerPeaksBound,'g--','DisplayName','Secure lower bound')
    ylim(axisYLimMultiplier.*[min(minPeaksVal),max(maxPeaksVal)])
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    title("Final derivative graph")
    legend('show','Location','eastoutside')
    hold off
    sgtitle(defaultTitleName)

    %% Adjust starting and ending position
    % In order to cut data which are not complete, the starting and ending
    % position are shifted to the nearest peak, in the just cutted signal.
    cutPosAverage = firstAverageEnv(derivativePosStart:derivativePosEnd);
    firstCutPosDataSet = posDataSet.yPos(derivativePosStart:derivativePosEnd);
    [maxPeaksVal, maxLocalization] = findpeaks(cutPosAverage,'MinPeakHeight',mean(cutPosAverage));
    [minPeaksVal, minLocalization] = findpeaks(-cutPosAverage,'MinPeakHeight',-mean(cutPosAverage));
    minPeaksVal = -minPeaksVal;
    upperPeaksBound = mean(maxPeaksVal);
    lowerPeaksBound = mean(minPeaksVal);

    posStart = min(minLocalization(1),maxLocalization(1));
    posEnd = max(minLocalization(end),maxLocalization(end));

    maxLocalization = maxLocalization*10e-5-elapsedTime(posStart);
    minLocalization = minLocalization*10e-5-elapsedTime(posStart);

    cuttedPosDataSet = firstCutPosDataSet(posStart:posEnd);
    cuttedElapsedTime = elapsedTime(posStart:posEnd)-elapsedTime(posStart);
    cuttedAverageBehavior = cutPosAverage(posStart:posEnd);

    timeDelayFromOriginalPos = derivativePosStart;
    
    %% Phases number evaluation
    posUpperPhase = length(maxPeaksVal);
    posLowerPhase = length(minPeaksVal);
    
    if DEBUG
        fprintf("\nPosition peaks:\n")
        fprintf("\t- N. MAX: %d\n",posUpperPhase)
        fprintf("\t- N. min: %d\n",posLowerPhase)
    end
    
    %% Plot results
    figure(fig1)
    subplot(2,1,1)
    plot(elapsedTime,posDataSet.yPos,'k-','DisplayName', 'y position')
    hold on, grid on
    plot(elapsedTime,firstAverageEnv,'r--','DisplayName','Average signal')
    plot(elapsedTime(derivativePosStart),posDataSet.yPos(derivativePosStart),'ro','DisplayName','Derivative starting point')
    plot(elapsedTime(derivativePosEnd),posDataSet.yPos(derivativePosEnd),'bo','DisplayName','Derivative ending point')
    plot(elapsedTime(posStart+timeDelayFromOriginalPos),posDataSet.yPos(posStart+timeDelayFromOriginalPos),'ro','DisplayName','Position starting point','MarkerSize',10)
    plot(elapsedTime(posEnd+timeDelayFromOriginalPos),posDataSet.yPos(posEnd+timeDelayFromOriginalPos),'bo','DisplayName','Position ending point','MarkerSize',10)
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    ylabel("Position [ m ]")
    title("Original signal")
    legend('show','Location','eastoutside')
    hold off

    subplot(2,1,2), hold on, grid on
    plot(cuttedElapsedTime,cuttedPosDataSet,'k-','DisplayName', 'y position_{cutted}')
    plot(cuttedElapsedTime,cuttedAverageBehavior,'b--','DisplayName','Average behavior')
    plot(maxLocalization,maxPeaksVal,'ro','DisplayName','Maximums')
    plot(minLocalization,minPeaksVal,'go','DisplayName','Minimums')
    yline(upperPeaksBound,'r--','DisplayName','Higher bound')
    yline(lowerPeaksBound,'g--','DisplayName','Lower bound')
    title("Cutted signal starting and ending points")
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    ylabel("Position [ m ]")
    legend('show','Location','eastoutside')
    hold off
    sgtitle(defaultTitleName)
    
    % Figure saving for position
    if IMAGE_SAVING
        mkdir ProcessedData\PositionVisualizing;
        path = strjoin(["ProcessedData\PositionVisualizing\P",num2str(numPerson),".png"],"");
        exportgraphics(fig1,path)
        mkdir ProcessedData\PositionProcessing;
        path = strjoin(["ProcessedData\PositionProcessing\P",num2str(numPerson),".png"],"");
        exportgraphics(fig2,path)
    end
    
    %% FORCE ANALYSIS
    % Interpolating the force data, 
    % Notice that the force only need to find the initial point, the last will
    % be the same of the position
    forceElapsedTime = minutesDataPointsConverter(forceDataSet);
    
    % Plot results
    fig3 = figure('Name','Force synchronization');
    fig3.WindowState = 'maximized';
    subplot(3,1,1), grid on, hold on
    plot(forceElapsedTime,forceDataSet.Fy,'k-')
    title("Original force")
    hold off
    
    %% Low pass filter
    % Removing noise in the force signal implies the use of a lowpass filter,
    % which introduce a phase shift to the signal. In order to avoid this
    % shift, a chebyshev filter is designed, and then its coefficient are
    % re-elaborated in order to remove the shift using a zero phase digital
    % filter funct (filtfilt())
    fc = 5;
    gain = 1;
    
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Plot the filter properties
%     fvtool(sos,'Fs',fs)
    % Remove the pahse shifting and compute the output
    filteredForce = filtfilt(sos,gain,forceDataSet.Fy);
    
    
    % Use the following just for debugging using break points after the end
    if DEBUG
        % Design of a classic chebyshev filter of third order, in order to
        % compare its output with the zero phase one.
        [b,a] = cheby1(3,gain,fc/(frequency/2));
        % Plot the filter properties
%         freqz(b,a,[],fs);
        % Evaluate the filtered output
        Y = filter(b,a,forceDataSet.Fy);
        
        % Plot comparison results
        subplot(3,1,2), hold on, grid on
        plot(forceElapsedTime,forceDataSet.Fy,'k-','DisplayName','Original force')
        plot(forceElapsedTime,Y,'b-','DisplayName','Filtered chebyshev')
        plot(forceElapsedTime,filteredForce,'g-','DisplayName','Filtered zero phase')
        xlabel("Elapsed time [ f_s = 100 Hz ]")
        ylabel("Force [ N ]")
        title("Filtered force")
        legend('show','Location','eastoutside')
        hold off
    end
    
    % Save the evaluated filtered signal into the older container, in order to
    % mantain time stamp data and other properties of the signal
    forceDataSet.Fy = filteredForce;
    
    %% Synchronizing force signal with position
    % Find the initial delay between the two sampled signals
    initialTimeDelay = posDataSet.Time(1)-forceDataSet.Time(1);
    
    if initialTimeDelay >= 0
        % If the force has more samples than position, than it has smaller starting time,
        % and a positive difference with the position one, so it needs to be back-shifted
        synchForceDataSet = forceDataSet(forceDataSet.Time>=posDataSet.Time(1),:);
        synchForceElapsedTime = minutesDataPointsConverter(synchForceDataSet);
    else
        % The opposite situation, so it will be forward-shifted using some zeros
        synchForceDataSet = [sum(forceDataSet.Time(1)<=posDataSet.Time);forceDataSet];
        synchForceElapsedTime = minutesDataPointsConverter(synchForceDataSet);
    end
    
    % Now the force has to be interpolated in the position time stamp in order
    % to set the same start and stop point
    FySynchForceDataSet = interp1(1:height(synchForceDataSet),synchForceDataSet.Fy,1:height(posDataSet));
    
    % Plot results
    subplot(3,1,2), grid on, hold on
    plot(elapsedTime,FySynchForceDataSet,'DisplayName','Filtered force')
    plot(elapsedTime(posStart),FySynchForceDataSet(posStart),'ro','DisplayName','Starting point')
    plot(elapsedTime(posEnd),FySynchForceDataSet(posEnd),'bo','DisplayName','Ending point')
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    ylabel("Force [ N ]")
    title("Definition of starting and ending points")
    legend('show','Location','eastoutside')
    hold off
    
    %% Remove greetings and closing and taking only Fy as interesting data
    cuttedSynchForceDataSet = FySynchForceDataSet(posStart:posEnd);
    
    %% Finding min e MAX peaks of the force
    maximumMovementTime = 0.1;
    [envHigh, envLow] = envelope(cuttedSynchForceDataSet,maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    upperPeaksBound = mean(maxPeaksVal);
    lowerPeaksBound = mean(minPeaksVal);
    maxLocalization = maxLocalization*10e-5;
    minLocalization = minLocalization*10e-5;
    
    highestValue = max(cuttedSynchForceDataSet); 
    lowestValue = min(cuttedSynchForceDataSet);
    
    % Plot results
    subplot(3,1,3), grid on, hold on
    plot(cuttedElapsedTime,cuttedSynchForceDataSet,'k-','DisplayName','Synched force')
    plot(cuttedElapsedTime,averageEnv,'r--','DisplayName','Average behavior')
    plot(maxLocalization,maxPeaksVal,'go',minLocalization,minPeaksVal,'go')
    yline(upperPeaksBound,'k--','Higher bound')
    yline(lowerPeaksBound,'k--','Lower bound')
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    ylabel("Force [ N ]")
    ylim([lowestValue,highestValue])
    title("Final processed force signal")
    legend("Synched force", "Average behavior",'Location','eastoutside')
    hold off
    sgtitle(defaultTitleName)
    
    %% Phase number evaluation
    posUpperPhase = length(maxPeaksVal);
    posLowerPhase = length(minPeaksVal);
    
    if DEBUG
        fprintf("\nFirst registered force peaks:\n")
        fprintf("\t- N. MAX: %d\n",posUpperPhase)
        fprintf("\t- N. min: %d\n",posLowerPhase)
    end
    
    % The resulting peaks are around the double of the expected ones, this
    % because each moving phase finds at least a first higher force peaks, and
    % then a lower one. This is a recursive behavior which has to be analyzed
    % further on.
    % So to count the correct number of phases another envelop is done,
    % rounding each phase to almost a single peak.
    maximumMovementTime = 1;
    [envHigh, envLow] = envelope(cuttedSynchForceDataSet,maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    maxLocalization = maxLocalization*10e-5;
    minLocalization = minLocalization*10e-5;
    posUpperPhase = length(maxPeaksVal);
    posLowerPhase = length(minPeaksVal);
    
    % Use the following just for debugging using break points after the end
    if DEBUG
        fprintf("\nRe-processed force peaks:\n")
        fprintf("\t- N. MAX: %d\n",posUpperPhase)
        fprintf("\t- N. min: %d\n",posLowerPhase)
    
        figure, hold on, grid on
        plot(cuttedElapsedTime,cuttedSynchForceDataSet,'DisplayName','Synched force')
        plot(cuttedElapsedTime,averageEnv,'r--','DisplayName','Average behavior')
        plot(maxLocalization,maxPeaksVal,'go',minLocalization,minPeaksVal,'go')
        yline(upperPeaksBound,'k--','Higher bound')
        yline(lowerPeaksBound,'k--','Lower bound')
        xlabel("Elapsed time [ f_s = 100 Hz ]")
        ylabel("Force [ N ]")
        ylim([lowestValue,highestValue])
        title("Phase number determination")
        legend("Synched force", "Average behavior",'Location','eastoutside')
        hold off
    end
    
    % Figure saving for force
    if IMAGE_SAVING
        mkdir ProcessedData\ForceSynchronization;
        path = strjoin(["ProcessedData\ForceSynchronization\P",num2str(numPerson),".png"],"");
        exportgraphics(fig3,path)
    end
    
    %% Ultimate synched data set saving
    ultimateSynchPosDataSet = [cuttedElapsedTime',cuttedPosDataSet];
    ultimateSynchForceDataSet = [cuttedElapsedTime',cuttedSynchForceDataSet'];

    %% Force pause for online evaluation
    if sum(find(pausePeople == numPerson)) > 0
        % If a person number is found in the pausePeople array, the pause.
        fprintf("\nPause requested, press enter on the command window to continue...\n")
        pause;
    end

    %% Closing all the saved figures
    if  IMAGE_SAVING
        close(fig1);
        close(fig2);
        close(fig3); 
    end
end
