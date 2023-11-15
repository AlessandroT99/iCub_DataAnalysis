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

function positionDerivatives(cuttedPosDataSet, posMaxLocalization, posMaxPeaksVal, posMinLocalization, posMinPeaksVal, cuttedElapsedTime, numPerson, defaultTitleName, BaselineFilesParameters)
    
    PAUSE_TIME = 2;
    frequency = 100;
    posDataSet = table2array(cuttedPosDataSet(:,4));

    %% Plot position signal
    fig1 = figure('Name','Velocity and acceleration evaluation');
    fig1.WindowState = 'maximized';
    sgtitle(defaultTitleName)
    
    subplot(3,1,1), grid on, hold on
    plot(cuttedElapsedTime,posDataSet,'k-')
    plot(posMaxLocalization,posMaxPeaksVal,'ro')
    plot(posMinLocalization,posMinPeaksVal,'go')
    legend("Signal","Max peaks","Min peaks",'Location','eastoutside')
    title("Position Signal")
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Position [ m ]",'Interpreter','latex')
    hold off

    %% Velocity evaluation
    velocity = zeros(1,length(posDataSet)-1);
    for i = 2:length(posDataSet)
        velocity(i) = (posDataSet(i)-posDataSet(i-1))/(0.01/60);
    end
    
    fc = 5;
    gain = 1;
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Remove the pahse shifting and compute the output
    filteredVelocity = filtfilt(sos,gain,velocity);

    maximumMovementTime = 0.15;
    [envHigh, envLow] = envelope(filteredVelocity,maximumMovementTime*frequency*0.8,'peak');
    velocityAverageEnv = (envLow+envHigh)/2;
    [velMaxPeaksVal, velMaxLocalization] = findpeaks(velocityAverageEnv,'MinPeakHeight',mean(velocityAverageEnv));
    [velMinPeaksVal, velMinLocalization] = findpeaks(-velocityAverageEnv,'MinPeakHeight',-mean(velocityAverageEnv));
    velMinPeaksVal = -velMinPeaksVal;
    [velMinPeaksVal,velMinLocalization,velMaxPeaksVal,velMaxLocalization] = maxMinCleaning(velMinPeaksVal,velMinLocalization,velMaxPeaksVal,velMaxLocalization,0);

    % Resizing minimum and maximum values
    velMaxLocalization = (velMaxLocalization)/(100*60);
    velMinLocalization = (velMinLocalization)/(100*60);

    % Plot results
    subplot(3,1,2), grid on, hold on
    plot(cuttedElapsedTime,filteredVelocity,'k-')
    plot(velMaxLocalization,velMaxPeaksVal,'ro')
    plot(velMinLocalization,velMinPeaksVal,'go')
    legend("Signal","Max peaks","Min peaks",'Location','eastoutside')
    title("Velocity Signal")
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Velocity [ $\frac{m}{s}$ ]",'Interpreter','latex')
    hold off

    %% Acceleration evaluation
    acceleration = zeros(1,length(filteredVelocity)-1);
    for i = 2:length(filteredVelocity)
        acceleration(i) = (filteredVelocity(i)-filteredVelocity(i-1))/(0.01/60);
    end

    fc = 2;
    gain = 1;
    % Design of the chebyshev filter of third order
    [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
    % Groups the filter coefficients
    sos = ss2sos(a,b,c,d);
    % Remove the pahse shifting and compute the output
    filteredAcceleration = filtfilt(sos,gain,acceleration);

    maximumMovementTime = 0.1;
    [envHigh, envLow] = envelope(filteredAcceleration,maximumMovementTime*frequency*0.8,'peak');
    accelerationAverageEnv = (envLow+envHigh)/2;
    [accMaxPeaksVal, accMaxLocalization] = findpeaks(accelerationAverageEnv,'MinPeakHeight',mean(accelerationAverageEnv));
    [accMinPeaksVal, accMinLocalization] = findpeaks(-accelerationAverageEnv,'MinPeakHeight',-mean(accelerationAverageEnv));
    accMinPeaksVal = -accMinPeaksVal;
    [accMinPeaksVal,accMinLocalization,accMaxPeaksVal,accMaxLocalization] = maxMinCleaning(accMinPeaksVal,accMinLocalization,accMaxPeaksVal,accMaxLocalization);

    % Resizing minimum and maximum values
    accMaxLocalization = (accMaxLocalization)/(100*60);
    accMinLocalization = (accMinLocalization)/(100*60);

    % Plot results
    subplot(3,1,3), grid on, hold on
    plot(cuttedElapsedTime,filteredAcceleration,'k-')
    plot(accMaxLocalization,accMaxPeaksVal,'ro')
    plot(accMinLocalization,accMinPeaksVal,'go')
    legend("Signal","Max peaks","Min peaks",'Location','eastoutside')
    title("Acceleration Signal")
    xlabel("Time [ min ]",'Interpreter','latex'), ylabel("Acceleration [ $\frac{m}{s^2}$ ]",'Interpreter','latex')
    hold off

    %% Figure saving
    mkdir ..\ProcessedData\PositionDerivatives;
    if numPerson < 0
        path = strjoin(["..\ProcessedData\PositionDerivatives\",BaselineFilesParameters(3),num2str(3+numPerson),".png"],"");
    else
        path = strjoin(["..\ProcessedData\PositionDerivatives\P",num2str(numPerson),".png"],"");
    end
    pause(PAUSE_TIME);
    exportgraphics(fig1,path)
    close(fig1);

end