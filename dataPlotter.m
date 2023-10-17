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

clear all, close all,  clc

tic
fprintf("Starting the data analysis...\n")

% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');

% TODO: 
% - find a way to save the two scrollable plots as image.
% - start the further analysis on the force
% - plot scatter plots as further analysis output
% - Define the force using Denavit-Hartenberg

%% Input data
numPeople = 32; 
people = readtable("..\Dati Personali EXP2.xlsx");
people = people(1:numPeople,:);

%% Output initialization
totalMeanHtoR = 0;
totalMeanRtoH = 0;
evaluatedPeople = 0;

notConsideredValue = 1e3; % Value at which a variable is initialized, and used to known is it has been written
experimentDuration = notConsideredValue.*ones(1,numPeople);
meanHtoR = notConsideredValue.*ones(1,numPeople);
meanRtoH = notConsideredValue.*ones(1,numPeople);
nMaxPeaks = notConsideredValue.*ones(1,numPeople);
nMinPeaks = notConsideredValue.*ones(1,numPeople);
maxPeaksAverage = notConsideredValue.*ones(1,numPeople);
minPeaksAverage = notConsideredValue.*ones(1,numPeople);
stdPos = notConsideredValue.*ones(1,numPeople);
meanPos = notConsideredValue.*ones(1,numPeople);
movementRange = notConsideredValue.*ones(1,numPeople);
maxMinAverageDistance = notConsideredValue.*ones(1,numPeople);
peaksVariation = notConsideredValue.*ones(1,numPeople);
peaksInitialAndFinalVariation = notConsideredValue.*ones(1,numPeople);
cableTensionEfficiency = notConsideredValue.*ones(1,numPeople);

%% Simulation parameter
BIG_PLOT_ENABLE = 0; % Allows to the plotting of the two big gender plot 
PAUSE_PEOPLE = 0;    % Array containing number of people for which the synch 
                     % shall put in pause to handle graphs

%% Usefull data to be saved
[nDX, nSX, nM, nF, plotPosM, plotPosF] = parametersUpdate(people); 

% Create figures for subplots
if BIG_PLOT_ENABLE
    figM = figure("Name","Male analysis");
    set(figM, 'Color', 'White', 'Unit', 'Normalized', 'Position', [0.25,0.2,0.6,0.6]); 
    figF = figure("Name","Female analysis");
    set(figF, 'Color', 'White', 'Unit', 'Normalized', 'Position', [0.25,0.2,0.6,0.6]);
    
    % Parameters of the figures
    nRow = 2;
    nCol = 2;
    
    actualNM = 0; % Number of males already analyzed
    actualNF = 0; % number of females already analyzed
end

for i = 1:height(people)
    % Find the correct data from the ones sent by iCub
    [posDataSet, forceDataSet] = fileReader(people, i);

