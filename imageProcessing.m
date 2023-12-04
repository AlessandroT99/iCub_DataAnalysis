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

% This software aims to analyze the data of images saved during the experiment of
% soap cutting, elaborated with color isolation and pattern recognition in
% a python file. Here the data are filtered and elaborated to get the
% hidden informations

clear all, close all, clc
format compact

%% Simulation parameter
% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');
% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

IMAGE_SAVING = 1;   % Used to let the window of the plot get the full resolution size before saving
PAUSE_TIME = 3;     % Put to 1 in order to save the main plots

maximumMovementTime = 2; % Variable used to determine the time span of the envelope in sec

MarkerDimension = 80;
ErrorBarCapSize = 12;
ErrorBarLineWidth = 1;
clearGreen = [119,221,119]./255;
clearRed = [1,0.4,0];
clearBlue = [0,0.6,1];
clearYellow = [255,253,116]./255;

%% Simulation input
NUM_PEOPLE = 32;    % Overall number of test analyzed

people = readtable("..\InputData\Dati Personali EXP2.xlsx");
people = people(1:NUM_PEOPLE,:);

imageDataSetParam = readtable("..\InputData\imageProcessing\UsefullData.xlsx");
TEST_TO_AVOID = [2,7,13,18,20,22,26,27,28];

totalLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test
HumanAngle = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),3);   % General variables used to contain mean, max value and std for each test
RobotAngle = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),3);   % General variables used to contain mean, max value and std for each test
HumanLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test
RobotLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test
TensedWirePercentage = zeros(1,NUM_PEOPLE-length(TEST_TO_AVOID)); % Variable that define the % of time in which the wire was tensed

% Create the directories in which the files would be saved
mkdir ..\ProcessedData\ImageProcessing
fprintf("\nStarting Evaluation...")

%% Results evaluation
i = 0;
for cnt = 1:NUM_PEOPLE
    if sum(find(cnt==TEST_TO_AVOID)) == 0
        i = i + 1;
        fprintf("\nTest N. %d",cnt)
        dataset = readtable(strjoin(["../InputData/imageProcessing/SingleExperimentData/Test",num2str(cnt),"_ImageProcessingData"],""));
        % Save the maximum length of the wire
        tensedWire = dataset.totalLength(imageDataSetParam.FrameOfTheTensedWire(cnt));
        if ~isnan(imageDataSetParam.InitialNumberConsidered(cnt))
            % Cut the dataset due to post processing decision saved in the excell file
            dataset = dataset(imageDataSetParam.InitialNumberConsidered(cnt):imageDataSetParam.FinalNumberConsidered(cnt),:);
        end

        %% Filtering data
        fc = 2;
        gain = 1;
        frequency = 30;
        % Design of the chebyshev filter of third order
        [a,b,c,d] = cheby1(3,gain,fc/(frequency/2));
        % Groups the filter coefficients
        sos = ss2sos(a,b,c,d);
        % Remove the phase shifting and compute the output
        filteredRightLength = filtfilt(sos,gain,dataset.rightLength);
        filteredLeftLength = filtfilt(sos,gain,dataset.leftLength);
        filteredRightAngle = filtfilt(sos,gain,dataset.rightAngle);
        filteredLeftAngle = filtfilt(sos,gain,dataset.leftAngle);
        filteredtotalLength = filtfilt(sos,gain,dataset.totalLength);
        
        envTotalLength = behavior(filteredtotalLength);
        envRightAngle = behavior(filteredRightAngle);
        envLeftAngle = behavior(filteredLeftAngle);

        TensedWirePercentage(i) = sum(filteredtotalLength >= tensedWire-tensedWire/100)/length(filteredtotalLength)*100;

        % Save mean values and std values of the overall dataset
        totalLength(i,:) = [mean(dataset.totalLength),std(dataset.totalLength)];
        % If the human hand is R then look for the left side of the interaction camera
        if strcmp(people.Mano(i),"R") == 1
            HumanAngle(i,:) = [mean(envLeftAngle),max(envLeftAngle),std(envLeftAngle)];
            RobotAngle(i,:) = [mean(envRightAngle),max(envRightAngle),std(envRightAngle)];
            HumanLength(i,:) = [mean(filteredLeftLength),std(filteredLeftLength)];
            RobotLength(i,:) = [mean(filteredRightLength),std(filteredRightLength)];
        else
            HumanAngle(i,:) = [mean(envRightAngle),max(envRightAngle),std(envRightAngle)];
            RobotAngle(i,:) = [mean(envLeftAngle),max(envLeftAngle),std(envLeftAngle)];
            HumanLength(i,:) = [mean(filteredRightLength),std(filteredRightLength)];
            RobotLength(i,:) = [mean(filteredLeftLength),std(filteredLeftLength)];
        end

        %% Plot results for total length
        fig1 = figure('Name','Wire Length');
        fig1.WindowState = 'maximized';
        grid on, hold on
        x = linspace(0,100,length(dataset.totalLength));
        plot(x,filteredtotalLength,'k')
        plot(1:100,envTotalLength,'r')
        yline(tensedWire-tensedWire/100,'k--','LineWidth',1.8)
        legend("Length of the wire","Envelope","Tensed wire length (-1% tollerance)",'Location','eastoutside')
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        title("Wire total length",strjoin(["Tensed wire Percentage: ",num2str(TensedWirePercentage(i))," %"],""))
        
        %% Plot results for side length
        fig2 = figure('Name','Wire side lengths');
        fig2.WindowState = 'maximized';
        subplot(2,1,1), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredLeftLength,'k')
        else
            plot(x,filteredRightLength,'k')
        end
        title("Wire length Human side")
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        hold off
        subplot(2,1,2), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredRightLength,'k')
        else
            plot(x,filteredLeftLength,'k')
        end
        title("Wire length Robot side")
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        hold off
        
        %% Plot results for side angle
        fig3 = figure('Name','Wire side angles');
        fig3.WindowState = 'maximized';
        subplot(2,1,1), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredLeftAngle,'k')
            plot(1:100,envLeftAngle,'r')
        else
            plot(x,filteredRightAngle,'k')
            plot(1:100,envRightAngle,'r')
        end
        title("Wire angle Human side")
        legend("Angle of the side of wire","Envelope",'Location','eastoutside')
        xlabel("Experiment progress [ % ]"), ylabel("Angle between the center marker horizontal [ deg ]")
        hold off
        subplot(2,1,2), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredRightAngle,'k')
            plot(1:100,envRightAngle,'r')
        else
            plot(x,filteredLeftAngle,'k')
            plot(1:100,envLeftAngle,'r')
        end
        title("Wire angle Robot side")
        legend("Angle of the side of wire","Envelope",'Location','eastoutside')
        xlabel("Experiment progress [ % ]"), ylabel("Angle between the center marker horizontal [ deg ]")
        hold off
    
        %% Save results
        if IMAGE_SAVING
            pause(PAUSE_TIME); 
            mkdir ..\ProcessedData\ImageProcessing\WireLength
            path = strjoin(["..\ProcessedData\ImageProcessing\WireLength\P",num2str(i),".png"],"");
            exportgraphics(fig1,path)
            close(fig1);
    
            mkdir ..\ProcessedData\ImageProcessing\WireSideLength
            path = strjoin(["..\ProcessedData\ImageProcessing\WireSideLength\P",num2str(i),".png"],"");
            exportgraphics(fig2,path)
            close(fig2);
    
            mkdir ..\ProcessedData\ImageProcessing\WireAngles
            path = strjoin(["..\ProcessedData\ImageProcessing\WireAngles\P",num2str(i),".png"],"");
            exportgraphics(fig3,path)
            close(fig3);
        end
    end
