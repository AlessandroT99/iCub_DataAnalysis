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

function cuttedSynchWrenchDataSet = wrenchForceReader(numPerson, initialPosDataSet, posStart, posEnd, handInvolved, BaselineFilesParameters)
% Function used to read and sinch the data from the /wholeBodyDynamics/involved_arm/cartesianEndEffectorWrench:o
    tic
    fprintf("\n         .Force transformation error evaluation...")
    if numPerson == -2
        wrenchDataSet = readtable(strjoin([BaselineFilesParameters(4),"\wrench\leftArm\",BaselineFilesParameters(1),"\data.log"],""));
    else 
        if numPerson == -1
            wrenchDataSet = readtable(strjoin([BaselineFilesParameters(4),"\wrench\rightArm\",BaselineFilesParameters(2),"\data.log"],""));
        else
            if strcmp(handInvolved,"DX") == 1
                if numPerson < 10
                    wrenchDataSet = strjoin(["..\InputData\wrench\leftArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    wrenchDataSet = strjoin(["..\InputData\wrench\leftArm\P_000",num2str(numPerson),"\data.log"],'');
                end
            else
                if numPerson < 10
                    wrenchDataSet = strjoin(["..\InputData\wrench\rightArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    wrenchDataSet = strjoin(["..\InputData\wrench\rightArm\P_000",num2str(numPerson),"\data.log"],'');
                end
            end
        end
    end

    wrenchDataSet = renamevars(wrenchDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                             ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
    
    %% Synchronizing wrench forces signal with position
    % Find the initial delay between the two sampled signals
    initialTimeDelay = initialPosDataSet.Time(1)-wrenchDataSet.Time(1);
    
    if initialTimeDelay >= 0
        % If the wrench forces have more samples than position, than it has smaller starting time,
        % and a positive difference with the position one, so it needs to be back-shifted
        synchWrenchDataSet = wrenchDataSet(wrenchDataSet.Time>=initialPosDataSet.Time(1),:);
    else
        % The opposite situation, so it will be forward-shifted using some zeros
        zeroMatrix = array2table(zeros(sum(wrenchDataSet.Time(1)>initialPosDataSet.Time),size(wrenchDataSet,2)));
        zeroMatrix = renamevars(zeroMatrix,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                            ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
        synchWrenchDataSet = [zeroMatrix;wrenchDataSet];
    end
    
    tmpCuttedSynchWrenchDataSet = zeros(posEnd-posStart+1,8);
    for j = 2:9
        % Now the wrench forces have to be interpolated in the position time stamp in order
        % to set the same start and stop point
        tmpSynchWrenchDataSet = interp1(1:height(synchWrenchDataSet),table2array(synchWrenchDataSet(:,j)),1:height(initialPosDataSet));
        % Remove greetings and closing
        tmpCuttedSynchWrenchDataSet(:,j-1) = tmpSynchWrenchDataSet(posStart:posEnd)';
    end
    cuttedSynchWrenchDataSet = array2table(tmpCuttedSynchWrenchDataSet);
    cuttedSynchWrenchDataSet = renamevars(cuttedSynchWrenchDataSet,1:width(cuttedSynchWrenchDataSet),["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
    cuttedElapsedTime = minutesDataPointsConverter(cuttedSynchWrenchDataSet)';
end
