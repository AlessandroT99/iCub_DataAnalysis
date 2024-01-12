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

maximumMovementTime = 2; % Variable used to determine the time span of the envelope in sec

% Folder created to containts all the ipothesis made in this software
mkdir ..\iCub_ProcessedData\Scatters\6.CorrelationResearch

%% Input data
NUM_PEOPLE = 32;    % Overall number of test analyzed

people = readtable("..\iCub_InputData\Dati Personali EXP2.xlsx");
people = people(1:NUM_PEOPLE,:);

% IMAGE PROCESSING USEFULL PARAMETERS
load ..\iCub_ProcessedData\ImageProcessing\ImageProcessingData.mat;

% SOAP MEASURE USEFULL PARAMETERS
soap = readtable("..\iCub_ProcessedData\SoapData.xlsx");

% DATA PROCESSING USEFULL PARAMETERS
positionDataProcessing = readtable("..\iCub_ProcessedData\PeaksPositionData.xlsx");
positionDataProcessing = positionDataProcessing(2:end,:);
forceDataProcessing = readtable("..\iCub_ProcessedData\PeaksForceData.xlsx");

mind = readtable("..\iCub_ProcessedData\MindAttribution.xlsx");

%% Data adjusting
soap4image = soap;
soap4dataPosProcessing = soap;
soap4dataForceProcessing = soap;
cntPos = 1;
cntForce = 1;
nearHandLogicPos = zeros(height(positionDataProcessing),1);
nearHandLogicForce = zeros(height(forceDataProcessing),1);
nearHandLogic4imagesPos = zeros(NUM_PEOPLE,1);
nearHandLogic4imagesForce = zeros(NUM_PEOPLE,1);
sensorDatalogic4imagesPos = zeros(NUM_PEOPLE,1);
sensorDatalogic4imagesForce = zeros(NUM_PEOPLE,1);

forcePositionLogic = zeros(height(positionDataProcessing),1);
for i = 1:height(positionDataProcessing)
    forcePositionLogic(i) = logical(sum(forceDataProcessing.ID==positionDataProcessing.ID(i)));
end

for i = 1:NUM_PEOPLE
    if isnan(RobotLength(i))
        soap4image(i,:) = array2table(nan.*ones(1,width(soap4image)));
    end

    if sum(find(i==positionDataProcessing.ID)) == 0
        soap4dataPosProcessing(cntPos,:) = [];
    else 
        if  ~isnan(positionDataProcessing.Near_Hand_ms_(cntPos))
            nearHandLogicPos(cntPos) = 1;
            nearHandLogic4imagesPos(i) = 1;
        end
        sensorDatalogic4imagesPos(i) = 1;
        cntPos = cntPos + 1;
    end

    if sum(find(i==forceDataProcessing.ID)) == 0
        soap4dataForceProcessing(cntForce,:) = [];
    else
        if ~isnan(positionDataProcessing.Near_Hand_ms_(cntForce))
            nearHandLogicForce(cntForce) = 1;
            nearHandLogic4imagesForce(i) = 1;
        end
        sensorDatalogic4imagesForce(i) = 1;
        cntForce = cntForce + 1;
    end
end

nearHandLogicPos = logical(nearHandLogicPos);
nearHandLogic4imagesPos = logical(nearHandLogic4imagesPos);
nearHandLogicForce = logical(nearHandLogicForce);
nearHandLogic4imagesForce = logical(nearHandLogic4imagesForce);
sensorDatalogic4imagesPos = logical(sensorDatalogic4imagesPos);
sensorDatalogic4imagesForce = logical(sensorDatalogic4imagesForce);

%% Plot results
fig1 = figure('Name','Removed material vs. tensed wire time');
fig1.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(soap4image.PercentageOfRemovedMaterial___,1,TensedWirePercentage);
xlabel("Removed material [ % ]"), ylabel("Tensed wire time [ % ]")
title("Removed material vs. tensed wire time")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"1_TensedWire-RemovedMaterial");

fig2 = figure('Name','Image Angle vs. Soap Indentation Angle');
fig2.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(soap4image.AngleHumanSide_deg_,1,HumanAngle)
xlabel("Image Angle [ deg ]"), ylabel("Soap Indentation Angle [ deg ]")
title("Image Angle vs. Soap Indentation Angle")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"2_ImageAngle-SoapIndentationAngle");

