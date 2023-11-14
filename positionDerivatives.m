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

function positionDerivatives(cuttedPosDataSet, numPerson, defaultTitleName, BaselineFilesParameters)
    
    maximumMovementTime = 0.1;
    frequency = 100;

    %% Velocity evaluation
    velocity = zeros(1,length(cuttedPosDataSet)-1);
    for i = 2:length(cuttedPosDataSet)
        velocity(i) = (cuttedPosDataSet(i)-cuttedPosDataSet(i-1))/10e-5;
    end
    [envHigh, envLow] = envelope(posDataSet.yPos,maximumMovementTime*frequency*0.8,'peak');
    velocityAverageEnv = (envLow+envHigh)/2;
    [velMaxPeaksVal, velMaxLocalization] = findpeaks(velocityAverageEnv,'MinPeakHeight',mean(velocityAverageEnv));
    [velMinPeaksVal, velMinLocalization] = findpeaks(-velocityAverageEnv,'MinPeakHeight',-mean(velocityAverageEnv));
    velMinPeaksVal = -velMinPeaksVal;
    [velMinPeaksVal,velMinLocalization,velMaxPeaksVal,velMaxLocalization] = maxMinCleaning(velMinPeaksVal,velMinLocalization,velMaxPeaksVal,velMaxLocalization);

    %% Acceleration evaluation
    acceleration = zeros(1,length(velocity)-1);
    for i = 2:length(velocity)
        acceleration(i) = (velocity(i)-velocity(i-1))/10e-5;
    end
    [envHigh, envLow] = envelope(posDataSet.yPos,maximumMovementTime*frequency*0.8,'peak');
    accelerationAverageEnv = (envLow+envHigh)/2;
    [accMaxPeaksVal, accMaxLocalization] = findpeaks(accelerationAverageEnv,'MinPeakHeight',mean(accelerationAverageEnv));
    [accMinPeaksVal, accMinLocalization] = findpeaks(-accelerationAverageEnv,'MinPeakHeight',-mean(accelerationAverageEnv));
    accMinPeaksVal = -accMinPeaksVal;
    [accMinPeaksVal,accMinLocalization,accMaxPeaksVal,accMaxLocalization] = maxMinCleaning(accMinPeaksVal,accMinLocalization,accMaxPeaksVal,accMaxLocalization);

end