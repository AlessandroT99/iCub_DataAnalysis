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

function [midVelocityMean, midVelocityStd] = positionDerivatives(cuttedPosDataSet, posMaxLocalization, posMaxPeaksVal, posMinLocalization, posMinPeaksVal, cuttedElapsedTime, numPerson, defaultTitleName, BaselineFilesParameters)
    PAUSE_TIME = 2;
    frequency = 100;
    posDataSet = table2array(cuttedPosDataSet(:,4));
    TIME_CONVERSION_CONSTANT = 0.01;

    %% Plot position signal
    fig1 = figure('Name','Velocity and acceleration evaluation');
    fig1.WindowState = 'maximized';
    sgtitle(defaultTitleName)
    
    subplot(3,1,1), grid on, hold on
    plot(cuttedElapsedTime,posDataSet,'k-')
    plot(posMaxLocalization,posMaxPeaksVal,'ro')
    plot(posMinLocalization,posMinPeaksVal,'go')
    legend("Signal","Max","Min",'Location','eastoutside')
    title("Position Signal")
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Position [ m ]",'Interpreter','latex')
    hold off

    %% Velocity evaluation
    velocity = zeros(1,length(posDataSet)-1);
    for i = 2:length(posDataSet)
        velocity(i) = (posDataSet(i)-posDataSet(i-1))/TIME_CONVERSION_CONSTANT;
    end
    
    fc = 5;
    gain = 1;
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Remove the pahse shifting and compute the output
    filteredVelocity = filtfilt(sos,gain,velocity);

    [velMaxPeaksVal, ~] = findpeaks(filteredVelocity,'MinPeakHeight',mean(filteredVelocity));
    [velMinPeaksVal, ~] = findpeaks(-filteredVelocity,'MinPeakHeight',-mean(filteredVelocity));
    velMinPeaksVal = -velMinPeaksVal;
    averageMin = mean(velMinPeaksVal);
    averageMax = mean(velMaxPeaksVal);
    [pks1,locs1] = findpeaks(filteredVelocity, cuttedElapsedTime, 'MinPeakHeight',averageMin);
    [~,locs2] = findpeaks(filteredVelocity, cuttedElapsedTime, 'MinPeakHeight',averageMax);
    [~, ia] = setdiff(locs1, locs2, 'stable');
    midPeaks = [pks1(ia); locs1(ia)];
    p = polyfit(midPeaks(2,:),midPeaks(1,:),3);
    midPeaksTrend = polyval(p,cuttedElapsedTime);
    midVelocityMean = mean(midPeaksTrend);
    midVelocityStd = std(midPeaksTrend);

    % Plot results
    subplot(3,1,2), grid on, hold on
    plot(cuttedElapsedTime,filteredVelocity,'k-')
    yline(averageMin,'r--')
    yline(averageMax,'g--')
    plot(cuttedElapsedTime,midPeaksTrend,'r-')
    legend("Signal","Lower Bound","Upper Bound","Middle peaks Trend",'Location','eastoutside')
    title("Velocity Signal")
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Velocity [ $\frac{m}{s}$ ]",'Interpreter','latex')
    hold off

    %% Acceleration evaluation
    acceleration = zeros(1,length(filteredVelocity)-1);
    for i = 2:length(filteredVelocity)
        acceleration(i) = (filteredVelocity(i)-filteredVelocity(i-1))/TIME_CONVERSION_CONSTANT;
    end

    fc = 2;
    gain = 1;
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Remove the pahse shifting and compute the output
    filteredAcceleration = filtfilt(sos,gain,acceleration);

    % Plot results
    subplot(3,1,3), grid on, hold on
    plot(cuttedElapsedTime,filteredAcceleration,'k-')
    title("Acceleration Signal")
    legend("Signal",'Location','eastoutside')
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Acceleration [ $\frac{m}{s^2}$ ]",'Interpreter','latex')
    hold off

    %% Figure saving
    mkdir ..\iCub_ProcessedData\PositionDerivatives;
    if numPerson < 0
        splitted = strsplit(BaselineFilesParameters(3),'\');
        if length(splitted) > 1
            mkdir(strjoin(["..\iCub_ProcessedData\PositionDerivatives",splitted(1:end-1)],'\'));
        end
        path = strjoin(["..\iCub_ProcessedData\PositionDerivatives\",BaselineFilesParameters(3),".png"],"");
    else
        path = strjoin(["..\iCub_ProcessedData\PositionDerivatives\P",num2str(numPerson),".png"],"");
    end
    pause(PAUSE_TIME);
    exportgraphics(fig1,path)
    close(fig1);

end