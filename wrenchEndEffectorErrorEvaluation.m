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

function [phaseError, moduleError, transformationError] = wrenchEndEffectorErrorEvaluation(newCuttedSynchForceDataSet, handInvolved, numPerson, initialPosDataSet, posStart, posEnd, defaultTitleName, BaselineFilesParameters)
% This function is used to check the error made from force transformation
% alghoritm making a comparison with the data dumped from the /wholeBodyDynamics/left_arm/cartesianEndEffectorWrench:o 
% port, which corresponds to the force correctly rotated into the desidered reference system
    IMAGE_SAVING = 1;        % Used to save some chosen plots
    PAUSE_TIME = 2;          % Used to let the window of the plot get the full resolution size before saving

    cuttedSynchWrenchDataSet = wrenchForceReader(numPerson, initialPosDataSet, posStart, posEnd, handInvolved, BaselineFilesParameters);

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
            path = strjoin(["..\ProcessedData\ForceTranformationError\",BaselineFilesParameters(3),num2str(3+numPerson),".png"],"");
        else
            path = strjoin(["..\ProcessedData\ForceTranformationError\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig1,path);
        close(fig1);
    end

    fprintf("                                            Completed in %s minutes with a mean error of %.2f\n",duration(0,0,toc,'Format','mm:ss.SS'),meanError)
end