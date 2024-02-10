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

function [newMinPeaksVal,newMinLocalization,newMaxPeaksVal,newMaxLocalization] = maxMinCleaning(minPeaksVal,minLocalization,maxPeaksVal,maxLocalization,ITERATE)
% Function used to remove double peaks which can alterate results
    if nargin == 4
        ITERATE = 1;
    end
    numberOfBackIndx = 3;
    iterations = 0;
    processComplete = 0;
    timeThreshold = 2*100; % Check that this has to be lower than the average phase duration for baselines
    while abs(length(minLocalization)-length(maxLocalization)) > 1 || (length(minLocalization) >= 80 && length(maxLocalization) >= 80) || processComplete == 0
        processComplete = 1;

        cnt = 1;
        while cnt <= length(minLocalization) - 1
            if minLocalization(cnt+1) - minLocalization(cnt) < timeThreshold
                processComplete = 0;
                if minPeaksVal(cnt+1) < minPeaksVal(cnt)
                    minLocalization(cnt) = [];
                    minPeaksVal(cnt) = [];
                else
                    minLocalization(cnt+1) = [];
                    minPeaksVal(cnt+1) = [];
                end
                if cnt - numberOfBackIndx < 1
                    cnt = 1;
                else
                    cnt = cnt - numberOfBackIndx;
                end
            else
                cnt = cnt + 1;
            end
        end

        cnt = 1;
        while cnt <= length(maxLocalization) - 1
            if maxLocalization(cnt+1) - maxLocalization(cnt) < timeThreshold
                processComplete = 0;
                if maxPeaksVal(cnt+1) > maxPeaksVal(cnt)
                    maxLocalization(cnt) = [];
                    maxPeaksVal(cnt) = [];
                else
                    maxLocalization(cnt+1) = [];
                    maxPeaksVal(cnt+1) = [];
                end
                if cnt - numberOfBackIndx < 1
                    cnt = 1;
                else
                    cnt = cnt - numberOfBackIndx;
                end
            else
                cnt = cnt + 1;
            end
        end
        iterations = iterations + 1;
        if iterations > 10 && abs(length(minLocalization)-length(maxLocalization)) < 3
%             disp("Threshold of minimum reached, ending cleaning.")
            break;
        else 
            if iterations > 20 && ITERATE
                error("Error in maxMinCleaning.m - Peaks cleaning has not been successfull.");
            else
                % If ITERATE is = 0 we do not care of the error
                break;
            end
        end
    end

    newMinPeaksVal = minPeaksVal;
    newMinLocalization = minLocalization;
    newMaxPeaksVal = maxPeaksVal;
    newMaxLocalization = maxLocalization;
end