fig3 = figure('Name','Asimmetry of posA vs. Removed material');
fig3.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(-positionDataProcessing.DeviationFromA_cm_,1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Asimmetry of posA [ cm ]"), ylabel("Removed material [ % ]")
title("Asimmetry of posA vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"3_AsimmetryPosA-RemovedMaterial");

fig4 = figure('Name','Human pulling phase time vs. Removed material');
fig4.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Human_PhaseTimeDomain_s_,1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Human pulling phase time [ s ]"), ylabel("Removed material [ % ]")
title("Human pulling phase time vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"4_HumanPullingPhaseTime-RemovedMaterial");

fig5 = figure('Name','Near Hand effect vs. Removed material');
fig5.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Near_Hand_ms_(nearHandLogicPos),1,soap4dataPosProcessing.PercentageOfRemovedMaterial___(nearHandLogicPos))
xlabel("Near Hand effect [ ms ]"), ylabel("Removed material [ % ]")
title("Near Hand effect vs. Removed material")
set(gca, 'XDir','reverse')
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"5_NearHand-RemovedMaterial");

fig6 = figure('Name','ROM vs. Removed material');
fig6.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.ROM_cm_,1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("ROM [ cm ]"), ylabel("Removed material [ % ]")
title("ROM vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"6_ROM-RemovedMaterial");

fig7 = figure('Name','Pulling phase time difference vs. Removed material');
fig7.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(abs(positionDataProcessing.PhaseDelay_s_),1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Absolute Pulling phase time difference [ s ]"), ylabel("Removed material [ % ]")
title("Pulling phase time difference vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"7_PullingPhaseTimeDifference-RemovedMaterial");

fig8 = figure('Name','ROM vs. Force applied');
fig8.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.ROM_cm_(logical(forcePositionLogic)),1,forceDataProcessing.PeaksMeanAmplitude)
xlabel("ROM [ cm ]"), ylabel("Force Applied [ N ]")
title("ROM vs. Force applied")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"8_ROM-MeanForceApplied");

fig9 = figure('Name','Force slope vs. Near Hand effect');
fig9.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(forceDataProcessing.ForceResultantSlope(nearHandLogicForce),1,positionDataProcessing.Near_Hand_ms_(nearHandLogicForce))
xlabel("Force slope"), ylabel("Near Hand effect [ ms ]")
title("Force slope vs. Near Hand effect")
set(gca, 'YDir','reverse')
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"9_ForceSlope-NearHand");

fig10 = figure('Name','Force slope vs. Removed material');
fig10.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(forceDataProcessing.ForceResultantSlope,1,soap4dataForceProcessing.PercentageOfRemovedMaterial___)
xlabel("Force slope"), ylabel("Removed material [ % ]")
title("Force slope vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"10_ForceSlope-RemovedMaterial");

fig11 = figure('Name','Force applied vs. Removed material');
fig11.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(forceDataProcessing.PeaksMeanAmplitude,1,soap4dataForceProcessing.PercentageOfRemovedMaterial___)
xlabel("Force applied [ N ]"), ylabel("Removed material [ % ]")
title("Force applied vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"11_MeanForceApplied-RemovedMaterial");

fig12 = figure('Name','Force slope vs. Force applied');
fig12.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(forceDataProcessing.ForceResultantSlope,1,forceDataProcessing.PeaksMeanAmplitude)
xlabel("Force slope"), ylabel("Force applied [ N ]")
title("Force slope vs. Force applied")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"12_ForceSlope-MeanForceApplied");

fig13 = figure('Name','Relative Velocity Difference (H-R) vs. Removed Material');
fig13.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Human_PhaseRelativeVelocity_cm_s_-positionDataProcessing.Robot_PhaseRelativeVelocity_cm_s_,1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Relative velocity difference [ cm/s ]"), ylabel("Removed Material [ % ]")
title("Relative Velocity Difference (H-R) vs. Removed Material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"13_RelativeVelocityDifference-RemovedMaterial");

fig14 = figure('Name','Human Relative Velocity vs. Removed Material');
fig14.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Human_PhaseRelativeVelocity_cm_s_,1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Relative velocity [ cm/s ]"), ylabel("Removed Material [ % ]")
title("Human Relative Velocity vs. Removed Material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"14_HumanRelativeVelocity-RemovedMaterial");

fig15 = figure('Name','Mean angle of the human side vs. Removed Material');
fig15.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(HumanAngle(sensorDatalogic4imagesPos),1,soap4dataPosProcessing.PercentageOfRemovedMaterial___)
xlabel("Angle [ deg ]"), ylabel("Removed Material [ % ]")
title("Mean angle of the human side vs. Removed Material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"15_MeanAngleHuman-RemovedMaterial");

fig16 = figure('Name','Mean angle of the human side vs. Force Applied');
fig16.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(HumanAngle(sensorDatalogic4imagesForce),1,forceDataProcessing.PeaksMeanAmplitude)
xlabel("Angle [ deg ]"), ylabel("Force Applied [ N ]")
title("Mean angle of the human side vs. Force Applied")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"16_MeanAngleHuman-MeanForceApplied");

fig17 = figure('Name','Mean angle of the human side vs. Near Hand Effect');
fig17.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(HumanAngle(nearHandLogic4imagesPos),1,positionDataProcessing.Near_Hand_ms_(nearHandLogicPos))
xlabel("Angle [ deg ]"), ylabel("Near Hand Effect [ ms ]")
set(gca, 'YDir','reverse')
title("Mean angle of the human side vs. Near Hand Effect")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"17_MeanAngleHuman-NearHand");

fig18 = figure('Name','Human Relative Velocity vs. Mean Force Applied');
fig18.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Human_PhaseRelativeVelocity_cm_s_(logical(forcePositionLogic)),1,forceDataProcessing.PeaksMeanAmplitude)
xlabel("Relative Velocity [ cm/s ]"), ylabel("Force Applied [ N ]")
title("Human Relative Velocity vs. Mean Force Applied")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"18_HumanRelativeVelocity-MeanForceApplied");

fig19 = figure('Name','Mean Angle Human Side vs. Human Relative Velocity');
fig19.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(HumanAngle(sensorDatalogic4imagesPos),1,positionDataProcessing.Human_PhaseRelativeVelocity_cm_s_)
xlabel("Mean Angle Human Side [ deg ]"), ylabel("Relative Velocity [ cm/s ]")
title("Mean Angle Human Side vs. Human Relative Velocity")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"19_MeanAngleHumanSide-HumanRelativeVelocity");

