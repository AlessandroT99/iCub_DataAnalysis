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

% TODO:
% - Elaborate the yellow underlined values

function plotFurtherAnalysis(experimentDuration, meanHtoR, meanRtoH, nMaxPeaks, nMinPeaks, ...
                                maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
                                peaksInitialAndFinalVariation, cableTensionEfficiency)
% This function takes in input the data generated from the position and
% force further analysis functions and plot usefull scatter and other
% diagrams in order to visualize trends or similars.
    
    %% Simulation parameters
    IMAGE_SAVING = 1;
    nTest = length(experimentDuration); % Number of test analyzed
    brightGreen = [0.22,1,0.08];
    clearRed = [1,0.55,0];
    clearBlue = [0,1,1];

    mkdir ..\ProcessedData\Scatters

    %% Experiment duration
    fig1 = figure('Name','Experiment duration scatter');
    fig1.WindowState = 'maximized';
    grid on, hold on
    scatter(experimentDuration(1),1,50,brightGreen,'filled')
    scatter(experimentDuration(2:end),2:nTest,50,'black','filled')
    xline(4,'k--','LineWidth',2.2)
    title("Distribution of experiment duration")
    legend("BaseLine","Desidered duration")
    xlabel("Elapsed Time [ min ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig1,"..\ProcessedData\Scatters\ExperimentDuration.png")
%         close(fig1);
    end
    
    %% Phase durations
    fig2 = figure('Name','Phases duration scatter');
    fig2.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH(1)*60,1,50,clearBlue,'filled')
    scatter(meanHtoR(1)*60,1,50,clearRed,'filled')
    scatter(meanRtoH(2:end)*60,2:nTest,50,'blue','filled')
    scatter(meanHtoR(2:end)*60,2:nTest,50,'red','filled')
    xline(1.5,'k--','LineWidth',2.2)
    title("Distribution of phases duration")
    legend("BaseLine RtoH","BaseLine HtoR",'Robot to Human','Human to Robot','Desidered duration')
    xlabel("Elapsed Time [ s ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig2,"..\ProcessedData\Scatters\PhaseDuration.png")
%         close(fig2);
    end
    
    %% Peaks number
    fig3 = figure('Name','Number of peaks scatter');
    fig3.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks(1),1,50,clearRed,'filled')
    scatter(nMinPeaks(1),1,50,clearBlue,'filled')
    scatter(nMaxPeaks(2:end),2:nTest,50,'red','filled')
    scatter(nMinPeaks(2:end),2:nTest,50,'blue','filled')
    xline(80,'k--','LineWidth',2.2)
    title("Distribution of peaks number")
    legend('Baseline Maximums','Baseline Minimums','# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig3,"..\ProcessedData\Scatters\PeaksNumber.png")
%         close(fig3);
    end
    
    fig4 = figure('Name','Number of peaks scatter vs. experiment duration');
    fig4.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks(1),experimentDuration(1),50,clearRed,'filled')
    scatter(nMinPeaks(1),experimentDuration(1),50,clearBlue,'filled')
    scatter(nMaxPeaks(2:end),experimentDuration(2:end),50,'red','filled')
    scatter(nMinPeaks(2:end),experimentDuration(2:end),50,'blue','filled')
    xline(80,'k--','LineWidth',2.2)
    title("Distribution of peaks number vs. experiment duration")
    legend('Baseline Maximums','Baseline Minimums','# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("Elapsed Time [ min ]")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig4,"..\ProcessedData\Scatters\PeaksNumber-ExperimentDuration.png")
%         close(fig4);
    end

    %% Peaks values
    fig5 = figure('Name','Values of peaks scatter');
    fig5.WindowState = 'maximized';
    grid on, hold on
    scatter(maxPeaksAverage(1).*100,1,50,clearRed,'filled')
    scatter(minPeaksAverage(1).*100,1,50,clearBlue,'filled')
    scatter(maxPeaksAverage(2:end).*100,2:nTest,50,'red','filled')
    scatter(minPeaksAverage(2:end).*100,2:nTest,50,'blue','filled')
    % xline(posA dx)
    % xline(posB dx)
    % xline(posB sx)
    % xline(posA sx)
    % text(mean(posA sx,posB sx),5,"iCub DX hand")
    % text(mean(posA dx,posB dx),5,"iCub SX hand")
    title("Distribution of position peaks values")
    legend('Baseline Maximums average','Baseline Minimums average','Maximums average','Minimums average')
    xlabel("Peaks value [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig5,"..\ProcessedData\Scatters\PeaksValues.png")
%         close(fig5);
    end

    %% Standard deviation
    fig6 = figure('Name','Standard deviation scatter');
    fig6.WindowState = 'maximized';
    grid on, hold on
    scatter(stdPos(1).*100,1,50,brightGreen,'filled')
    scatter(stdPos(2:end).*100,2:nTest,50,'black','filled')
    title("Distribution of position standard deviation")
    legend("Baseline Std","Std")
    xlabel("Standard deviation [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig6,"..\ProcessedData\Scatters\StandardDeviation.png")
%         close(fig6);
    end

    %% Mean values
    fig7 = figure('Name','Mean values scatter');
    fig7.WindowState = 'maximized';
    grid on, hold on
    scatter(meanPos(1).*100,1,50,brightGreen,'filled')
    scatter(meanPos(2:end).*100,2:nTest,50,'black','filled')
    title("Distribution of position mean values")
    legend("Baseline mean value","Mean values")
    xlabel("Mean [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig7,"..\ProcessedData\Scatters\MeanValues.png")
%         close(fig7);
    end

    %% Movement range
    fig8 = figure('Name','Movement range plot');
    fig8.WindowState = 'maximized';
    grid on, hold on
    plot(1:size(movementRange,2),movementRange(1,:).*100,'k--')
    plot(1:size(movementRange,2),movementRange(2:end,:).*100)
    title("Distribution of position movement ranges")
    legend("Baseline movement range")
    xlabel("Simulation progress")
    ylabel("Movement [ cm ]")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig8,"..\ProcessedData\Scatters\MovementRange.png")
%         close(fig8);
    end

    %% Max e Min average distance
    fig9 = figure('Name','Average distances bewteen MAX e min scatter');
    fig9.WindowState = 'maximized';
    grid on, hold on
    scatter(maxMinAverageDistance(1).*100,1,50,brightGreen,'filled')
    scatter(maxMinAverageDistance(2:end).*100,2:nTest,50,'black','filled')
    title("Distribution of position Average distances bewteen MAX e min")
    legend("Baseline Average distance","Average distances")
    xlabel("Average distance bewteen MAX e min [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig9,"..\ProcessedData\Scatters\MaxMinAverageDistance.png")
%         close(fig9);
    end

    %% Peaks variation 
    fig10 = figure('Name','Peaks variation plot');
    fig10.WindowState = 'maximized';
    grid on, hold on
    plot(1:size(maxPeaksVariation,2),maxPeaksVariation(1,:).*100,'r--')
    plot(1:size(minPeaksVariation,2),minPeaksVariation(1,:).*100,'b--')
    plot(1:size(maxPeaksVariation,2),maxPeaksVariation(2:end,:).*100)
    plot(1:size(minPeaksVariation,2),minPeaksVariation(2:end,:).*100)
    title("Distribution of position movement ranges")
    legend("Baseline MAX peaks variation","Baseline min peaks variation")
    xlabel("Simulation progress")
    ylabel("Variation [ cm ]")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig10,"..\ProcessedData\Scatters\PeaksVariation.png")
%         close(fig10);
    end
    
    %% Peaks initial and final variation
    fig11 = figure('Name','Initial and final movement range variation scatter');
    fig11.WindowState = 'maximized';
    grid on, hold on
    scatter(peaksInitialAndFinalVariation(1).*100,1,50,brightGreen,'filled')
    scatter(peaksInitialAndFinalVariation(2:end).*100,2:nTest,50,'black','filled')
    title("Distribution of position Initial and final movement range variation")
    legend("Baseline variation","Variations")
    xlabel("Average distance bewteen MAX e min [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig11,"..\ProcessedData\Scatters\PeaksInitialFinalVariation.png")
%         close(fig11);
    end

    %% Cable tension efficiency based on positions

end