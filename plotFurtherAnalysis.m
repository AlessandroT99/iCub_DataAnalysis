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

function plotFurtherAnalysis(experimentDuration, meanHtoR, meanRtoH, nMaxPeaks, nMinPeaks, ...
                                maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, peaksVariation, ...
                                peaksInitialAndFinalVariation, cableTensionEfficiency)
% This function takes in input the data generated from the position and
% force further analysis functions and plot usefull scatter and other
% diagrams in order to visualize trends or similars.
    
    %% Simulation parameters
    IMAGE_SAVING = 1;
    nTest = length(experimentDuration); % Number of test analyzed
    c = linspace(1,10,nTest); % Vector used to change scatter points color

    mkdir ..\ProcessedData\Scatters

    %% Experiment duration
    fig1 = figure('Name','Experiment duration scatter');
    fig1.WindowState = 'maximized';
    grid on, hold on
    xline(4,'k--','LineWidth',2.2)
    scatter(experimentDuration,1:nTest,50,c,'filled')
    title("Distribution of experiment duration")
    legend("Desidered duration")
    xlabel("Elapsed Time [ min ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig1,"..\ProcessedData\Scatters\ExperimentDuration.png")
    end
    
    %% Phase durations
    fig2 = figure('Name','Phases duration scatter');
    fig2.WindowState = 'maximized';
    grid on, hold on
    scatter(meanRtoH*60,1:nTest,50,'blue','filled')
    scatter(meanHtoR*60,1:nTest,50,'red','filled')
    xline(1.5,'k--','LineWidth',2.2)
    title("Distribution of phases duration")
    legend('Robot to Human','Human to Robot','Desidered duration')
    xlabel("Elapsed Time [ s ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig2,"..\ProcessedData\Scatters\PhaseDuration.png")
    end
    
    %% Peaks number
    fig3 = figure('Name','Number of peaks scatter');
    fig3.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks,1:nTest,50,'red','filled')
    scatter(nMinPeaks,1:nTest,50,'green','filled')
    xline(80,'k--','LineWidth',2.2)
    title("Distribution of peaks number")
    legend('# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig3,"..\ProcessedData\Scatters\PeaksNumber.png")
    end
    
    fig4 = figure('Name','Number of peaks scatter vs. experiment duration');
    fig4.WindowState = 'maximized';
    grid on, hold on
    scatter(nMaxPeaks,experimentDuration,50,'red','filled')
    scatter(nMinPeaks,experimentDuration,50,'green','filled')
    xline(80,'k--','LineWidth',2.2)
    title("Distribution of peaks number vs. experiment duration")
    legend('# Maximums','# Minimums','Desidered #')
    xlabel("# peaks")
    ylabel("Elapsed Time [ min ]")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig4,"..\ProcessedData\Scatters\PeaksNumber-ExperimentDuration.png")
    end

    %% Peaks values
    fig5 = figure('Name','Values of peaks scatter');
    fig5.WindowState = 'maximized';
    grid on, hold on
    scatter(maxPeaksAverage.*100,1:nTest,50,'red','filled')
    scatter(minPeaksAverage.*100,1:nTest,50,'green','filled')
    % xline(posA dx)
    % xline(posB dx)
    % xline(posB sx)
    % xline(posA sx)
    % text(mean(posA sx,posB sx),5,"iCub DX hand")
    % text(mean(posA dx,posB dx),5,"iCub SX hand")
    title("Distribution of position peaks values")
    legend('Maximums average','Minimums average')
    xlabel("Peaks value [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig5,"..\ProcessedData\Scatters\PeaksValues.png")
    end

    %% Standard deviation
    fig6 = figure('Name','Standard deviation scatter');
    fig6.WindowState = 'maximized';
    grid on, hold on
    scatter(stdPos.*100,1:nTest,50,c,'filled')
    title("Distribution of position standard deviation")
    xlabel("Standard deviation [ cm ]")
    ylabel("# Test")
    hold off
    
    if IMAGE_SAVING
        exportgraphics(fig6,"..\ProcessedData\Scatters\StandardDeviation.png")
    end

    %% Mean values
    fig7 = figure('Name','Mean values scatter');
    fig7.WindowState = 'maximized';
    grid on, hold on
    scatter(meanPos.*100,1:nTest,50,c,'filled')
    title("Distribution of position mean values")
    xlabel("Mean [ cm ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        exportgraphics(fig7,"..\ProcessedData\Scatters\MeanValues.png")
    end

    %% Movement range

    %% Max e Min average distance

    %% Peaks variation 
    
    %% Peaks initial and final variation

    %% Cable tension efficiency based on positions

end