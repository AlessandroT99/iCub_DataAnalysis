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
numPeople = 30; 
people = readtable("..\iCub_InputData\Dati Personali EXP3.xlsx");
people = people(1:numPeople,:);

load ..\iCub_ProcessedData\PeaksNumber.mat;
nMaxPeaks = nMaxPeaks(3:end);
nMinPeaks = nMinPeaks(3:end);
data = readtable("..\iCub_ProcessedData\PeaksPositionData.xlsx");

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
fig2 = figure('Name','Left hand soap indentation');

rPeople = 0;
lPeople = 0;
removedArea = zeros(1,sum(~isnan(people.ID)));
maxCutArea = zeros(1,sum(~isnan(people.ID)));
totalArea = zeros(1,sum(~isnan(people.ID)));
removedAreaPercentage = zeros(1,sum(~isnan(people.ID)));

for i = 1:numPeople
    if people.RobotSide(i) < people.HumanSide(i)
        angle(i) = -angle(i);
    end
    
    if ~isnan(people.ID(i))
        %% Evaluation of the removed area
        removedArea(i) = trapz([0,soapWidth(i)],[soapHeight(i)-people.RobotSide(i),soapHeight(i)-people.HumanSide(i)]);
        totalArea(i) = soapHeight(i)*soapWidth(i);
        removedAreaPercentage(i) = removedArea(i)/totalArea(i)*100;
    
        % Plot results
        if strcmp(people.Mano(i),"R") == 1
            rPeople = rPeople + 1;
            figure(fig1)
            subplot(4,4,rPeople), hold on
            plot([0,people.CutWidth(i)],[people.RobotSide(i),people.HumanSide(i)],'r-')
            yline(max(people.HumanSide(i),people.RobotSide(i)),'k--')
            plot([0,0],[0,soapHeight(i)], 'k-')
            if (abs(people.CutWidth(i)) > abs(soapWidth(i)))
                plot([people.CutWidth(i),0],[soapHeight(i),soapHeight(i)], 'k-')
                plot([people.CutWidth(i),people.CutWidth(i)],[0,soapHeight(i)], 'k-')
                text(people.CutWidth(i)-5,5,"H",'HorizontalAlignment','right')
                xlim([-2, people.CutWidth(i)+2])
            else
                plot([0,soapWidth(i)],[soapHeight(i),soapHeight(i)], 'k-')
                plot([soapWidth(i),soapWidth(i)],[0,soapHeight(i)], 'k-')
                text(soapWidth(i)-5,5,"H",'HorizontalAlignment','right')
                xlim([-2, soapWidth(i)+2])
            end
            text(5,5,"R")
        else
            lPeople = lPeople + 1;
            figure(fig2)
            subplot(4,4,lPeople), hold on
            plot([-people.CutWidth(i),0],[people.HumanSide(i),people.RobotSide(i)],'b-')
            yline(max(people.HumanSide(i),people.RobotSide(i)),'k--')
            plot([0,0],[0,soapHeight(i)], 'k-')
            if (abs(people.CutWidth(i)) > abs(soapWidth(i)))
                plot([-people.CutWidth(i),0],[soapHeight(i),soapHeight(i)], 'k-')
                plot([-people.CutWidth(i),-people.CutWidth(i)],[0,soapHeight(i)], 'k-')
                text(-people.CutWidth(i)+5,5,"R",'HorizontalAlignment','right')
                xlim([-people.CutWidth(i)-2,2])
            else
                plot([-soapWidth(i),0],[soapHeight(i),soapHeight(i)], 'k-')
                plot([-soapWidth(i),-soapWidth(i)],[0,soapHeight(i)], 'k-')
                text(-soapWidth(i)+5,5,"R",'HorizontalAlignment','right')
                xlim([-soapWidth(i)-2,2])
            end
            text(-5,5,"H")
        end
        ylim([0, soapHeight(i)+5])
        titleName = strjoin(["Test N. ", num2str(i), " - Removed material: ", sprintf("%.2f", removedAreaPercentage(i)), " %"],"");
        title(titleName,strjoin(["Indentation angle: ", sprintf("%.2f", angle(i)), " [deg]"],""))
        hold off
    end
end

figure(fig1), hold off
fig1.Position(3) = fig1.Position(3) + 300;
Lgnd = legend("Cutting Line","Horizontal reference");
fig1.WindowState = 'maximized';
Lgnd.Position(1) = 0.535;
Lgnd.Position(2) = 0.15;
sgtitle('Soap Indentation - Right Hand tests')

figure(fig2), hold off
fig2.Position(3) = fig2.Position(3) + 300;
Lgnd = legend("Cutting Line","Horizontal reference");
fig2.WindowState = 'maximized';
Lgnd.Position(1) = 0.535;
Lgnd.Position(2) = 0.15;
sgtitle('Soap Indentation - Left Hand tests')

angle = angle(~isnan(people.ID));
removedArea = removedArea(removedArea~=0);
removedAreaPercentage = removedAreaPercentage(removedAreaPercentage~=0);
numPeople = sum(~isnan(people.ID));

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
pause(5);
exportgraphics(fig1,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\RightHandSoapIndentation.png")
exportgraphics(fig2,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\LeftHandSoapIndentation.png")
exportgraphics(fig3,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\SoapRemovedMaterial.png")
exportgraphics(fig4,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\MeanAngleSoapIndentation.png")
exportgraphics(fig5,"..\iCub_ProcessedData\Scatters\0.SoapEvaluation\SoapIndentationParameters.png")

matx = table(people.ID(~isnan(people.ID)),angle,removedArea',removedAreaPercentage');
matx = renamevars(matx, 1:width(matx), ["ID","Angle Human Side [deg]","Removed Surface [mm^2]","Percentage of removed material [%]"]);

writetable(matx, "..\iCub_ProcessedData\SoapData.xlsx");


disp("Posterior Data analysis on new experiment.")
meanRemovedAreaPercentage = mean(removedAreaPercentage);
stdRemovedAreaPercentage = std(removedAreaPercentage);
fprintf("The average removed area percentage is %.2f with a std of %.4f\n", meanRemovedAreaPercentage, stdRemovedAreaPercentage)
for i = 1:sum(~isnan(people.ID))
    angleContribution(i) = removedAreaPercentage(i)/(mean(mean(nMaxPeaks(i)),mean(nMinPeaks(i)))*data.ROM_cm_(i));
end
fprintf("The dependency on cutting the angle is: %.4f\n",mean(angleContribution))
removedAreaPercentage2 = removedAreaPercentage;
save("../iCub_ProcessedData/Scatters/0.SoapEvaluation/removedAreaPercentage","removedAreaPercentage2","meanRemovedAreaPercentage","stdRemovedAreaPercentage","angleContribution");
close all