%     % Has been evaluated that the force RS has to be rotated and translated
%     % into the EF RS.
%     forceDataSet = forceTransformation(forceDataSet);

    % Before iterating check that the person has not an invalid dataset
    % which has to be skipped
    if isempty(posDataSet) == 0 && isempty(forceDataSet) == 0
        evaluatedPeople = evaluatedPeople + 1;
        personParam = ["Gender: ", people.Genere(i), "  -  ", "Human Hand: ", people.Mano(i), "  -  ", "Age: ", people.Et_(i)];
        fprintf("\n- Elaborating data from person N. %d...\n",i);

        % Synchronizing the two dataset to show them in a single plot
        [synchPosDataSet, synchForceDataSet] = ...
          synchSignalsData(posDataSet, forceDataSet, i, ...
            personParam,PAUSE_PEOPLE);   
        
        if BIG_PLOT_ENABLE
            if strcmp(people.Genere(i),"M") == 1
                % Defining the subplot in the males figure
                actualNM = actualNM + 1;
                figure(figM);
                h = scrollsubplot(2,2,plotPosM(actualNM));
            else 
                % Defining the subplot in the females figure
                actualNF = actualNF + 1;
                figure(figF);    
                h = scrollsubplot(2,2,plotPosF(actualNF));
            end
    
            p = get(gca, 'Position');
            rowH = 0.58/nRow;
            set(gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None');
            axes('Position', [p(1:3), rowH]);
        end

        % Plot results obtained previosly in a single involved subplot
        % depending on the gender and save them separately for each test
        combinePosForcePlots(synchPosDataSet, synchForceDataSet, i, ...
            personParam,BIG_PLOT_ENABLE);

        %% Usefull data for further analysis
        mkdir ..\ProcessedData\SimulationData;
        fileName = strjoin(["..\ProcessedData\SimulationData\P",num2str(i)],"");
        save(fileName, "synchPosDataSet", "i", 'personParam');

        %% Further analysis
        [experimentDuration(i), meanHtoR(i), meanRtoH(i), nMaxPeaks(i), nMinPeaks(i), ...
            maxPeaksAverage(i), minPeaksAverage(i), stdPos(i), meanPos(i), ...
            movementRange(i), maxMinAverageDistance(i), peaksVariation(i), ...
            peaksInitialAndFinalVariation(i), cableTensionEfficiency(i)] = ...
            posFurtherAnalysis(synchPosDataSet,i, personParam);
        forceFurtherAnalysis(synchForceDataSet,i,personParam);
    
        % Output parameters collection
        totalMeanHtoR = totalMeanHtoR + meanHtoR(i);  
        totalMeanRtoH = totalMeanRtoH + meanRtoH(i);
    end
end

%% Gender plots last touch
if BIG_PLOT_ENABLE
    figure(figM);
    % Add legend for males figure
    Lgnd = legend('show');
    Lgnd.Position(1) = 0.01;
    Lgnd.Position(2) = 0.4;
    % Add a general title to the figure
    axes('Position', [0, 0.95, 1, 0.05] ) ;
    set(gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
    text(0.5, 0, 'Male data analysis', 'FontSize', 14', 'FontWeight', 'Bold', ...
         'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
    
    
    figure(figF);  
    % Add legend for females figure
    Lgnd = legend('show');
    Lgnd.Position(1) = 0.01;
    Lgnd.Position(2) = 0.4;
    % Add a general title to the figure
    axes('Position', [0, 0.95, 1, 0.05]);
    set(gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None');
    text(0.5, 0, 'Female data analysis', 'FontSize', 14', 'FontWeight', 'Bold', ...
         'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom');
    
    % Print the images in order to see them more easily
    % fprintf("\n\nStart image saving...\n")
    % exportgraphics(figM,'ProcessedData\Male analysis output.png')
    % exportgraphics(figF,'ProcessedData\Female analysis output.png') 
    % fprintf("Image saving done\n")
    % close all
end

%% Output parameters evaluation
totalMeanHtoR = totalMeanHtoR/evaluatedPeople;  
totalMeanRtoH = totalMeanRtoH/evaluatedPeople;

% In case of not evaluated test, remove the indices not used in the
% output variables
experimentDuration = experimentDuration(experimentDuration~=notConsideredValue);
meanHtoR = meanHtoR(meanHtoR~=notConsideredValue);
meanRtoH = meanRtoH(meanRtoH~=notConsideredValue);
nMaxPeaks = nMaxPeaks(nMaxPeaks~=notConsideredValue);
nMinPeaks = nMinPeaks(nMinPeaks~=notConsideredValue);
maxPeaksAverage = maxPeaksAverage(maxPeaksAverage~=notConsideredValue);
minPeaksAverage = minPeaksAverage(minPeaksAverage~=notConsideredValue);
stdPos = stdPos(stdPos~=notConsideredValue);
meanPos = meanPos(meanPos~=notConsideredValue);
movementRange = movementRange(movementRange~=notConsideredValue);
maxMinAverageDistance = maxMinAverageDistance(maxMinAverageDistance~=notConsideredValue);
peaksVariation = peaksVariation(peaksVariation~=notConsideredValue);
peaksInitialAndFinalVariation = peaksInitialAndFinalVariation(peaksInitialAndFinalVariation~=notConsideredValue);
cableTensionEfficiency = cableTensionEfficiency(cableTensionEfficiency~=notConsideredValue);

%% Further analysis plotting
plotFurtherAnalysis(experimentDuration, meanHtoR, meanRtoH, nMaxPeaks, nMinPeaks, ...
                                maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                movementRange, maxMinAverageDistance, peaksVariation, ...
                                peaksInitialAndFinalVariation, cableTensionEfficiency);

%% Conclusion of the main
close all;

fprintf("\nProcess of analysis complete!\n")
toc