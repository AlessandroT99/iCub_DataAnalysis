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

clear all, close all, clc

%% Reading input data of the baseline experiment
posFilePath = "..\positions\leftHand\P\data.log";
forceFilePath = "..\forces\leftArm\P\data.log";

posDataSet = readtable(posFilePath);
forceDataSet = readtable(forceFilePath);

posDataSet = renamevars(posDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9"], ...
                                   ["Counter","Time","xPos","yPos","zPos","q1","q2","q3","q4"]);
forceDataSet = renamevars(forceDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                       ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);

%% A priori informations
experimentDuration = 24000;
frequency = 100;

%% Synchronization of the signals analysis
[synchPosDataSet, synchForceDataSet] = ...
          synchSignalsData(posDataSet, forceDataSet, 0, "BaseLine"); 

%% POSITION ANALYSIS
maximumMovementTime = 0.5;
[envHigh, envLow] = envelope(synchPosDataSet(:,2),maximumMovementTime*frequency*0.8,'peak');
averageEnv = (envLow+envHigh)/2;

[maxPeaksVal, maxLocalization] = findpeaks(averageEnv);
[minPeaksVal, minLocalization] = findpeaks(-averageEnv);
minPeaksVal = -minPeaksVal;
maxLocalization = maxLocalization*10e-5;
minLocalization = minLocalization*10e-5;
posUpperPhase = length(maxPeaksVal);
posLowerPhase = length(minPeaksVal);

figure, hold on, grid on
plot(synchPosDataSet(:,1),synchPosDataSet(:,2),'DisplayName','Synched position')
plot(synchPosDataSet(:,1),averageEnv,'r--','DisplayName','Average behavior')
plot(maxLocalization,maxPeaksVal,'go',minLocalization,minPeaksVal,'go')
yline(-0.24,'k--')
yline(-0.09,'k--')
xlabel("Elapsed time  [ f_s = 100 Hz ]")
ylabel("Position [ m ]")
title("BaseLine Test","SX HAND - Position phase number determination")
legend("Synched force", "Average behavior")
text(1,-0.25,'Robot Phase')
text(1,-0.08,'Human Phase')
ylim([-0.3,-0.05])
hold off

for i = 1:length(maxPeaksVal)
    HtoR(i) = minLocalization(i+1)-maxLocalization(i);
    RtoH(i) = maxLocalization(i)-minLocalization(i);
end

figure, hold on, grid on
plot(HtoR.*60,'r-','DisplayName','Human to Robot phase')
plot(RtoH.*60,'b-','DisplayName','Robot to Human phase')
title("Time length of phases")
xlabel("Phase number")
ylabel("Time [ s ]")
legend('show')
hold off