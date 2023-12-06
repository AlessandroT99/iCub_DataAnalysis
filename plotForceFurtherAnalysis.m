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

% This software aims to find data from the force signal in order to
% determine a parameter to increase efficience of the interaction,
% especially it is used to plot the data saved for each dataset involved.

function plotForceFurtherAnalysis(meanTrend, lowSlope, upSlope, meanAmplitude)
    %% Simulation parameters
    IMAGE_SAVING = 1; % Put to 1 in order to save the main plots
    PAUSE_TIME = 2; % Used to let the window of the plot get the full resolution size before saving
    nTest = length(meanTrend); % Number of test analyzed
    clearGreen = [119,221,119]./255;
    clearRed = [1,0.4,0];
    clearBlue = [0,0.6,1];
    clearYellow = [255,253,116]./255;

    customColors = zeros(36,3);
    customColors(1:9,:) = brewermap(9,'Set1');
    customColors(10:17,:) = brewermap(8,'Set2');
    customColors(18:25,:) = brewermap(8,'Pastel1');
    customColors(26:33,:) = brewermap(8,'Pastel2');
    EmptyPointLine = 1.5;
    MarkerDimension = 80;
    DottedLineWidth = 2;
    ErrorBarCapSize = 12;
    ErrorBarLineWidth = 1;
    ConnectionLineWidthROM = 0.5;
    LineTypeROM = '-';

    % Folders and priority order of the subfolders
    mkdir ..\iCub_ProcessedData\Scatters\7.ForceAnalysis

    %% Mean Trend - 7. FORCE MEAN TREND
    fig1 = figure('Name','Mean behavior of each force signal');
    fig1.WindowState = 'maximized';
    grid on, hold on
    plot(linspace(0,100,size(meanTrend,2)),meanTrend)
    title("Mean behavior of each force signal")
    ylabel("Force [ N ]")
    xlabel("Experiment progression [ % ]")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig1,"..\iCub_ProcessedData\Scatters\7.ForceAnalysis\MeanTrend.png")
        close(fig1);
    end

    %% Mean Amplitude - 8. FORCE MEAN AMPLITUDE
    fig2 = figure('Name','Experiment duration scatter');
    fig2.WindowState = 'maximized';
    grid on, hold on
    scatter(1:length(meanAmplitude),meanAmplitude,MarkerDimension,clearRed,'filled')
%     lsline
    title("Mean amplitude of the force signal")
    xlabel("Force [ N ]")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig2,"..\iCub_ProcessedData\Scatters\7.ForceAnalysis\MeanAmplitude.png")
        close(fig2);
    end

    %% Slope - 9. FORCE SLOPE
    fig3 = figure('Name','Slope of the force signal in the upper and lower peaks');
    fig3.WindowState = 'maximized';
    grid on, hold on
    scatter(1:length(lowSlope),lowSlope,MarkerDimension,clearRed,'filled')
%     h = lsline;
%     h.Color = [1,0,0];
    scatter(1:length(upSlope),upSlope,MarkerDimension,clearBlue,'filled')
%     h = lsline;
%     h.Color = [0,0,1];
    title("Slope of the force signal in the upper and lower peaks")
%     legend("Lower slope","Lower trend","Upper slope","Upper trend")
    legend("Lower slope","Upper slope")
    xlabel("Slope")
    ylabel("# Test")
    hold off

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig3,"..\iCub_ProcessedData\Scatters\7.ForceAnalysis\Slope.png")
        close(fig3);
    end

end