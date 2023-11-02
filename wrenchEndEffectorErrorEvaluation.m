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

function [phaseError, moduleError, transformationError] = wrenchEndEffectorErrorEvaluation(newCuttedSynchForceDataSet, handInvolved, numPerson, initialPosDataSet, posStart, posEnd, defaultTitleName)
% This function is used to check the error made from force transformation
% alghoritm making a comparison with the data dumped from the /wholeBodyDynamics/left_arm/cartesianEndEffectorWrench:o 
% port, which corresponds to the force correctly rotated into the desidered reference system
    IMAGE_SAVING = 1;        % Used to save some chosen plots
    PAUSE_TIME = 2;          % Used to let the window of the plot get the full resolution size before saving

    tic
    fprintf("\n         .Force transformation error evaluation...")
    if numPerson == -2
        wrenchDataSet = readtable("..\InputData\wrench\leftArm\P0_L_Base\data.log");
    else 
        if numPerson == -1
            wrenchDataSet = readtable("..\InputData\wrench\rightArm\P0_R_Base\data.log");
        else
            if strcmp(handInvolved,"DX") == 1
                if numPerson < 10
                    wrenchDataSet = join(["..\InputData\wrench\leftArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    wrenchDataSet = join(["..\InputData\wrench\leftArm\P_000",num2str(numPerson),"\data.log"],'');
                end
            else
                if personSubSet < 10
                    wrenchDataSet = join(["..\InputData\wrench\rightArm\P_0000",num2str(numPerson),"\data.log"],'');
                else
                    wrenchDataSet = join(["..\InputData\wrench\rightArm\P_000",num2str(numPerson),"\data.log"],'');
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

    transformationError = cuttedSynchWrenchDataSet.Fy - newCuttedSynchForceDataSet.Fy;
    fftIdeal = fft(cuttedSynchWrenchDataSet.Fy);
    fftReal = fft(newCuttedSynchForceDataSet.Fy);
    phaseError = phase(fftIdeal)-phase(fftReal);
    moduleError = abs(fftIdeal)-abs(fftReal);
    meanError = mean(transformationError);

    % Plot results
    fig1 = figure('Name','Force transformation error');
    fig1.WindowState = 'maximized';
    subplot(2,1,1), grid on, hold on
    plot(cuttedElapsedTime, cuttedSynchWrenchDataSet.Fy, 'r-', 'DisplayName','Wrench force')
    plot(cuttedElapsedTime, newCuttedSynchForceDataSet.Fy, 'k--', 'LineWidth', 1.2, 'DisplayName','Evaluated Force')
    title('Comparison between transformed forces')
    xlabel("Time [ min ]"), ylabel("Force [ N ]")
    legend('show', 'Location','eastoutside')
    hold off

    subplot(2,1,2), grid on, hold on
    plot(cuttedElapsedTime, transformationError, 'b-','DisplayName','Error evaluated')
    yline(meanError,'k--','LineWidth',2.2,'DisplayName','Mean Error')
    title('Error of the force calculation')
    xlabel("Time [ min ]"), ylabel("Force [ N ]")
    legend('show', 'Location','eastoutside')
    hold off

    sgtitle(defaultTitleName)

    if IMAGE_SAVING
        mkdir ..\ProcessedData\ForceTranformationError;
        if numPerson < 0
            path = strjoin(["..\ProcessedData\ForceTranformationError\B",num2str(3+numPerson),".png"],"");
        else
            path = strjoin(["..\ProcessedData\ForceTranformationError\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path);
        close(fig1);
    end

    fprintf("                                            Completed in %s minutes with a mean error of %.2f\n",duration(0,0,toc,'Format','mm:ss.SS'),meanError)
end