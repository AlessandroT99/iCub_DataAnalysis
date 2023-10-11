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

function [nDX, nSX, nM, nF, plotPosM, plotPosF] = parametersUpdate(dataSet)
% This function is used in order to update the total number of person that
% holds the listed parameters:
% - DX arm used
% - SX arm used
% - Male
% - Female

    % Notice that the parameters are taken for the robot side, so the arm will
    % be changed with the opposite
    
    nDX = 0;                    % Number of uses of robot DX hand
    nSX = 0;                    % Number of uses of robot SX hand
    nM = 0;                     % Number of males which took the test
    nF = 0;                     % Number of females which took the test
    plotPosM = [];              % Position in the subplot of the males test
    plotPosF = [];              % Position in the subplot of the females test
    nMDX = 0;                   % Number of DX males which took the test
    nMSX = 0;                   % Number of SX males which took the test 
    nFDX = 0;                   % Number of DX females which took the test
    nFSX = 0;                   % Number of SX females which took the test
    even = 2:2:height(dataSet); % Array containing even numbers
    odds = 1:2:height(dataSet); % Array containing odd numbers
    
    for numPerson = 1:height(dataSet)
         % Exclude people who are not valid as dataSet
        if strcmp(dataSet.Note(numPerson),"No video") == 0 && ...
            strcmp(dataSet.Note(numPerson),"Video incompleto") == 0
            
            if strcmp(dataSet.Mano(numPerson),"DX") == 1
                nSX = nSX + 1;
                if strcmp(dataSet.Genere(numPerson),"M") == 1
                    nM = nM + 1;
                    nMDX = nMDX + 1;
                    plotPosM = [plotPosM, even(nMDX)];
                else
                    nF = nF + 1;
                    nFDX = nFDX + 1;
                    plotPosF = [plotPosF, even(nFDX)];
                end
    
            else
                nDX = nDX + 1;
                if strcmp(dataSet.Genere(numPerson),"M") == 1
                    nM = nM + 1;
                    nMSX = nMSX + 1;
                    plotPosM = [plotPosM, odds(nMSX)];
                else
                    nF = nF + 1;
                    nFSX = nFSX + 1;
                    plotPosF = [plotPosF, odds(nFSX)];
                end
            end
            
        end
    end

end