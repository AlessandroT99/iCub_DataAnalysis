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

function [newMinPeaksVal,newMinLocalization,newMaxPeaksVal,newMaxLocalization] = maxMinCleaning(minPeaksVal,minLocalization,maxPeaksVal,maxLocalization)
% Function used to remove double peaks which can alterate results
    timeThreshold = 1.4*100; % Check that this has to be lower than the average phase duration for baselines
    for i = 1:length(minLocalization) - 1
        if i > length(minLocalization) - 1
            break;
        end
        if minLocalization(i+1) - minLocalization(i) < timeThreshold
            if minPeaksVal(i+1) < minPeaksVal(i)
                minLocalization(i) = [];
                minPeaksVal(i) = [];
            else
                minLocalization(i+1) = [];
                minPeaksVal(i+1) = [];
            end
            
            if i - 3 < 1
                i = 1;
            else
                i = i - 3;
            end
        end
    end
    for i = 1:length(maxLocalization) - 1
        if i > length(maxLocalization) - 1
            break;
        end
        if maxLocalization(i+1) - maxLocalization(i) < timeThreshold
            if maxPeaksVal(i+1) > maxPeaksVal(i)
                maxLocalization(i) = [];
                maxPeaksVal(i) = [];
            else
                maxLocalization(i+1) = [];
                maxPeaksVal(i+1) = [];
            end
            if i - 3 < 1
                i = 1;
            else
                i = i - 3;
            end
        end
    end

    newMinPeaksVal = minPeaksVal;
    newMinLocalization = minLocalization;
    newMaxPeaksVal = maxPeaksVal;
    newMaxLocalization = maxLocalization;
end