fig20 = figure('Name','Near Hand Effect vs. Human Relative Velocity');
fig20.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.Near_Hand_ms_(nearHandLogicPos),1,positionDataProcessing.Human_PhaseRelativeVelocity_cm_s_(nearHandLogicPos))
xlabel("Near Hand Effect [ ms ]"), ylabel("Relative Velocity [ cm/s ]")
title("Near Hand Effect vs. Human Relative Velocity")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"20_NearHand-HumanRelativeVelocity");

fig21 = figure('Name','Asymmetry from A vs. Mean Angle Human Side');
fig21.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.DeviationFromA_cm_,1,HumanAngle(sensorDatalogic4imagesPos))
xlabel("Asymmetry from A [ cm ]"), ylabel("Angle [ deg ]")
title("Asymmetry from A vs. Mean Angle Human Side")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"21_AsymmetryfromA-MeanAngleHumanSide");

fig22 = figure('Name','Mind attribution');
fig22.WindowState = 'maximized';
hold on, grid on
clearRed = [1,0.4,0];
clearBlue = [0,0.6,1];
MarkerDimension = 80;
scatter(1:height(mind), mind.mind, MarkerDimension, clearRed, "filled")
p = polyfit(1:height(mind), mind.mind,1);
ymean = polyval(p, linspace(0,height(mind)));
plot(linspace(0,height(mind)),ymean,'-',"Color",clearRed)
scatter(1:height(mind), mind.MIND, MarkerDimension, clearBlue, "filled")
p = polyfit(1:height(mind), mind.MIND,1);
ymean = polyval(p, linspace(0,height(mind)));
plot(linspace(0,height(mind)),ymean,'-',"Color",clearBlue)
xlabel("Mind attribution"), ylabel("# of participant")
title("Mind attribution pre&post")
legend("Before","Before trend","After","After trend")
hold off
savingFigure(gcf,"22_MindAttribution");

fig23 = figure('Name','ROM vs. Mean Angle Human Side');
fig23.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(positionDataProcessing.ROM_cm_,1,HumanAngle(sensorDatalogic4imagesPos))
xlabel("ROM [ cm ]"), ylabel("Angle [ deg ]")
title("ROM vs. Mean Angle Human Side")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"23_ROM-MeanAngleHumanSide");

fig24 = figure('Name','Mind attribution vs. Mean Force Applied');
fig24.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(forceDataProcessing.PeaksMeanAmplitude,1,mind.MIND(sensorDatalogic4imagesForce))
ylabel("Mind Attribution"), xlabel("Force Applied [ N ]")
title("Mind attribution vs. Mean Force Applied")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"24_MindAttribution-MeanForceApplied");

