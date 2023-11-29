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

function [ultimateSynchPosDataSet, ultimateSynchForceDataSet, newBaselineBoundaries, midVelocityMean, midVelocityStd] = ...
    synchSignalsData(robot, aik, opts, posDataSet, forceDataSet, numPerson, personParameters, pausePeople, baselineBoundaries, BaselineFilesParameters)
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

    %% Parameters for the simulation 
    DEBUG = 0;                              % Debug binary variable, use it =1 to unlock some parts of the code, normally unusefull
    IMAGE_SAVING = 1;                       % Put to 1 in order to save the main plots
    PAUSE_TIME = 2;                         % Used to let the window of the plot get the full resolution size before saving
    FORCE_TRANSFORMATION_EVALUATION = 1;    % Goes to 0 if the force transformation has to be skipped
    PLOT_TRAJECTORIES = 1;                  % If equal to 0 does not plot hand trajectories
    axisYLimMultiplier = 1.5;               % Multiplies the chosen y limits for axis plotting
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParameters],"");
    
    if IMAGE_SAVING
        mkdir ..\ProcessedData;
    end

    tic
    fprintf("   .Computing position cutting...")

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
    xlabel("Elapsed time [ min ]")
    ylabel("Position [ m ]")
    title("Original signal")
    legend('show','Location','eastoutside')
    hold off
    
    % The signal derivative is evaluated
    posDerivative = zeros(1,length(firstAverageEnv)-1);
    for i = 2:length(firstAverageEnv)
        posDerivative(i) = (firstAverageEnv(i)-firstAverageEnv(i-1))/(0.01/60);
    end
    
    % Plot results
    fig2 = figure('Name','Position processing through derivative and filtering');
    fig2.WindowState = 'maximized';
    subplot(4,1,1), hold on, grid on
    plot(elapsedTime,posDerivative)
    title("Derivative of the original signal")
    xlabel("Elapsed time [ min ]")
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
    xlabel("Elapsed time [ min ]")
    hold off
    
    %% Identification of starting
    % Average slope of the position signal in the first robot phase
    stdRequired = 0.9; % Estimated graphycally looking at the plots into \ProcessedData\PositionDerivativeSTD
    subSetDimension = 25;

    findedFlag = 0;
    % This flag let find just one time the start position but let
    % evaluating the slope for the whole signal
    
    for i = subSetDimension+1:subSetDimension:length(firstAverageEnv)
        posStd(i) = std(filteredPosDerivative(i-subSetDimension:i));
        if (posStd(i) > stdRequired && findedFlag == 0)
            derivativePosStart = i-25;
            findedFlag = 1;
        end
    end

    %% Identification of ending point
    % Finally the ending point is firstly found only adding the experiment time
    % but knowing that the conclusion include a rotation of the chest during
    % the last robot phase, we need to esclude that last part of the signal.
    initialPosEnd = derivativePosStart+experimentDuration;
    if initialPosEnd > length(filteredPosDerivative)
        initialPosEnd = length(filteredPosDerivative);
    end
    cuttedFilteredPosDerivative = filteredPosDerivative(derivativePosStart:initialPosEnd);
    
    % So the peaks of the experiment time derivative are evaluated and the
    % mean of them is calculated
    [maxPeaksVal, ~] = findpeaks(cuttedFilteredPosDerivative);
    [minPeaksVal, ~] = findpeaks(-cuttedFilteredPosDerivative);
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

    %% Check for incorrect lenght of the experiment
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
        [maxPeaksVal, ~] = findpeaks(cuttedFilteredPosDerivative);
        [minPeaksVal, ~] = findpeaks(-cuttedFilteredPosDerivative);
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
    
    % Resizing also minimum and maximum values
    maxLocalization = (maxLocalization)/(100*60);
    maxLocalization = maxLocalization(maxLocalization>0);
    maxPeaksVal = maxPeaksVal(end-length(maxLocalization)+1:end);
    maxLocalization = maxLocalization(maxLocalization<=length(derivativeCuttedElapsedTime));
    maxPeaksVal = maxPeaksVal(1:length(maxLocalization));

    minLocalization = (minLocalization)/(100*60);
    minLocalization = minLocalization(minLocalization>0);
    minPeaksVal = minPeaksVal(end-length(minLocalization)+1:end);
    minLocalization = minLocalization(minLocalization<=length(derivativeCuttedElapsedTime));
    minPeaksVal = minPeaksVal(1:length(minLocalization));
    
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
    xlabel("Elapsed time [ min ]")
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
    xlabel("Elapsed time [ min ]")
    title("Final derivative graph")
    legend('show','Location','eastoutside')
    hold off
    sgtitle(defaultTitleName)

    %% Adjust starting and ending position
    % In order to cut data which are not complete, the starting and ending
    % position are shifted to the nearest peak, in the just cutted signal.
    cutPosAverage = firstAverageEnv(derivativePosStart:derivativePosEnd);
    firstCutPosDataSet = posDataSet(derivativePosStart:derivativePosEnd,:);
    [maxPeaksVal, maxLocalization] = findpeaks(cutPosAverage,'MinPeakHeight',mean(cutPosAverage));
    [minPeaksVal, minLocalization] = findpeaks(-cutPosAverage,'MinPeakHeight',-mean(cutPosAverage));
    minPeaksVal = -minPeaksVal;
    upperPeaksBound = mean(maxPeaksVal);
    lowerPeaksBound = mean(minPeaksVal);

    % Cleaning the peaks from doubles
    [minPeaksVal,minLocalization,maxPeaksVal,maxLocalization] = maxMinCleaning(minPeaksVal,minLocalization,maxPeaksVal,maxLocalization);

    posStart = min(minLocalization(1),maxLocalization(1));
    posEnd = max(minLocalization(end),maxLocalization(end));


    cuttedPosDataSet = firstCutPosDataSet(posStart:posEnd,:);
    cuttedElapsedTime = elapsedTime(posStart:posEnd)-elapsedTime(posStart);
    cuttedAverageBehavior = cutPosAverage(posStart:posEnd);

    % Resizing minimum and maximum values
    maxLocalization = (maxLocalization-posStart)/(100*60);
    maxLocalization = maxLocalization(maxLocalization>0);
    maxPeaksVal = maxPeaksVal(end-length(maxLocalization)+1:end);
    maxLocalization = maxLocalization(maxLocalization<=length(cuttedElapsedTime));
    maxPeaksVal = maxPeaksVal(1:length(maxLocalization));

    minLocalization = (minLocalization-posStart)/(100*60);
    minLocalization = minLocalization(minLocalization>0);
    minPeaksVal = minPeaksVal(end-length(minLocalization)+1:end);
    minLocalization = minLocalization(minLocalization<=length(cuttedElapsedTime));
    minPeaksVal = minPeaksVal(1:length(minLocalization));

    timeDelayFromOriginalPos = derivativePosStart;
    
    %% Phases number evaluation
    posUpperPhase = length(maxPeaksVal);
    posLowerPhase = length(minPeaksVal);
    
    if DEBUG
        fprintf("\nPosition peaks:\n")
        fprintf("\t- N. MAX: %d\n",posUpperPhase)
        fprintf("\t- N. min: %d\n",posLowerPhase)
    end

    %% Robot hand trajectory plotting
    if PLOT_TRAJECTORIES
        fig3DTraj = figure('Name', 'Hand trajectory');
        fig3DTraj.WindowState = 'maximized';
        grid on, hold on
        plot3(cuttedPosDataSet.xPos,cuttedPosDataSet.yPos,cuttedPosDataSet.zPos,'k-')
        plot3(cuttedPosDataSet.xPos(1),cuttedPosDataSet.yPos(1),cuttedPosDataSet.zPos(1),'go','MarkerFaceColor','g')
        plot3(cuttedPosDataSet.xPos(end),cuttedPosDataSet.yPos(end),cuttedPosDataSet.zPos(end),'ro','MarkerFaceColor','r')
        title('Hand Trajectory',defaultTitleName)
        legend("Signal","Start point","End point",'Location','eastoutside')
    
        fig2DTraj = figure('Name', 'Hand trajectory');
        fig2DTraj.WindowState = 'maximized';
        subplot(1,3,1), grid on, hold on
        plot(cuttedPosDataSet.xPos.*100,cuttedPosDataSet.yPos.*100,'k-')
        plot(cuttedPosDataSet.xPos(1).*100,cuttedPosDataSet.yPos(1).*100,'go','MarkerFaceColor','g')
        plot(cuttedPosDataSet.xPos(end).*100,cuttedPosDataSet.yPos(end).*100,'ro','MarkerFaceColor','r')
        ylabel("Y position [ cm ]"), xlabel("X position [ cm ]")
        title('Hand Trajectory - Plane XY')
        legend("Signal","Start point","End point",'Location','southoutside')
    
        subplot(1,3,2), grid on, hold on
        plot(cuttedPosDataSet.xPos.*100,cuttedPosDataSet.zPos.*100,'k-')
        plot(cuttedPosDataSet.xPos(1).*100,cuttedPosDataSet.zPos(1).*100,'go','MarkerFaceColor','g')
        plot(cuttedPosDataSet.xPos(end).*100,cuttedPosDataSet.zPos(end).*100,'ro','MarkerFaceColor','r')
        ylabel("Z position [ cm ]"), xlabel("X position [ cm ]")
        title('Hand Trajectory - Plane XZ')
        legend("Signal","Start point","End point",'Location','southoutside')
    
        subplot(1,3,3), grid on, hold on
        plot(cuttedPosDataSet.yPos.*100,cuttedPosDataSet.zPos.*100,'k-')
        plot(cuttedPosDataSet.yPos(1).*100,cuttedPosDataSet.zPos(1).*100,'go','MarkerFaceColor','g')
        plot(cuttedPosDataSet.yPos(end).*100,cuttedPosDataSet.zPos(end).*100,'ro','MarkerFaceColor','r')
        ylabel("Z position [ cm ]"), xlabel("Y position [ cm ]")
        title('Hand Trajectory - Plane YZ')
        legend("Signal","Start point","End point",'Location','southoutside')
        
        sgtitle(defaultTitleName)
    
        if IMAGE_SAVING
            mkdir ..\ProcessedData\HandTrajectory;
            if numPerson < 0
                path = strjoin(["..\ProcessedData\HandTrajectory\",BaselineFilesParameters(3),".png"],"");
                path2 = strjoin(["..\ProcessedData\HandTrajectory\",BaselineFilesParameters(3),"_3D.fig"],"");
            else
                path = strjoin(["..\ProcessedData\HandTrajectory\P",num2str(numPerson),".png"],"");
                path2 = strjoin(["..\ProcessedData\HandTrajectory\3D_P",num2str(numPerson),".fig"],"");
            end
            pause(PAUSE_TIME);
            savefig(fig3DTraj,path2);
            exportgraphics(fig2DTraj,path)
            close(fig2DTraj);
            close(fig3DTraj);
        end
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
    xlabel("Elapsed time [ min ]")
    ylabel("Position [ m ]")
    title("Original signal")
    legend('show','Location','eastoutside')
    hold off

    subplot(2,1,2), hold on, grid on
    plot(cuttedElapsedTime,cuttedPosDataSet.yPos,'k-','DisplayName', 'y position_{cutted}')
    plot(cuttedElapsedTime,cuttedAverageBehavior,'b--','DisplayName','Average behavior')
    legendName = strjoin([num2str(posUpperPhase),"maximums"]);
    plot(maxLocalization,maxPeaksVal,'ro','DisplayName',legendName)
    legendName = strjoin([num2str(posLowerPhase),"minimums"]);
    plot(minLocalization,minPeaksVal,'go','DisplayName',legendName)
    yline(upperPeaksBound,'r--','DisplayName','Higher bound')
    yline(lowerPeaksBound,'g--','DisplayName','Lower bound')
    if numPerson > 0
        textPosX = cuttedElapsedTime(end)+0.1;
        if strcmp(personParameters(5),"R") == 1
            yline(baselineBoundaries(1,1),'k--','LineWidth',1.8,'DisplayName','Baseline upper boundary');
            yline(baselineBoundaries(2,1),'k--','LineWidth',1.8,'DisplayName','Baseline lower boundary');
            text(textPosX,baselineBoundaries(1,1),'Human Phase','FontSize',10, 'VerticalAlignment', 'middle','HorizontalAlignment','left')
            text(textPosX,baselineBoundaries(2,1),'Robot Phase','FontSize',10, 'VerticalAlignment', 'middle','HorizontalAlignment','left')
        else
            yline(baselineBoundaries(1,2),'k--','LineWidth',1.8,'DisplayName','Baseline upper boundary');
            yline(baselineBoundaries(2,2),'k--','LineWidth',1.8,'DisplayName','Baseline lower boundary');
            text(textPosX,baselineBoundaries(1,2),'Robot Phase','FontSize',10, 'VerticalAlignment', 'middle','HorizontalAlignment','left')
            text(textPosX,baselineBoundaries(2,2),'Human Phase','FontSize',10, 'VerticalAlignment', 'middle','HorizontalAlignment','left')
        end
    end
    title("Cutted signal starting and ending points")
    xlabel("Elapsed time [ min ]")
    ylabel("Position [ m ]")
    legend('show','Location','westoutside')
    hold off
    sgtitle(defaultTitleName)
    
    if numPerson < 0 
        newBaselineBoundaries = baselineBoundaries;
        newBaselineBoundaries(1,3+numPerson) = upperPeaksBound;
        newBaselineBoundaries(2,3+numPerson) = lowerPeaksBound;
    else
        newBaselineBoundaries = baselineBoundaries;
    end

    % Figure saving for position
    if IMAGE_SAVING
        mkdir ..\ProcessedData\PositionVisualizing;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\PositionVisualizing\",BaselineFilesParameters(3),".png"],"");
        else
            path = strjoin(["..\ProcessedData\PositionVisualizing\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path)

        mkdir ..\ProcessedData\PositionProcessing;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\PositionProcessing\",BaselineFilesParameters(3),".png"],"");
        else
            path = strjoin(["..\ProcessedData\PositionProcessing\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig2,path)
    end

    % Reference "tic" at the beginning in the "Parameters for the simulation" section 
    fprintf("                                  Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS')) 

    %% Evaluation of velocity and acceleration
    tic
    fprintf("   .Computing velocity and acceleration...")
    [midVelocityMean, midVelocityStd] = positionDerivatives(cuttedPosDataSet, maxLocalization, maxPeaksVal, minLocalization, minPeaksVal, cuttedElapsedTime, numPerson, defaultTitleName, BaselineFilesParameters);
    fprintf("                         Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
    %% Saving position data
    mkdir ..\ProcessedData\SynchedPositionData;
    if numPerson < 0
        path = strjoin(["..\ProcessedData\SynchedPositionData\",BaselineFilesParameters(3)],"");
    else
        path = strjoin(["..\ProcessedData\SynchedPositionData\P",num2str(numPerson)],"");
    end
    save(path,"cuttedPosDataSet","minLocalization","minPeaksVal","maxLocalization","maxPeaksVal","cuttedElapsedTime");

    %% FORCE ANALYSIS
    tic
    fprintf("   .Computing force signal cutting and synching...")

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
        xlabel("Elapsed time [ min ]")
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
    else
        % The opposite situation, so it will be forward-shifted using some zeros
        zeroMatrix = array2table(zeros(sum(forceDataSet.Time(1)>posDataSet.Time),size(forceDataSet,2)));
        zeroMatrix = renamevars(zeroMatrix,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                             ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
        synchForceDataSet = [zeroMatrix;forceDataSet];
    end
    
    forceStart = posStart+derivativePosStart;
    forceEnd = posEnd+derivativePosStart;

    % Now the force has to be interpolated in the position time stamp in order
    % to set the same start and stop point
    FxSynchForceDataSet = interp1(1:height(synchForceDataSet),synchForceDataSet.Fx,1:height(posDataSet));
    FySynchForceDataSet = interp1(1:height(synchForceDataSet),synchForceDataSet.Fy,1:height(posDataSet));
    FzSynchForceDataSet = interp1(1:height(synchForceDataSet),synchForceDataSet.Fz,1:height(posDataSet));


    % Plot results
    subplot(3,1,2), grid on, hold on
    plot(elapsedTime,FySynchForceDataSet,'DisplayName','Filtered force')
    plot(elapsedTime(forceStart),FySynchForceDataSet(forceStart),'ro','DisplayName','Starting point')
    plot(elapsedTime(forceEnd),FySynchForceDataSet(forceEnd),'bo','DisplayName','Ending point')
    xlabel("Elapsed time [ min ]")
    ylabel("Force [ N ]")
    title("Definition of starting and ending points")
    legend('show','Location','eastoutside')
    hold off
    
    %% Remove greetings and closing
    FxCuttedSynchForceDataSet = FxSynchForceDataSet(forceStart:forceEnd);
    FyCuttedSynchForceDataSet = FySynchForceDataSet(forceStart:forceEnd);
    FzCuttedSynchForceDataSet = FzSynchForceDataSet(forceStart:forceEnd);
    cuttedSynchForceDataSet = table(cuttedElapsedTime',FxCuttedSynchForceDataSet',FyCuttedSynchForceDataSet',FzCuttedSynchForceDataSet', ...
                                    'VariableNames',["Time","Fx","Fy","Fz"]);
    % Reference "tic" in the "Force analysis" section 
    fprintf("                 Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))

    %     save synchBaseLine;
    
    %% Force transformation
    if FORCE_TRANSFORMATION_EVALUATION
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ForceErrorTransformationData\",BaselineFilesParameters(3),".mat"],"");
        else
            path = strjoin(["..\ProcessedData\ForceErrorTransformationData\P",num2str(numPerson),".mat"],"");
        end
        if exist(path,'file')
            load(path);
        else
            % Has been evaluated that the force RS has to be rotated and translated
            % into the EF RS with respect to the OF
            forceTransformTime = tic;
            fprintf("   .Computing force transformation...")
            if numPerson < 0 % Up to know this procedure can only be done on the baselines
                [finalCuttedSynchForceDataSet, ~] = forceTransformation(robot, aik, opts, posDataSet, cuttedPosDataSet, ...
                    cuttedSynchForceDataSet, forceStart, forceEnd, personParameters, defaultTitleName, numPerson, BaselineFilesParameters);
            else
                finalCuttedSynchForceDataSet = cuttedSynchForceDataSet;
            end
            fprintf("\n       .Whole process completed in %s minutes\n",duration(0,0,toc(forceTransformTime),'Format','mm:ss.SS'))
        end
    else
        if numPerson < 0
            finalCuttedSynchForceDataSet = wrenchForceReader(numPerson, posDataSet, forceStart, forceEnd, personParameters(5),BaselineFilesParameters);
        else
            finalCuttedSynchForceDataSet = cuttedSynchForceDataSet;
        end
    end

    %% Finding min e MAX peaks of the force
    tic
    fprintf("   .Concluding computation of usefull parameters of the force...")
    
    maximumMovementTime = 0.1;
    [envHigh, envLow] = envelope(finalCuttedSynchForceDataSet.Fy,maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    upperPeaksBound = mean(maxPeaksVal);
    lowerPeaksBound = mean(minPeaksVal);
    
    % Resizing minimum and maximum values
    maxLocalization = (maxLocalization)/(100*60);
    minLocalization = (minLocalization)/(100*60);

    highestValue = max(finalCuttedSynchForceDataSet.Fy); 
    lowestValue = min(finalCuttedSynchForceDataSet.Fy);
    
    % Plot results
    figure(fig3);
    subplot(3,1,3), grid on, hold on
    plot(cuttedElapsedTime,finalCuttedSynchForceDataSet.Fy,'k-','DisplayName','Transformed synched force')
    plot(cuttedElapsedTime,averageEnv,'b--','DisplayName','Average behavior')
    plot(maxLocalization,maxPeaksVal,'ro','DisplayName','Maximums')
    plot(minLocalization,minPeaksVal,'go','DisplayName','Minimums')
    yline(upperPeaksBound,'r--','DisplayName','Higher bound')
    yline(lowerPeaksBound,'g--','DisplayName','Lower bound')
    xlabel("Elapsed time [ min ]")
    ylabel("Force [ N ]")
    ylim([lowestValue,highestValue])
    title("Final processed force signal")
    legend('show','Location','eastoutside')
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
    [envHigh, envLow] = envelope(finalCuttedSynchForceDataSet.Fy,maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;
    
    % Resizing minimum and maximum values
    maxLocalization = (maxLocalization)/(100*60);
    minLocalization = (minLocalization)/(100*60);

    posUpperPhase = length(maxPeaksVal);
    posLowerPhase = length(minPeaksVal);
    
    % Use the following just for debugging using break points after the end
    if DEBUG
        fprintf("\nRe-processed force peaks:\n")
        fprintf("\t- N. MAX: %d\n",posUpperPhase)
        fprintf("\t- N. min: %d\n",posLowerPhase)
    
        figure, hold on, grid on
        plot(cuttedElapsedTime,finalCuttedSynchForceDataSet.Fy,'DisplayName','Synched force')
        plot(cuttedElapsedTime,averageEnv,'r--','DisplayName','Average behavior')
        plot(cuttedElapsedTime(maxLocalization),maxPeaksVal,'go',cuttedElapsedTime(minLocalization),minPeaksVal,'go')
        yline(upperPeaksBound,'k--','Higher bound')
        yline(lowerPeaksBound,'k--','Lower bound')
        xlabel("Elapsed time [ min ]")
        ylabel("Force [ N ]")
        ylim([lowestValue,highestValue])
        title("Phase number determination")
        legend("Synched force", "Average behavior",'Location','eastoutside')
        hold off
    end
    
    % Figure saving for force
    if IMAGE_SAVING
        mkdir ..\ProcessedData\ForceSynchronization;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ForceSynchronization\",BaselineFilesParameters(3),".png"],"");
        else
            path = strjoin(["..\ProcessedData\ForceSynchronization\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig3,path)
    end

    % Reference "tic" at the beginning in the "Finding min e MAX peaks of the force" section 
    fprintf("   Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
    %% Ultimate synched data set saving
    ultimateSynchPosDataSet = [minutesDataPointsConverter(cuttedPosDataSet)',cuttedPosDataSet.yPos];
    ultimateSynchForceDataSet = [minutesDataPointsConverter(finalCuttedSynchForceDataSet)',finalCuttedSynchForceDataSet.Fy];

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
