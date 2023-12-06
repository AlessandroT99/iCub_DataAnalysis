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

function [posDataSet, forceDataSet] = fileReader(peopleDataSet, personSubSet)
% This is a function used to read the whole dataset of people who made the
% Posner paradigm experiment and choose the person data putting as
% "numSubSet" the ID of the person chosen.

% OUTPUT:   
% posDataSet = dataset of person numSubSet for posData
% forceDataSet = dataset of person numSubSet for forceDataSet

    % Exclude people who are not valid as dataSet
    if strcmp(peopleDataSet.Note(personSubSet),"No video") == 0 && ...
       strcmp(peopleDataSet.Note(personSubSet),"Video incompleto") == 0
        % Now chose the correct path to load data
        if strcmp(peopleDataSet.Mano(personSubSet),"R") == 1
            if personSubSet < 10
                posFilePath = join(["..\iCub_InputData\positions\leftHand\P_0000",num2str(personSubSet),"\data.log"],'');
                forceFilePath = join(["..\iCub_InputData\forces\leftArm\P_0000",num2str(personSubSet),"\data.log"],'');
            else
                posFilePath = join(["..\iCub_InputData\positions\leftHand\P_000",num2str(personSubSet),"\data.log"],'');
                forceFilePath = join(["..\iCub_InputData\forces\leftArm\P_000",num2str(personSubSet),"\data.log"],'');
            end
        else
            if personSubSet < 10
                posFilePath = join(["..\iCub_InputData\positions\rightHand\P_0000",num2str(personSubSet),"\data.log"],'');
                forceFilePath = join(["..\iCub_InputData\forces\rightArm\P_0000",num2str(personSubSet),"\data.log"],'');
            else
                posFilePath = join(["..\iCub_InputData\positions\rightHand\P_000",num2str(personSubSet),"\data.log"],'');
                forceFilePath = join(["..\iCub_InputData\forces\rightArm\P_000",num2str(personSubSet),"\data.log"],'');
            end
        end
    
        % Correct fie reading
        posDataSet = readtable(posFilePath);
        forceDataSet = readtable(forceFilePath);

        % Code use to identify the unusefull warning
%         [msg,warnID] = lastwarn
        
        % Rename the table columns
        posDataSet = renamevars(posDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9"], ...
                                           ["Counter","Time","xPos","yPos","zPos","ax","ay","az","theta"]);
        forceDataSet = renamevars(forceDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                               ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
    else
        % Output empty set to notify that the person involved data have
        % been discarded for the reasons in the notes
        posDataSet = [];
        forceDataSet = [];
    end
end
