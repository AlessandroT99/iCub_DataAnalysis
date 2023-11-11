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

% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');
% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

%% Input Data
numPeople = 32; 
people = readtable("..\InputData\Dati Personali EXP2.xlsx");
people = people(1:numPeople,:);

soapWidth = people.WidthSoap;               % mm
soapHeight = people.HeightSoap(1);          % mm
lateralHeight = people.LateralHeight(1);    % mm, it represents the height from the bottom to the line at the half of the soap
flatWidth = people.FlatWidth(1);            % mm, it represents the flat part on the top of the soap

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

%% Evaluation of the distance from the cut to the top of the soap
xSoapWidth = zeros(numPeople,1000);
ySoapWidth = zeros(numPeople,1000);
for i = 1:numPeople
    % Evaluation of the soap form
    x1 = [0,soapWidth(i)/2-flatWidth/2];
    x2 = [soapWidth(i)/2+flatWidth/2,soapWidth(i)];
    y1 = [lateralHeight,soapHeight];
    y2 = [soapHeight,lateralHeight];
    r1 = sqrt((x1(2) - x1(1)).^2 + (y1(2) - y1(1)).^2);
    r2 = sqrt((x2(2) - x2(1)).^2 + (y2(2) - y2(1)).^2);

    % Evaluate lateral arcs coordinates
    x_arc = [linspace(x1(1),x1(2), 100); linspace(x2(1),x2(2), 100)];
    y_arc = [y1(2) .* cos(linspace(-pi/2, 0, 100)); y2(1) .* cos(linspace(0, pi/2, 100))];
    topPointsX = [x_arc(1,:),soapWidth(i)/2,x_arc(2,:)];
    topPointsY = [y_arc(1,:),soapHeight,y_arc(2,:)];
%     figure, plot(topPointsX,topPointsY)
    xSoapWidth(i,:) = linspace(0,soapWidth(i),1000);
    ySoapWidth(i,:) = interp1(topPointsX,topPointsY,xSoapWidth(i,:));
%     figure, plot(xSoapWidth,ySoapWidth)
end

%% Plot results
fig1 = figure('Name','Right hand soap indentation');
sgtitle('Soap Indentation - Right Hand tests'), hold on
fig2 = figure('Name','Left hand soap indentation');
sgtitle('Soap Indentation - Left Hand tests'), hold on
rPeople = 0;
lPeople = 0;
removedArea = zeros(1,numPeople);
totalArea = zeros(1,numPeople);
standardError = zeros(1,numPeople);
for i = 1:numPeople
    if strcmp(people.Mano(i),"DX") == 1
        rPeople = rPeople + 1;
        figure(fig1)
        subplot(numPeople/8,numPeople/8,rPeople), hold on
        p = polyfit([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.RobotSide(i), people.HumanSide(i)],1);
        xTmp = linspace(0,soapWidth(i),1000);
        yPlot = interp1(xTmp, polyval(p,xTmp), xSoapWidth(i,:));
        plot(xSoapWidth(i,:), yPlot, 'r-')
        text(xSoapWidth(i,200),5,"R")
        text(xSoapWidth(i,end-200),5,"H",'HorizontalAlignment','right')
    else
        lPeople = lPeople + 1;
        figure(fig2)
        subplot(numPeople/8,numPeople/8,lPeople), hold on
        p = polyfit([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.HumanSide(i), people.RobotSide(i)],1);
        xTmp = linspace(0,soapWidth(i),1000);
        yPlot = interp1(xTmp, polyval(p,xTmp), xSoapWidth(i,:));
        plot(xSoapWidth(i,:), yPlot, 'b-')
        text(xSoapWidth(i,200),5,"H")
        text(xSoapWidth(i,end-200),5,"R",'HorizontalAlignment','right')
    end
    xlim([0, soapWidth(i)])
    ylim([0, soapHeight+1])
    titleName = strjoin(["Test N. ", num2str(i), " - Indentation angle: ", sprintf("%.2f", angle(i)), " [deg]"],"");
    title(titleName)
    
    %% Evaluation of the removed area
    mins = zeros(1,2);
    [~,mins(1)] = min(abs(yPlot(1:end/2)-ySoapWidth(i,1:end/2)));
    [~,mins(2)] = min(abs(yPlot(end/2:end)-ySoapWidth(i,end/2:end)));
    mins(2) = mins(2)+length(ySoapWidth)/2;
    removedArea(i) = trapz(xSoapWidth(i,mins(1):mins(2)),ySoapWidth(i,mins(1):mins(2))-yPlot(mins(1):mins(2)));
    totalArea(i) = trapz(xSoapWidth(i,:),ySoapWidth(i,:));
    if strcmp(people.Mano(i),"DX") == 1
        yline(max(ySoapWidth(i,mins)),'k--','LineWidth',0.8);
    else
        yline(max(ySoapWidth(i,mins)),'k--','LineWidth',0.8);
    end
    plot(xSoapWidth(i,:),ySoapWidth(i,:),'k')
    hold off
    standardError(i) = std(ySoapWidth(i,mins(1):mins(2))-yPlot(mins(1):mins(2)))/sqrt(length(ySoapWidth));
end

figure(fig1), hold off
fig1.Position(3) = fig1.Position(3) + 300;
Lgnd = legend("Cutted Line", "Reference Plane");
Lgnd.Position(1) = 0;
Lgnd.Position(2) = 0.5;
fig1.WindowState = 'maximized';

figure(fig2), hold off
fig2.Position(3) = fig2.Position(3) + 300;
Lgnd = legend("Cutted Line", "Reference Plane");
Lgnd.Position(1) = 0;
Lgnd.Position(2) = 0.5;
fig2.WindowState = 'maximized';

fig3 = figure('Name','Trend of removed material');
fig3.WindowState = 'maximized';
hold on, grid on
scatter(removedArea,1:numPeople,'red','filled','DisplayName','Removed material')
xline(mean(removedArea),'r--','LineWidth',0.8,'DisplayName','Removed material in average')
xline(mean(totalArea),'k--','LineWidth',2.2,'DisplayName','Available material in average')
% errorbar(removedArea,1:numPeople,standardError,'Horizontal', 'k', 'LineStyle','none','CapSize',12,'LineWidth',0.8,'DisplayName','Standard Error')
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
scatter(mean(angle),mean(removedArea), 150,'red','filled')
errorbar(mean(angle),mean(removedArea),std(removedArea)/sqrt(numPeople), 'k', 'LineStyle','none','LineWidth',0.8)
errorbar(mean(angle),mean(removedArea),std(angle)/sqrt(numPeople), 'Horizontal', 'k', 'LineStyle','none','LineWidth',0.8)
limX = [0,max(angle)];
limY = [0,max(removedArea)];
xlim(limX), ylim(limY)
plot(limX,limY,'k-')
legend("Test samples","Mean of the samples","Standard Error",'Location','northwest')
xlabel("Angle [ deg ]"), ylabel("Removed material [ mm^2 ]")
title("Comparison between indentation angle and removed material from soap bars")

mkdir ..\ProcessedData\Scatters
exportgraphics(fig1,"..\ProcessedData\Scatters\RightHandSoapIndentation.png")
exportgraphics(fig2,"..\ProcessedData\Scatters\LeftHandSoapIndentation.png")
exportgraphics(fig3,"..\ProcessedData\Scatters\SoapRemovedMaterial.png")
exportgraphics(fig4,"..\ProcessedData\Scatters\MeanAngleSoapIndentation.png")
exportgraphics(fig5,"..\ProcessedData\Scatters\SoapIndentationParameters.png")

% close all