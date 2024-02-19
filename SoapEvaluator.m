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

% This software aim is to analyzed the ata from the manual reading of
% measures on the soap bars used during the experiment.

clear all, close all, clc
format compact

% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');
% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

mkdir ..\iCub_ProcessedData\Scatters\0.SoapEvaluation

%% Input Data
numPeople = 20; 
people = readtable("..\iCub_InputData\Dati Personali EXP3.xlsx");
people = people(1:numPeople,:);

soapWidth = people.WidthSoap;               % mm
soapHeight = people.HeightSoap;          % mm

% We got a triangle were:
% c is soap cut line width 
% b is soap cut indentation line
% a is the line of deep of the cut in the human side w.r.t. the c line
%    c
%   --- 
% a | / b
%   |/
% theta is the wanted angle between c and b

%% Indetation angle evaluation
a = people.DeltaIndent;
c = people.CutWidth;
b = sqrt(a.^2 + c.^2);
% c = b*cos(theta)
angle = acos(c./b).*180./pi; % DEGREES

%% Plot results
fig1 = figure('Name','Right hand soap indentation');
sgtitle('Soap Indentation - Right Hand tests'), hold on
fig2 = figure('Name','Left hand soap indentation');
sgtitle('Soap Indentation - Left Hand tests'), hold on
rPeople = 0;
lPeople = 0;
removedArea = zeros(1,numPeople);
maxCutArea = zeros(1,numPeople);
totalArea = zeros(1,numPeople);
removedAreaPercentage = zeros(1,numPeople);
for i = 1:numPeople
    if people.RobotSide(i) < people.HumanSide(i)
        angle(i) = -angle(i);
    end
    
    if strcmp(people.Mano(i),"R") == 1
        rPeople = rPeople + 1;
        figure(fig1)
        subplot(5,3,rPeople), hold on
        plot([0,people.CutWidth(i)],[people.RobotSide(i),people.HumanSide(i)],'r-')
        plot([0,soapWidth(i)],[soapHeight(i),soapHeight(i)], 'k-')
        plot([0,0],[0,soapHeight(i)], 'k-')
        plot([soapWidth(i),soapWidth(i)],[0,soapHeight(i)], 'k-')
        text(5,5,"R")
        text(soapWidth(i)-5,5,"H",'HorizontalAlignment','right')
        xlim([0, soapWidth(i)+2])
    else
        lPeople = lPeople + 1;
        figure(fig2)
        subplot(5,3,lPeople), hold on
        plot([-people.CutWidth(i),0],[people.HumanSide(i),people.RobotSide(i)],'b-')
        plot([-soapWidth(i),0],[soapHeight(i),soapHeight(i)], 'k-')
        plot([0,0],[0,soapHeight(i)], 'k-')
        plot([-soapWidth(i),-soapWidth(i)],[0,soapHeight(i)], 'k-')
        text(5,5,"H")
        text(soapWidth(i)-5,5,"R",'HorizontalAlignment','right')
        xlim([-soapWidth(i)-2,0+2])
    end
    ylim([0-2, soapHeight(i)+2])
    titleName = strjoin(["Test N. ", num2str(i), " - Indentation angle: ", sprintf("%.2f", angle(i)), " [deg]"],"");
    title(titleName)
    
    %% Evaluation of the removed area
    if people.HumanSide(i) == 0
        removedArea(i) = trapz([0,people.cutWidth(i),soapWidth(i)],[soapHeight(i)-people.RobotSide(i),0,0]);
    else
        removedArea(i) = trapz([0,soapWidth(i)],[soapHeight(i)-people.RobotSide(i),soapHeight(i)-people.HumanSide(i)]);
    end
    totalArea(i) = soapHeight(i)*soapWidth(i)/2;
    hold off
    removedAreaPercentage(i) = (removedArea(i))/totalArea(i)*100;
end

figure(fig1), hold off
fig1.Position(3) = fig1.Position(3) + 300;
Lgnd = legend("Cutting Line");
Lgnd.Position(1) = 0;
Lgnd.Position(2) = 0.5;
fig1.WindowState = 'maximized';

figure(fig2), hold off
fig2.Position(3) = fig2.Position(3) + 300;
Lgnd = legend("Cutting Line");
Lgnd.Position(1) = 0;
Lgnd.Position(2) = 0.5;
fig2.WindowState = 'maximized';

fig3 = figure('Name','Trend of removed material');
fig3.WindowState = 'maximized';
hold on, grid on
scatter(removedArea,1:numPeople,'red','filled','DisplayName','Removed material')
xline(mean(removedArea),'r--','LineWidth',0.8,'DisplayName','Removed material in average')
xline(mean(totalArea),'k--','LineWidth',2.2,'DisplayName','Available material in average')
legend('show','Location','eastoutside')
xlabel("Removed material [ mm^2 ]"), ylabel("# Test")
title("Trend of removed material after the cutting")

fig4 = figure('Name','Trend of angle of soap indentation');
fig4.WindowState = 'maximized';
hold on, grid on
scatter(angle,1:numPeople,'red','filled','DisplayName','Indentation angle')
xline(mean(angle),'r--','LineWidth',0.8,'DisplayName','Average indentation angle')
legend('show','Location','eastoutside')
xlabel("Angle [ deg ]"), ylabel("# Test")
title("Trend of angle indentation in the soap")

fig5 = figure('Name','Soap Indentation parameters');
fig5.WindowState = 'maximized';
hold on, grid on
scatter(angle,removedArea,50,'red','LineWidth',1.5)
lsline
scatter(mean(angle),mean(removedArea), 150,'red','filled')
errorbar(mean(angle),mean(removedArea),-std(removedArea)/(2*sqrt(numPeople)),std(removedArea)/(2*sqrt(numPeople)), 'k', 'LineStyle','none','LineWidth',0.8)
errorbar(mean(angle),mean(removedArea),-std(angle)/(2*sqrt(numPeople)),std(angle)/(2*sqrt(numPeople)), 'Horizontal', 'k', 'LineStyle','none','LineWidth',0.8)
limX = [min(angle),max(angle)];
limY = [min(removedArea),max(removedArea)];
xlim([limX(1)-1,limX(2)+1]), ylim([limY(1)-25,limY(2)+25])
legend("Test samples","Trend line","Mean of the samples","Standard Error",'Location','northwest')
xlabel("Angle [ deg ]"), ylabel("Removed material [ mm^2 ]")
title("Comparison between indentation angle and removed material from soap bars")

%% Save and close all the plot
mkdir ..\iCub_ProcessedData\Scatters
pause(2);
exportgraphics(fig1,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\RightHandSoapIndentation.png")
exportgraphics(fig2,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\LeftHandSoapIndentation.png")
exportgraphics(fig3,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\SoapRemovedMaterial.png")
exportgraphics(fig4,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\MeanAngleSoapIndentation.png")
exportgraphics(fig5,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\SoapIndentationParameters.png")

matx = table((1:32)',angle,removedArea',removedAreaPercentage');
matx = renamevars(matx, 1:width(matx), ["ID","Angle Human Side [deg]","Removed Surface [mm^2]","Percentage of removed material [%]"]);

writetable(matx, "..\iCub_ProcessedData\SoapData.xlsx");

close all
