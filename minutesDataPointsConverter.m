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

function [elapsedTime] = minutesDataPointsConverter(dataSet)
% Function used to evaluate the minutes of the signal involved in order to
% define correctly the x-axis

    totalSize = height(dataSet);
    secondsDuration = totalSize/100;
    minutesDuration = secondsDuration/60;
    elapsedTime = linspace(0,minutesDuration,totalSize);

end