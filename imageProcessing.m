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
TEST_TO_AVOID = [2,7,13,18,20,22,26,28];

totalLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test
HumanAngle = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);   % General variables used to contain mean and std for each test
RobotAngle = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);   % General variables used to contain mean and std for each test
HumanLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test
RobotLength = zeros(NUM_PEOPLE-length(TEST_TO_AVOID),2);  % General variables used to contain mean and std for each test

% Create the directories in which the files would be saved
mkdir ..\ProcessedData\ImageProcessing
fprintf("\nStarting Evaluation...")

%% Results evaluation
for i = 1:NUM_PEOPLE
    if sum(find(i==TEST_TO_AVOID)) == 0
        fprintf("\nTest N. %d",i)
        dataset = readtable(strjoin(["../InputData/imageProcessing/SingleExperimentData/Test",num2str(i),"_ImageProcessingData"],""));
        % Save the maximum length of the wire
        tensedWire = dataset.totalLength(imageDataSetParam.FrameOfTheTensedWire(i));
        if ~isnan(imageDataSetParam.InitialNumberConsidered(i))
            % Cut the dataset due to post processing decision saved in the excell file
            dataset = dataset(imageDataSetParam.InitialNumberConsidered(i):imageDataSetParam.FinalNumberConsidered(i),:);
        end
        
        % Save mean values and std values of the overall dataset
        totalLength(i,:) = [mean(dataset.totalLength),std(dataset.totalLength)];
        % If the human hand is R then look for the left side of the interaction camera
        if strcmp(people.Mano(i),"R") == 1
            HumanAngle(i,:) = [mean(dataset.leftAngle),std(dataset.leftAngle)];
            RobotAngle(i,:) = [mean(dataset.rightAngle),std(dataset.rightAngle)];
            HumanLength(i,:) = [mean(dataset.leftLength),std(dataset.leftLength)];
            RobotLength(i,:) = [mean(dataset.rightLength),std(dataset.rightLength)];
        else
            HumanAngle(i,:) = [mean(dataset.rightAngle),std(dataset.rightAngle)];
            RobotAngle(i,:) = [mean(dataset.leftAngle),std(dataset.leftAngle)];
            HumanLength(i,:) = [mean(dataset.rightLength),std(dataset.rightLength)];
            RobotLength(i,:) = [mean(dataset.leftLength),std(dataset.leftLength)];
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

        %% Plot results for total length
        fig1 = figure('Name','Wire Length');
        fig1.WindowState = 'maximized';
        grid on, hold on
        x = linspace(0,100,length(dataset.totalLength));
        plot(x,filteredtotalLength,'r')
        yline(tensedWire,'k--','LineWidth',1.8)
        legend("Length of the wire","Tensed wire length",'Location','eastoutside')
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        title("Wire total length")
        
        %% Plot results for side length
        fig2 = figure('Name','Wire side lengths');
        fig2.WindowState = 'maximized';
        subplot(2,1,1), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredLeftLength,'r')
        else
            plot(x,filteredRightLength,'r')
        end
        title("Wire length Human side")
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        hold off
        subplot(2,1,2), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
%            plot(x,dataset.rightLength,'k')
           plot(x,filteredRightLength,'r')
        else
%             plot(x,dataset.leftLength,'k')
            plot(x,filteredLeftLength,'r')
        end
        title("Wire length Robot side")
        xlabel("Experiment progress [ % ]"), ylabel("Length in the image frame [ cm ]")
        hold off
        
        %% Plot results for side angle
        fig3 = figure('Name','Wire side angles');
        fig3.WindowState = 'maximized';
        subplot(2,1,1), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredLeftAngle,'r')
        else
            plot(x,filteredRightAngle,'r')
        end
        title("Wire angle Human side")
        xlabel("Experiment progress [ % ]"), ylabel("Angle between the center marker horizontal [ deg ]")
        hold off
        subplot(2,1,2), grid on, hold on
        if strcmp(people.Mano(i),"R") == 1
            plot(x,filteredRightAngle,'r')
        else
            plot(x,filteredLeftAngle,'r')
        end
        title("Wire angle Robot side")
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

save('ImageProcessingData',"totalLength","HumanAngle","RobotAngle","HumanLength","RobotLength");

%% Scatter plotting
fprintf("\nScatter plotting...")
mkdir ../ProcessedData/Scatters/0.ImageProcessing
% fig4 = figure('Name','WireLength scatter');
% fig4.WindowState = 'maximized';
% grid on, hold on
% scatter(,MarkerDimension,clearBlue,'filled')
% plot_mean_stdError(meanRtoH_space(logical([0,0,logicalIntervalPeaks])),1,nearHand(logicalIntervalPeaks),MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,'b--')
% title("Human pulling phase space duration")
% xlabel("Space distance [ cm ]"), ylabel("Near-Hand Effect[ ms ]")
% legend('Human Pulling phase','Mean','Trend','Standard Error')
% hold off
% 
% 
% if IMAGE_SAVING
%     pause(PAUSE_TIME);
%     exportgraphics(fig4,"..\ProcessedData\Scatters\4.PullingPhases\HumanPhaseSpaceDuration.png")
%     close(fig4);
% end

fprintf("\nEvaluation completed...")
