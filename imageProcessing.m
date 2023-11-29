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
format compact

% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');
% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

dataset = readtable("../InputData/imageProcessing/SingleExperimentData/Test1_ImageProcessingData");
dataset = dataset(200:8140,:);
totalLength = [mean(dataset.totalLength),std(dataset.totalLength)];

figure, grid on, hold on
plot(dataset.totalLength)
title("Wire total length")

figure
subplot(2,1,1), grid on, hold on
plot(dataset.leftLength)
title("Wire length human side")
hold off
subplot(2,1,2), grid on, hold on
plot(dataset.rightLength)
title("Wire length robot side")
hold off

figure
subplot(2,1,1), grid on, hold on
plot(dataset.leftAngle)
title("Wire angle human side")
hold off
subplot(2,1,2), grid on, hold on
plot(dataset.rightAngle)
title("Wire angle robot side")
hold off