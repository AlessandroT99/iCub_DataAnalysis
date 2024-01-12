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
% WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details

% TODO: 
% - find a way to save the two scrollable plots as image.
% - start the further analysis on the force

 function dataPlotter(TELEGRAM_LOG, POS_AVOIDING_TESTS, FORCE_AVOIDING_TESTS)
    tStart = tic;
    
    % Suppress the warning about creating folder that already exist
    warning('OFF','MATLAB:MKDIR:DirectoryExists');
    
    % Importing this type of data raise a warning for the variable names
    % settings, which I overwrite, so I just shut it off in the following
    warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');
    
    % While importing iCub model, a warning of home position is showed, but
    % does not concern with it use, so it has been suppressed.
    warning('OFF','robotics:robotmanip:joint:ResettingHomePosition');
    
    %% Simulation parameter
    BIG_PLOT_ENABLE = 0;        % Allows to the plotting of the two big gender plot 
    PAUSE_PEOPLE = -5;          % Array containing number of people for which the synch shall put in pause to handle graphs (-5 == noone pause)
    AXIS_3PLOT = 1;             % Allows plotting all the 3 force and position components
    BASELINE_NUMBER = 2;        % Number of baseline in the simulation
    BaseLineEvaluationDone = 0; % Goes to 1 when the base line has been evaluated
    posBaseline = [];           % Variable where the pos baseline is saved
    baselineBoundaries = zeros(BASELINE_NUMBER,2); % Used to save the boundaries of the baseline and print them into the positions [Rmax,Lmax;Rmin,Lmin]

    % Logging instants in telegram
    if TELEGRAM_LOG
        pyrunfile("telegramLogging.py",txtMsg="[STARTING] HRI Data analysis - Starting simulation...",TEXT=1,filePath="");
    end
    
    %% Baselines input data
    NEW_BASELINES = 0;          % Change the input of the default baselines if 1
    if NEW_BASELINES
        % Remember to create manually the folders for containing this outputs!
        BaselineMainDataFolder = "..\iCub_InputData\NewBaselines"; % Name of the main folder containing all baselines data
        LbaseLinePath = "B_SX_Soft_NewSensor";  % Name of the folder containing the file of the L baseline
        RbaseLinePath = "B_DX_Soft_NewSensor";  % Name of the folder containing the file of the R baseline
        BaseLineOutputName_L = "NewBaselines\B_SX_Soft_NewSensor";   % The initial part of the name of the L baseline output
        BaseLineOutputName_R = "NewBaselines\B_DX_Soft_NewSensor";   % The initial part of the name of the R baseline output
    else
        BaselineMainDataFolder = "..\iCub_InputData"; % Name of the main folder containing all baselines data
        LbaseLinePath = "P0_L_Base";  % Name of the folder containing the file of the L baseline
        RbaseLinePath = "P0_R_Base";  % Name of the folder containing the file of the R baseline
        BaseLineOutputName_L = "B_SX_Base";   % The initial part of the name of the L baseline output
        BaseLineOutputName_R = "B_DX_Base";   % The initial part of the name of the R baseline output
    end
    
    %% Input data
    fprintf("Simulation starting up...\n")
    
    numPeople = 32+BASELINE_NUMBER; 
    people = readtable("..\iCub_InputData\Dati Personali EXP2.xlsx");
    people = people(1:numPeople-BASELINE_NUMBER,:);

    FxLeftMean = -11.6261;

    % The following command is part of the robotic toolbox
    % Whilst the iCub model has been downloaded from
    % "https://github.com/robotology/icub-models"
    fprintf("Importing input data and simulation models...\n\n")
    % Has been chosen the Paris01 iCub due to the low number of reference
    % frames included, in fact almost all the other models included also the
    % skin reference frames, which where not usefull for this purpose.
    iCub = importrobot("..\icub-models\iCub\robots\iCubLisboa01\model.urdf");
    % Modify numDoFTBase number into analyticalInverseKinematics() 
    aik = analyticalInverseKinematics(iCub);
    opts = showdetails(aik);
    % % Code use to identify the unusefull warning
    % [msg,warnID] = lastwarn
    % show(iCub);
    
    %% Output initialization
    totalMeanHtoR = 0;
    totalMeanRtoH = 0;
    evaluatedPeople = 0;
    
    notConsideredValue = 1e3; % Value at which a variable is initialized, and used to known is it has been written
    experimentDuration = notConsideredValue.*ones(1,numPeople);
    meanHtoR_time = notConsideredValue.*ones(1,numPeople);
    meanRtoH_time = notConsideredValue.*ones(1,numPeople);
    meanHtoR_space = notConsideredValue.*ones(1,numPeople);
    meanRtoH_space = notConsideredValue.*ones(1,numPeople);
    phaseTimeDifference = notConsideredValue.*ones(1,numPeople);
    nMaxPeaks = notConsideredValue.*ones(1,numPeople);
    nMinPeaks = notConsideredValue.*ones(1,numPeople);
    maxPeaksAverage = notConsideredValue.*ones(1,numPeople);
    minPeaksAverage = notConsideredValue.*ones(1,numPeople);
    stdPos = notConsideredValue.*ones(1,numPeople);
    meanPos = notConsideredValue.*ones(1,numPeople);
    movementRange = notConsideredValue.*ones(numPeople,100);
    maxMinAverageDistance = notConsideredValue.*ones(1,numPeople);
    maxPeaksVariation = notConsideredValue.*ones(numPeople,100);
    minPeaksVariation = notConsideredValue.*ones(numPeople,100);
    peaksInitialAndFinalVariation = notConsideredValue.*ones(1,numPeople);
    synchroEfficiency = notConsideredValue.*ones(numPeople,100);
    posAPeaksStd = notConsideredValue.*ones(1,numPeople);
    posBPeaksStd = notConsideredValue.*ones(1,numPeople);
    posAPeaksmean = notConsideredValue.*ones(1,numPeople);
    posBPeaksmean = notConsideredValue.*ones(1,numPeople);
    ROM = notConsideredValue.*ones(1,numPeople);
    testedPeople = [];
    forceTestedPeople = [];
    midVelocityMean = notConsideredValue.*ones(1,numPeople);
    midVelocityStd = notConsideredValue.*ones(1,numPeople);
    HtoR_relativeVelocity = cell(1,numPeople);
    RtoH_relativeVelocity = cell(1,numPeople);

    meanTrend = notConsideredValue.*ones(1,numPeople);
    lowSlope = notConsideredValue.*ones(1,numPeople);
    upSlope = notConsideredValue.*ones(1,numPeople);
    peaksAmplitude = cell(1,numPeople);
    meanXforce = notConsideredValue.*ones(1,numPeople);
    
    %% Usefull data to be saved
    fprintf("\nStarting the data analysis...\n")
    
    [nR, nL, nM, nF, plotPosM, plotPosF, personWhoFeelsFollowerOrLeader] = parametersUpdate(people); 
    
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
    
    for i = 1:numPeople
        if BaseLineEvaluationDone == 0
            if i == 1
                posFilePath = strjoin([BaselineMainDataFolder,"\positions\leftHand\",LbaseLinePath,"\data.log"],"");
                forceFilePath = strjoin([BaselineMainDataFolder,"\forces\leftArm\",LbaseLinePath,"\data.log"],"");
                BaseLineOutputName = BaseLineOutputName_L;
            else
                if i == 2
                    posFilePath = strjoin([BaselineMainDataFolder,"\positions\rightHand\",RbaseLinePath,"\data.log"],"");
                    forceFilePath = strjoin([BaselineMainDataFolder,"\forces\rightArm\",RbaseLinePath,"\data.log"],"");
                    BaseLineOutputName = BaseLineOutputName_R;
                end
            end
            BaselineFilesParameters = [LbaseLinePath,RbaseLinePath,BaseLineOutputName,BaselineMainDataFolder]; % just the union of the four up for faster use and function passing 
    
            posDataSet = readtable(posFilePath);
            forceDataSet = readtable(forceFilePath);
            
            posDataSet = renamevars(posDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9"], ...
                                               ["Counter","Time","xPos","yPos","zPos","ax","ay","az","theta"]);
            forceDataSet = renamevars(forceDataSet,["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8"], ...
                                           ["Counter","Time","Fx","Fy","Fz","Tx","Ty","Tz"]);
        
            numP = i-BASELINE_NUMBER-1;
    
        else
            numP = i-BASELINE_NUMBER;
            % Find the correct data from the ones sent by iCub
            [posDataSet, forceDataSet] = fileReader(people, numP);
        end
    
        % Before iterating check that the person has not an invalid dataset
        % which has to be skipped
        if isempty(posDataSet) == 0 && isempty(forceDataSet) == 0 && sum(find(numP==POS_AVOIDING_TESTS)) == 0
            % Adjusting the Fx mean value due to the hand used, so only if
            % is a test with the robot hand R or if it is the baseline
            % number 2, also made with the right hand of the robot
            if i == 2 && strcmp(RbaseLinePath, "P0_R_Base") == 1
                forceDataSet.Fx = forceDataSet.Fx - mean(forceDataSet.Fx) + FxLeftMean;
            else
                if numP > 0
                    if strcmp(people.Mano(numP), "L") == 1
                        forceDataSet.Fx = forceDataSet.Fx - mean(forceDataSet.Fx) + FxLeftMean;
                    end
                end
            end

            personTime = tic;
            if BaseLineEvaluationDone == 0
                if TELEGRAM_LOG
                    pyrunfile("telegramLogging.py",txtMsg=strjoin(["[INFO] Evaluation of Baseline n.",num2str(i)],""),TEXT=1,filePath="");
                end
                fprintf("\n- Elaborating data from Baseline test ");
                if i == 1
                    personParam = ["Baseline Test","  ","-","  Robot Hand: ","L"];
                else
                    personParam = ["Baseline Test","  ","-","  Robot Hand: ","R"];
                end
                fprintf("N. %d...\n",i);
            else
                if TELEGRAM_LOG
                    pyrunfile("telegramLogging.py",txtMsg=strjoin(["[INFO] Evaluation of participant n.",num2str(numP)],""),TEXT=1,filePath="");            
                end
                testedPeople = [testedPeople,i-BASELINE_NUMBER];
                if sum(find(numP == FORCE_AVOIDING_TESTS)) == 0
                    forceTestedPeople = [forceTestedPeople,i-BASELINE_NUMBER];
                end
                evaluatedPeople = evaluatedPeople + 1;
                personParam = ["Gender: ", people.Genere(numP), "  -  ", "Human Hand: ", people.Mano(numP), "  -  ", "Age: ", people.Et_(i-BASELINE_NUMBER)];
                fprintf("\n- Elaborating data from person N. %d...\n",numP);
            end
    
            % Plots the 3 axis components of force and position
            if AXIS_3PLOT
                tic
                fprintf("   .Plotting all components of position and force...")
                print3Axis(posDataSet, forceDataSet,numP, BaselineFilesParameters);
                fprintf("               Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
            end
    
            % Synchronizing the two dataset to show them in a single plot
            [synchPosDataSet, synchForceDataSet, baselineBoundaries, midVelocityMean(i), midVelocityStd(i), meanXforce(i)] = ...
              synchSignalsData(iCub, aik, opts, posDataSet, forceDataSet, numP, ...
                personParam,PAUSE_PEOPLE,baselineBoundaries, BaselineFilesParameters, TELEGRAM_LOG, FORCE_AVOIDING_TESTS, notConsideredValue);   
    
            if BIG_PLOT_ENABLE && BaseLineEvaluationDone
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
            tic
            if sum(find(numP == FORCE_AVOIDING_TESTS)) >= 1
                fprintf("   .Skipping the combination of force and position...")
            else
                fprintf("   .Plotting the combination of force and position...")
                combinePosForcePlots(synchPosDataSet, synchForceDataSet, numP, ...
                    personParam,BIG_PLOT_ENABLE, BaselineFilesParameters);
            end
            fprintf("              Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
            % Usefull data for further analysis
            mkdir ..\iCub_ProcessedData\SimulationData;
            if numP < 0
                fileName = strjoin(["..\iCub_ProcessedData\SimulationData\",BaseLineOutputName],"");
            else
                fileName = strjoin(["..\iCub_ProcessedData\SimulationData\P",num2str(numP)],"");
            end
            save(fileName, "synchPosDataSet", "numP", 'personParam');
    
            % Position further analysis
            tic
            fprintf("   .Computing further analysis on the position...")
            [experimentDuration(i), meanHtoR_time(i), meanRtoH_time(i), meanHtoR_space(i), meanRtoH_space(i), phaseTimeDifference(i), ...
                nMaxPeaks(i), nMinPeaks(i), maxPeaksAverage(i), minPeaksAverage(i), stdPos(i), meanPos(i), ...
                movementRange(i,:), maxMinAverageDistance(i), maxPeaksVariation(i,:), minPeaksVariation(i,:), ...
                peaksInitialAndFinalVariation(i), synchroEfficiency(i,:), posAPeaksStd(i), ...
                posBPeaksStd(i), posAPeaksmean(i), posBPeaksmean(i), ROM(i), HtoR_relativeVelocity{i}, RtoH_relativeVelocity{i}] = ...
                posFurtherAnalysis(synchPosDataSet,numP, personParam, posBaseline, BaselineFilesParameters);
            fprintf("                  Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
            
            % Force further analysis on left hand of the robot or the baseline with robot left hand
            tic
            if sum(find(numP == FORCE_AVOIDING_TESTS)) >= 1
                fprintf("   .Skipping further analysis on the force... ")
            else
                fprintf("   .Computing further analysis on the force...")
                [meanTrend(i), lowSlope(i), upSlope(i), peaksAmplitude{i}] ...
                    = forceFurtherAnalysis(synchForceDataSet, numP, personParam, BaselineFilesParameters);
            end
            fprintf("                     Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))

            % Output parameters collection
            if BaseLineEvaluationDone
                totalMeanHtoR = totalMeanHtoR + meanHtoR_time(i);  
                totalMeanRtoH = totalMeanRtoH + meanRtoH_time(i);
            else 
                if BASELINE_NUMBER == i
                    BaseLineEvaluationDone = 1;
                end
                posBaseline{i} = synchPosDataSet(:,2); % Save the baseline sets
            end
    
            fprintf("The total computational time for this test has been %s minutes.\n",duration(0,0,toc(personTime),'Format','mm:ss.SS'))
            
            if TELEGRAM_LOG
                if i == 1
                    pyrunfile("telegramLogging.py",txtMsg=strjoin(["[INFO] Baseline n.",num2str(i)," completed"],""),TEXT=1,filePath="");
                    pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\PositionVisualizing\",BaseLineOutputName_L,".png"],""))
                    pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\ForceSynchronization\",BaseLineOutputName_L,".png"],""))
                else
                    if i == 2
                        pyrunfile("telegramLogging.py",txtMsg=strjoin(["[INFO] Baseline n.",num2str(i)," completed"],""),TEXT=1,filePath="");
                        pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\PositionVisualizing\",BaseLineOutputName_R,".png"],""))
                        pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\ForceSynchronization\",BaseLineOutputName_R,".png"],""))
                    else
                        pyrunfile("telegramLogging.py",txtMsg=strjoin(["[INFO] Participant n.",num2str(numP)," completed"],""),TEXT=1,filePath="");
                        pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\PositionVisualizing\P",num2str(numP),".png"],""))
                        if sum(find(numP == FORCE_AVOIDING_TESTS)) == 0
                            pyrunfile("telegramLogging.py",txtMsg="",TEXT=0,filePath=strjoin(["..\iCub_ProcessedData\ForceSynchronization\P",num2str(numP),".png"],""))
                        end
                    end
                end
            end
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
        % exportgraphics(figM,'iCub_ProcessedData\Male analysis output.png')
        % exportgraphics(figF,'iCub_ProcessedData\Female analysis output.png') 
        % fprintf("Image saving done\n")
        % close all
    end
    
    %% Output parameters evaluation
    
    totalMeanHtoR = totalMeanHtoR/evaluatedPeople;  
    totalMeanRtoH = totalMeanRtoH/evaluatedPeople;
    
    % In case of not evaluated test, remove the indices not used in the
    % output variables
    experimentDuration = experimentDuration(experimentDuration~=notConsideredValue);
    meanHtoR_time = meanHtoR_time(meanHtoR_time~=notConsideredValue);
    meanRtoH_time = meanRtoH_time(meanRtoH_time~=notConsideredValue);
    meanHtoR_space = meanHtoR_space(meanHtoR_space~=notConsideredValue);
    meanRtoH_space = meanRtoH_space(meanRtoH_space~=notConsideredValue);
    phaseTimeDifference = phaseTimeDifference(phaseTimeDifference~=notConsideredValue);
    nMaxPeaks = nMaxPeaks(nMaxPeaks~=notConsideredValue);
    nMinPeaks = nMinPeaks(nMinPeaks~=notConsideredValue);
    maxPeaksAverage = maxPeaksAverage(maxPeaksAverage~=notConsideredValue);
    minPeaksAverage = minPeaksAverage(minPeaksAverage~=notConsideredValue);
    stdPos = stdPos(stdPos~=notConsideredValue);
    meanPos = meanPos(meanPos~=notConsideredValue);
    movementRange = movementRange(movementRange(:,1)~=notConsideredValue,:);
    maxMinAverageDistance = maxMinAverageDistance(maxMinAverageDistance~=notConsideredValue);
    maxPeaksVariation = maxPeaksVariation(maxPeaksVariation(:,1)~=notConsideredValue,:);
    minPeaksVariation = minPeaksVariation(minPeaksVariation(:,1)~=notConsideredValue,:);
    peaksInitialAndFinalVariation = peaksInitialAndFinalVariation(peaksInitialAndFinalVariation~=notConsideredValue);
    synchroEfficiency = synchroEfficiency(synchroEfficiency(:,1)~=notConsideredValue,:);
    midVelocityMean = midVelocityMean(midVelocityMean~=notConsideredValue);
    midVelocityStd = midVelocityStd(midVelocityStd~=notConsideredValue);
    HtoR_relativeVelocity = HtoR_relativeVelocity(~cellfun('isempty',HtoR_relativeVelocity));
    RtoH_relativeVelocity = RtoH_relativeVelocity(~cellfun('isempty',RtoH_relativeVelocity));

    meanTrend = meanTrend(meanTrend~=notConsideredValue);
    lowSlope = lowSlope(lowSlope~=notConsideredValue);
    upSlope = upSlope(upSlope~=notConsideredValue);
    meanXforce = meanXforce(meanXforce~=notConsideredValue);
    peaksAmplitude = peaksAmplitude(~cellfun('isempty',peaksAmplitude));

    % All the following values are already in cm
    posAPeaksStd = posAPeaksStd(posAPeaksStd~=notConsideredValue).*100;
    posBPeaksStd = posBPeaksStd(posBPeaksStd~=notConsideredValue).*100;
    posAPeaksmean = posAPeaksmean(posAPeaksmean~=notConsideredValue).*100;
    posBPeaksmean = posBPeaksmean(posBPeaksmean~=notConsideredValue).*100;
    ROM = ROM(ROM~=notConsideredValue).*100;
    
    if TELEGRAM_LOG
        pyrunfile("telegramLogging.py",txtMsg="[INFO] Further position analysis started...",TEXT=1,filePath="");
    end

    %% Further analysis data saving
    save ..\iCub_ProcessedData\furtherAnalysisData;
%     load ..\iCub_ProcessedData\furtherAnalysisData;

    %% Position further analysis plotting
    tic
    fprintf("\nPlotting position further analysis results...")
    plotPositionFurtherAnalysis(experimentDuration, meanHtoR_time, meanRtoH_time, meanHtoR_space, meanRtoH_space, phaseTimeDifference, ...
                                    nMaxPeaks, nMinPeaks, maxPeaksAverage, minPeaksAverage, stdPos, meanPos, ...
                                    movementRange, maxMinAverageDistance, maxPeaksVariation, minPeaksVariation, ...
                                    peaksInitialAndFinalVariation, synchroEfficiency, BASELINE_NUMBER, HtoR_relativeVelocity, RtoH_relativeVelocity, ...
                                    posAPeaksStd, posBPeaksStd, posAPeaksmean, posBPeaksmean, midVelocityMean, midVelocityStd, testedPeople, ROM, people.Delta_RTs_(testedPeople), meanXforce);
    fprintf("                  Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))
    
    %% Force further analysis
    tic
    fprintf("\nPlotting force further analysis results...")
    plotForceFurtherAnalysis(forceTestedPeople, meanTrend, lowSlope, upSlope, peaksAmplitude);
    fprintf("                     Completed in %s minutes\n",duration(0,0,toc,'Format','mm:ss.SS'))

    %% Conclusion of the main
    close all;
    
    fprintf("\nProcess of analysis complete!\n")
    overallTime = duration(0,0,toc(tStart),'Format','dd:hh:mm:ss.SS');
    if TELEGRAM_LOG
        pyrunfile("telegramLogging.py",txtMsg=strjoin(["[COMPLETION] Simulation completed in ", num2str(overallTime), " days."],""),TEXT=1,filePath="");
    end
    overallTime = duration(0,0,toc(tStart),'Format','hh:mm:ss.SS');
    fprintf("The simulation has been executed in %s hours\n",overallTime)
end
