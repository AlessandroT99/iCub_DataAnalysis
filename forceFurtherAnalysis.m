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

% TODO: 
% - Analisi picchi
% - Analisi trend media
% - Analisi trend ampiezza

function [meanTrend, upAmplitudeTrend, lowAmplitudeTrend] = forceFurtherAnalysis(synchForceDataSet,numPerson,personParam,baseline, BaselineFilesParameters)
    %% SIMULATION PARAMETERS
    frequency = 100;
    IMAGE_SAVING = 1;
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParam],"");
    PAUSE_TIME = 2;

    %% PEAKS ANALYSIS
    maximumMovementTime = 0.5;
    [envHigh, envLow] = envelope(synchForceDataSet.Fy,maximumMovementTime*frequency*0.8,'peak');
    averageEnv = (envLow+envHigh)/2;
    
    [maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
    [minPeaksVal, minLocalization] = findpeaks(-averageEnv);
    minPeaksVal = -minPeaksVal;

    %% AVERAGE TREND ANALYSIS
    meanTrend = behavior(synchForceDataSet);

    %% AMPLITUDE TREND ANALYSIS
    upAmplitudeTrend = behavior(envHigh);
    lowAmplitudeTrend = bahvior(envLow);

end

%% Function
function [signalBehavior] = behavior(signal)
   ORDER = 1;
   signalBehavior = zeros(1,100);
   for i = 0:99
        signalBehavior(i+1) = mean(signal(round(i*length(signal)/100)+1:round((i+1)*length(signal)/100))); 
   end
end