fig25 = figure('Name','Mind attribution vs. Removed material');
fig25.WindowState = 'maximized';
hold on, grid on
plot_scatterProcedure(soap.PercentageOfRemovedMaterial___,1,mind.MIND)
ylabel("Mind Attribution"), xlabel("Removed material [ % ]")
title("Mind attribution vs. Removed material")
legend("Participants","Trend","Mean","Standard Deviation")
hold off
savingFigure(gcf,"25_MindAttribution-RemovedMaterial");

%% End of the simulation
fprintf("\nAnalysis completed.\n");

%% Saving data
outputTable = array2table(zeros(NUM_PEOPLE+1,1+width(positionDataProcessing)-1+width(forceDataProcessing)-1+width(soap)-1+2));
posCnt = 1;
forceCnt = 1;
soapCnt = 1;
for id = 1:NUM_PEOPLE
    if positionDataProcessing.ID(posCnt) == id
        outputTable(id+1,2:width(positionDataProcessing)) = positionDataProcessing(posCnt,2:end); 
        posCnt = posCnt + 1;
    else
        outputTable(id+1,2:width(positionDataProcessing)) = array2table(nan(1,width(positionDataProcessing)-1));
    end
    
    if forceDataProcessing.ID(forceCnt) == id
        outputTable(id,1+width(positionDataProcessing):width(positionDataProcessing)+width(forceDataProcessing)-1) = forceDataProcessing(forceCnt,2:end);
        forceCnt = forceCnt + 1;
    else
        outputTable(id+1,1+width(positionDataProcessing):width(positionDataProcessing)+width(forceDataProcessing)-1) = array2table(nan(1,width(forceDataProcessing)-1));
    end

    if soap.ID(soapCnt) == id
        outputTable(id+1, width(positionDataProcessing)+width(forceDataProcessing):width(positionDataProcessing)+width(forceDataProcessing)+width(soap)-2) = soap(soapCnt, 2:end);
        soapCnt = soapCnt + 1;
    else 
        outputTable(id+1, width(positionDataProcessing)+width(forceDataProcessing):width(positionDataProcessing)+width(forceDataProcessing)+width(soap)-2) = arrray2table(nan(1,width(soap)-1));
    end
end
outputTable(2:end,1) = array2table((1:NUM_PEOPLE)');
outputTable(2:end,end-1:end) = array2table([HumanAngle, RobotAngle]);
NONE = -1;
POSITION = 0;
FORCE = 1;
SOAP = 2;
IMAGE = 3;
outputTable(1,:) = array2table([NONE,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION,POSITION, ...
                    FORCE,FORCE,FORCE,SOAP,SOAP,SOAP,IMAGE,IMAGE]);
outputTable = renamevars(outputTable,1:width(outputTable),["ID",positionDataProcessing.Properties.VariableNames(2:end),forceDataProcessing.Properties.VariableNames(2:end),soap.Properties.VariableNames(2:end),"Image Human Angle", "Image Robot Angle"]);

if isfile("..\iCub_ProcessedData\CompleteAnalysis.xlsx")
        delete("..\iCub_ProcessedData\CompleteAnalysis.xlsx");
end
writetable(outputTable, "..\iCub_ProcessedData\CompleteAnalysis.xlsx");

fprintf("\nAll data saved.\n\n")

%% Function
function plot_scatterProcedure(x,xMultiplier,y)
    % Usefull common plot parameters
    MarkerDimension = 80;
    ErrorBarCapSize = 12;
    ErrorBarLineWidth = 1;
    clearGreen = [119,221,119]./255;
    clearRed = [1,0.4,0];
    clearBlue = [0,0.6,1];
    clearYellow = [255,253,116]./255;

    tmp = ~isnan(x);
    if sum(tmp) == 0 % if not NaN are present in x
        tmp = ~isnan(y);
        if sum(tmp) == 0 % in not NaN are present in y
            tmp = true(1,length(x));
        end
    end
    x = x(tmp);
    y = y(tmp);

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

function savingFigure(fig, nameFile)
    IMAGE_SAVING = 1;   % Used to let the window of the plot get the full resolution size before saving
    PAUSE_TIME = 1;     % Put to 1 in order to save the main plots

    if IMAGE_SAVING
        pause(PAUSE_TIME);
        exportgraphics(fig,strjoin(["..\iCub_ProcessedData\Scatters\6.CorrelationResearch\",nameFile,".png"],""))
        fprintf(strjoin(["\nThe file ",nameFile," has been successfully saved."],""))
        close(fig);
    end
end