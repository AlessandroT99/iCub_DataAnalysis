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
% - end the further analysis on the position
% - start the further analysis on the force
% - plot scatter plots as further analysis output

%% Input data
numPeople = 32; 
people = readtable("Dati Personali EXP2.xlsx");
people = people(1:numPeople,:);

%% Output initialization
totalMeanHtoR = 0;
totalMeanRtoH = 0;
evaluatedPeople = 0;

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

    % Before iterating check that the person has not an invalid dataset
    % which has to be skipped
    if isempty(posDataSet) == 0 && isempty(forceDataSet) == 0
        evaluatedPeople = evaluatedPeople + 1;
        personParam = ["Human Hand: ", people.Mano(i), "  -  ", "Age: ", people.Et_(i)];
        fprintf("\n- Elaborating data from person N. %d...\n",i);

        % Synchronizing the two dataset to show them in a single plot
        [synchPosDataSet, synchForceDataSet] = ...
          synchSignalsData(posDataSet, forceDataSet, i, ...
            ["Gender: ", people.Genere(i), "  -  ", personParam],PAUSE_PEOPLE);   
        
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
            ["Gender: ", people.Genere(i), "  -  ", personParam],BIG_PLOT_ENABLE);

        %% Further analysis
        [meanHtoR, meanRtoH] = posFurtherAnalysis(synchPosDataSet,i, ...
            ["Gender: ", people.Genere(i), "  -  ", personParam]);
        forceFurtherAnalysis(synchForceDataSet,i,["Gender: ", people.Genere(i), "  -  ", personParam]);
    
        % Output parameters collection
        totalMeanHtoR = totalMeanHtoR + meanHtoR;  
        totalMeanRtoH = totalMeanRtoH + meanRtoH;
    end
end

%% Output parameters evaluation
totalMeanHtoR = totalMeanHtoR/evaluatedPeople;  
totalMeanRtoH = totalMeanRtoH/evaluatedPeople;

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

close all;

fprintf("\nProcess of analysis complete!\n")
toc