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

function [nR, nL, nM, nF, plotPosM, plotPosF, personWhoFeelsFollowerOrLeader] = parametersUpdate(dataSet)
% This function is used in order to update the total number of person that
% holds the listed parameters:
% - R arm used
% - L arm used
% - Male
% - Female

    % Notice that the parameters are taken for the robot side, so the arm will
    % be changed with the opposite
    
    nR = 0;                    % Number of uses of robot R hand
    nL = 0;                    % Number of uses of robot L hand
    nM = 0;                     % Number of males which took the test
    nF = 0;                     % Number of females which took the test
    plotPosM = [];              % Position in the subplot of the males test
    plotPosF = [];              % Position in the subplot of the females test
    nMR = 0;                   % Number of R males which took the test
    nML = 0;                   % Number of L males which took the test 
    nFR = 0;                   % Number of R females which took the test
    nFL = 0;                   % Number of L females which took the test
    even = 2:2:3*height(dataSet); % Array containing even numbers
    odds = 1:2:3*height(dataSet); % Array containing odd numbers
    
    
    for numPerson = 1:height(dataSet)
         % Exclude people who are not valid as dataSet
        if strcmp(dataSet.Note(numPerson),"No video") == 0 && ...
            strcmp(dataSet.Note(numPerson),"Video incompleto") == 0
            
            if strcmp(dataSet.Mano(numPerson),"R") == 1
                nL = nL + 1;
                if strcmp(dataSet.Genere(numPerson),"M") == 1
                    nM = nM + 1;
                    nMR = nMR + 1;
                    plotPosM = [plotPosM, even(nMR)];
                else
                    nF = nF + 1;
                    nFR = nFR + 1;
                    plotPosF = [plotPosF, even(nFR)];
                end
    
            else
                nR = nR + 1;
                if strcmp(dataSet.Genere(numPerson),"M") == 1
                    nM = nM + 1;
                    nML = nML + 1;
                    plotPosM = [plotPosM, odds(nML)];
                else
                    nF = nF + 1;
                    nFL = nFL + 1;
                    plotPosF = [plotPosF, odds(nFL)];
                end
            end
           
            if dataSet.Lead_Fol(numPerson) >= 5
                personWhoFeelsFollowerOrLeader(numPerson) = 1;
            else
                if dataSet.Lead_Fol(numPerson) <= 3
                    personWhoFeelsFollowerOrLeader(numPerson) = -1;
                else
                    personWhoFeelsFollowerOrLeader(numPerson) = 2;
                end
            end
        end
    end
    personWhoFeelsFollowerOrLeader = personWhoFeelsFollowerOrLeader(personWhoFeelsFollowerOrLeader~=0);
    personWhoFeelsFollowerOrLeader(personWhoFeelsFollowerOrLeader==2) = zeros(1,sum(personWhoFeelsFollowerOrLeader==2));
end