end

fig4 = figure('Name','Tensed wire vs. mean human angle');
fig4.WindowState = 'maximized';
hold on, grid on
scatter(HumanAngle(:,1),TensedWirePercentage,80,"cyan","filled")
lsline
xlabel("Mean Human Angle [ deg ]"), ylabel("Tensed wire time percentage [ % ]")
title("Tensed wire vs. mean human angle")

fig5 = figure('Name','Tensed wire vs. max human angle');
fig5.WindowState = 'maximized';
hold on, grid on
scatter(HumanAngle(:,2),TensedWirePercentage,80,"cyan","filled")
lsline
xlabel("Max Human Angle [ deg ]"), ylabel("Tensed wire time percentage [ % ]")
title("Tensed wire vs. max human angle")

if IMAGE_SAVING
    pause(PAUSE_TIME); 
    exportgraphics(fig4,"..\ProcessedData\ImageProcessing\TensedWirePercentage-MaxHumanAngle.png")
    close(fig4);
    exportgraphics(fig5,"..\ProcessedData\ImageProcessing\TensedWirePercentage-MeanHumanAngle.png")
    close(fig5);
end

%% Saving data
variablesToBeSaved = 6;
toSave = zeros(NUM_PEOPLE,variablesToBeSaved);
cnt = 0;
for i = 1:NUM_PEOPLE
    if sum(find(i==TEST_TO_AVOID)) == 0
        cnt = cnt + 1;
        toSave(i,1) = totalLength(cnt);
        toSave(i,2) = HumanAngle(cnt);
        toSave(i,3) = RobotAngle(cnt);
        toSave(i,4) = HumanLength(cnt);
        toSave(i,5) = RobotLength(cnt);
        toSave(i,6) = TensedWirePercentage(cnt);
    else
        toSave(i,:) = nan*ones(1,variablesToBeSaved);
    end
end
totalLength = toSave(:,1);
HumanAngle = toSave(:,2);
RobotAngle = toSave(:,3);
HumanLength = toSave(:,4);
RobotLength = toSave(:,5);
TensedWirePercentage = toSave(:,6);

save('../ProcessedData/ImageProcessing/ImageProcessingData',"totalLength","HumanAngle","RobotAngle","HumanLength","RobotLength","TensedWirePercentage");

fprintf("\nEvaluation completed\n\n")

%% Function
function [signalBehavior] = behavior(signal)
   ORDER = 4;
   signalBehavior = zeros(1,100);
   for i = 0:99
        signalBehavior(i+1) = mean(signal(round(i*length(signal)/100)+1:round((i+1)*length(signal)/100))); 
   end
end
