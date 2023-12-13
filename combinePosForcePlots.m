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
% - Add the boundaries of position in order to recognise human side and
%   robot side

function combinePosForcePlots(synchedPosSet, synchedForceSet, numPerson, personParameters,BIG_PLOT_ENABLE,BaselineFilesParameters)
% The following function is used in order to plot togheter the force and
% the position signal, firstly in the gender subplot, then in a single
% figure that will be than saved in memory

% BIG_PLOT_ENABLE Allows to the plotting of the two big gender plot 

    %% Initial parameters
    defaultTitleName = strjoin(["Test N. ",num2str(numPerson), "  -  ", personParameters],"");
    IMAGE_SAVING = 1; % Put to 1 in order to save the main plots
    PAUSE_TIME = 2;

    %% Position and force combining
    % Firstly the trend of the two signals is evaluated getting an average of
    % little sub-set of the signal point
    cuttedElapsedTime = synchedPosSet(:,1);
    pointsPerMean = 100;
    cnt = pointsPerMean+1;
    i = 1;
    % The following while is in charge to cycle every sub-set of the involved
    % signal, until the end of the vector dimension
    while(cnt<length(cuttedElapsedTime))
        posTrendPoints(i) = mean(synchedPosSet(cnt-pointsPerMean:cnt,2));
        forceTrendPoints(i) = mean(synchedForceSet(cnt-pointsPerMean:cnt,2));
        trendLineTime(i) = cuttedElapsedTime(cnt);
        cnt = cnt+pointsPerMean;
        i = i+1;
    end
    % A last iteration is made in order to get one last point in a sub-set
    % composed of the remaing samples
    posTrendPoints(i) = mean(synchedPosSet(end-pointsPerMean:end,2));
    forceTrendPoints(i) = mean(synchedForceSet(end-pointsPerMean:end,2));
    trendLineTime(i) = cuttedElapsedTime(end);
    
    % Then the average points are fitted in order to get a trend line for each
    % signal
    fittingGrade = 1;
    pp = polyfit(trendLineTime,posTrendPoints,fittingGrade);
    posTrend = polyval(pp,cuttedElapsedTime);
    pf = polyfit(trendLineTime,forceTrendPoints,fittingGrade);
    forceTrend = polyval(pf,cuttedElapsedTime);
    
    highestValue = max(synchedForceSet(:,2)); 
    lowestValue = min(synchedForceSet(:,2));

    %% Plot results into the subplot
    if BIG_PLOT_ENABLE
        xlabel("Elapsed time [ f_s = 100 Hz ]")
        grid on, hold on
        
        yyaxis left
        hold on
        plot(cuttedElapsedTime,100.*synchedPosSet(:,2),'k-','DisplayName','Position_y')
        plot(cuttedElapsedTime,100.*posTrend,'k--','LineWidth',2, ...
            'DisplayName','Position Trend')
        ylabel("Position [ cm ]")
        hold off
        
        yyaxis right
        hold on
        plot(cuttedElapsedTime,synchedForceSet(:,2),'r-','DisplayName','Force_y')
        plot(cuttedElapsedTime,forceTrend,'r--','LineWidth',2, ...
            'DisplayName','Force Trend')
        ylim([lowestValue,highestValue])
        ylabel("Force [N]")
        hold off
        
        legend('show')
        title(defaultTitleName,"Position and force comparison")
    end

    %% Plot results into a figure
    fig4 = figure('Name','Position and Force comparison');
    fig4.WindowState = 'maximized';
    xlabel("Elapsed time [ f_s = 100 Hz ]")
    grid on, hold on
    
    yyaxis left
    hold on
    plot(cuttedElapsedTime,100.*synchedPosSet(:,2),'k-','DisplayName','Position_y')
    plot(cuttedElapsedTime,100.*posTrend,'k--','LineWidth',2, ...
        'DisplayName','Position Trend')
    ylabel("Position [ cm ]")
    hold off
    
    yyaxis right
    hold on
    plot(cuttedElapsedTime,synchedForceSet(:,2),'r-','DisplayName','Force_y')
    plot(cuttedElapsedTime,forceTrend,'r--','LineWidth',2, ...
        'DisplayName','Force Trend')
    ylim([lowestValue,highestValue])
    ylabel("Force [N]")
    hold off
    
    legend('show')
    title(defaultTitleName,"Position and force comparison")
    
    % Figure saving for force and position comparison
    if IMAGE_SAVING
        mkdir ..\iCub_ProcessedData\ForcePositionComparison;
        if numPerson < 0
            splitted = strsplit(BaselineFilesParameters(3),'\');
            if length(splitted) > 1
                mkdir(strjoin(["..\iCub_ProcessedData\ForcePositionComparison",splitted(1:end-1)],'\'));
            end
            path = strjoin(["..\iCub_ProcessedData\ForcePositionComparison\",BaselineFilesParameters(3),".png"],"");
        else
            path = strjoin(["..\iCub_ProcessedData\ForcePositionComparison\P",num2str(numPerson),".png"],"");
        end
        pause(PAUSE_TIME);
        exportgraphics(fig4,path)
        close(fig4);
    end
end
