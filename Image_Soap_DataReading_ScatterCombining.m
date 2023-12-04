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

% This software aims to combine dataa from soap measuring, image procesing
% and data analysis made in the other softwares of the folder in order to
% find proper correlation bewteen data and find a variable which describes
% correctly the efficiency of the cutting task.

clear all, close all, clc
format compact

fprintf("\nStarting Analysis...")

%% Simulation parameters
% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');
% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

IMAGE_SAVING = 1;   % Used to let the window of the plot get the full resolution size before saving
PAUSE_TIME = 3;     % Put to 1 in order to save the main plots

maximumMovementTime = 2; % Variable used to determine the time span of the envelope in sec

% Folder created to containts all the ipothesis made in this software
mkdir ..\ProcessedData\Scatters\6.CorrelationResearch

%% Input data
NUM_PEOPLE = 32;    % Overall number of test analyzed

people = readtable("..\InputData\Dati Personali EXP2.xlsx");
people = people(1:NUM_PEOPLE,:);

% IMAGE PROCESSING USEFULL PARAMETERS
load ..\ProcessedData\ImageProcessing\ImageProcessingData.mat;

% SOAP MEASURE USEFULL PARAMETERS
soap = readtable("..\ProcessedData\SoapData.xlsx");

% DATA PROCESSING USEFULL PARAMETERS
dataProcessing = readtable("..\ProcessedData\PeaksPositionData.xlsx");
dataProcessing = dataProcessing(2:end,:);

%% Data adjusting
soap4image = soap;
soap4dataProcessing = soap;
cnt = 1;
for i = 1:NUM_PEOPLE
    if isnan(RobotLength(i))
        soap4image(i,:) = array2table(nan.*ones(1,width(soap4image)));
    end

    if sum(find(i==dataProcessing.ID)) == 0
        soap4dataProcessing(cnt,:) = [];
    else
        if ~isnan(dataProcessing.Near_Hand_ms_(cnt))
            nearHandLogic(cnt) = 1;
        end
        cnt = cnt + 1;
    end
end
nearHandLogic = logical(nearHandLogic);

%% Plot results
fig1 = figure('Name','Removed material vs. tensed wire time');
fig1.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(soap4image.PercentageOfRemovedMaterial___,1,TensedWirePercentage);
xlabel("Removed material [ % ]"), ylabel("Tensed wire time [ % ]")
title("Removed material vs. tensed wire time")
legend("Participants","Trend","Mean","Standard Deviation")

fig2 = figure('Name','Image Angle vs. Soap Indentation Angle');
fig2.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(soap4image.AngleHumanSide_deg_,1,HumanAngle)
xlabel("Image Angle [ deg ]"), ylabel("Soap Indentation Angle [ deg ]")
title("Image Angle vs. Soap Indentation Angle")
legend("Participants","Trend","Mean","Standard Deviation")

fig3 = figure('Name','Asimmetry of posA vs. Removed material');
fig3.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(-dataProcessing.DeviationFromA_cm_,1,soap4dataProcessing.PercentageOfRemovedMaterial___)
xlabel("Asimmetry of posA [ cm ]"), ylabel("Removed material [ % ]")
title("Asimmetry of posA vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")

fig4 = figure('Name','Human pulling phase time vs. Removed material');
fig4.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(dataProcessing.Human_PhaseTimeDomain_s_,100,soap4dataProcessing.PercentageOfRemovedMaterial___)
xlabel("Human pulling phase time [ ms ]"), ylabel("Removed material [ % ]")
title("Human pulling phase time vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")

fig5 = figure('Name','Near Hand effect vs. Removed material');
fig5.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(dataProcessing.Near_Hand_ms_(nearHandLogic),1,soap4dataProcessing.PercentageOfRemovedMaterial___(nearHandLogic))
xlabel("Near Hand effect [ ms ]"), ylabel("Removed material [ % ]")
title("Near Hand effect vs. Removed material")
set(gca, 'XDir','reverse')
legend("Participants","Trend","Mean","Standard Deviation")

fig6 = figure('Name','ROM vs. Removed material');
fig6.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(dataProcessing.ROM_cm_,1,soap4dataProcessing.PercentageOfRemovedMaterial___)
xlabel("ROM [ cm ]"), ylabel("Removed material [ % ]")
title("ROM vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")

fig7 = figure('Name','Pulling phase time difference vs. Removed material');
fig7.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(abs(dataProcessing.Human_PhaseTimeDomain_s_-dataProcessing.Robot_PhaseTimeDomain_s_),100,soap4dataProcessing.PercentageOfRemovedMaterial___)
xlabel("Pulling phase time difference [ ms ]"), ylabel("Removed material [ % ]")
title("Pulling phase time difference vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")

%% Saving results
if IMAGE_SAVING
    pause(PAUSE_TIME); 
    exportgraphics(fig1,"..\ProcessedData\Scatters\6.CorrelationResearch\TensedWire-RemovedMaterial.png")
    close(fig1);
    exportgraphics(fig2,"..\ProcessedData\Scatters\6.CorrelationResearch\ImageAngle-SoapIndentationAngle.png")
    close(fig2);
    exportgraphics(fig3,"..\ProcessedData\Scatters\6.CorrelationResearch\AsimmetryPosA-RemovedMaterial.png")
    close(fig3);
    exportgraphics(fig4,"..\ProcessedData\Scatters\6.CorrelationResearch\HumanPullingPhaseTime-RemovedMaterial.png")
    close(fig4);
    exportgraphics(fig5,"..\ProcessedData\Scatters\6.CorrelationResearch\NearHand-RemovedMaterial.png")
    close(fig5);
    exportgraphics(fig6,"..\ProcessedData\Scatters\6.CorrelationResearch\ROM-RemovedMaterial.png")
    close(fig6);
    exportgraphics(fig7,"..\ProcessedData\Scatters\6.CorrelationResearch\PullingPhaseTimeDifference-RemovedMaterial.png")
    close(fig7);
end

%% End of the simulation
fprintf("\nAnalysis completed.\n\n");

%% Functions
function plot_scatterProcedure(x,xMultiplier,y)
    % Usefull common plot parameters
    MarkerDimension = 80;
    ErrorBarCapSize = 12;
    ErrorBarLineWidth = 1;
    clearGreen = [119,221,119]./255;
    clearRed = [1,0.4,0];
    clearBlue = [0,0.6,1];
    clearYellow = [255,253,116]./255;

    scatter(x.*xMultiplier,y,MarkerDimension,clearRed,"filled")
    lsline
    scatter(mean(x.*xMultiplier),mean(y),1.5*MarkerDimension,"black",'filled')
    stdError1 = std(x.*xMultiplier)./sqrt(length(x));
    stdError2 = std(y)./sqrt(length(y));
    errorbar(mean(x.*xMultiplier),mean(y), -stdError1/2,stdError1/2, ...
        'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    errorbar(mean(x.*xMultiplier),mean(y), -stdError2/2,stdError2/2, ...
        'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
end