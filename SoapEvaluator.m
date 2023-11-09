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
RigthDistanceFromSoapTop = zeros(1,numPeople);
LeftDistanceFromSoapTop = zeros(1,numPeople);
for i = 1:numPeople
    x1 = [0,(soapWidth(i)/2-flatWidth)/2];
    x2 = [soapWidth(i)-flatWidth/2,soapWidth(i)];
    y1 = [lateralHeight,soapHeight];
    y2 = [soapHeight,lateralHeight];
    topPointsX = [x1,soapWidth(i)/2,x2];
    topPointsY = [y1,soapHeight,y2];
    xSoapWidth = linspace(0,soapWidth(i),1000);
    ySoapWidth = polyval(p,xSoapWidth);
    figure, plot(xSoapWidth,ySoapWidth)
    if strcmp(people.Mano(i),"DX") == 1
        RigthDistanceFromSoapTop(i) = ySoapWidth(round((soapWidth(i)/2-people.CutWidth(i)/2)*10));%-people.HumanSide(i);
        LeftDistanceFromSoapTop(i) = ySoapWidth(round((soapWidth(i)/2+people.CutWidth(i)/2)*10));%-people.RobotSide(i);
    else
        RigthDistanceFromSoapTop(i) = ySoapWidth(round((soapWidth(i)/2-people.CutWidth(i)/2)*10));%-people.RobotSide(i);
        LeftDistanceFromSoapTop(i) = ySoapWidth(round((soapWidth(i)/2+people.CutWidth(i)/2)*10));%-people.HumanSide(i);
    end
end

%% Evaluation of the removed area
removedArea = zeros(1,numPeople);
for i = 1:numPeople
    cutWidth = [soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2];
    if strcmp(people.Mano(i),"DX") == 1
        removedArea(i) = trapz(xSoapWidth,ySoapWidth-interp1(cutWidth,[people.RobotSide(i), people.HumanSide(i)],linspace(cutWidth(1),cutWidth(2),1000)));
    else
        removedArea(i) = trapz(xSoapWidth,ySoapWidth-interp1(cutWidth,[people.HumanSide(i), people.RobotSide(i)],linspace(cutWidth(1),cutWidth(2),1000)));
    end
end

%% Plot results
fig1 = figure('Name','Right hand soap indentation');
fig1.WindowState = 'maximized';
sgtitle('Soap Indentation - Right Hand tests'), hold on
fig2 = figure('Name','Left hand soap indentation');
fig2.WindowState = 'maximized';
sgtitle('Soap Indentation - Left Hand tests'), hold on
rPeople = 0;
lPeople = 0;
for i = 1:numPeople
    if strcmp(people.Mano(i),"DX") == 1
        rPeople = rPeople + 1;
        figure(fig1)
        subplot(numPeople/8,numPeople/8,rPeople), hold on
        plot([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.RobotSide(i), people.HumanSide(i)],'r-')
        plot([soapWidth(i)/2+people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.HumanSide(i), RigthDistanceFromSoapTop(i)],'k--')
        plot([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2-people.CutWidth(i)/2], [people.RobotSide(i), LeftDistanceFromSoapTop(i)],'k--')
    else
        lPeople = lPeople + 1;
        figure(fig2)
        subplot(numPeople/8,numPeople/8,lPeople), hold on
        plot([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.HumanSide(i), people.RobotSide(i)],'b-')
        plot([soapWidth(i)/2+people.CutWidth(i)/2, soapWidth(i)/2+people.CutWidth(i)/2], [people.RobotSide(i), RigthDistanceFromSoapTop(i)],'k--')
        plot([soapWidth(i)/2-people.CutWidth(i)/2, soapWidth(i)/2-people.CutWidth(i)/2], [people.HumanSide(i), LeftDistanceFromSoapTop(i)],'k--')
    end
    plot(xSoapWidth,ySoapWidth,'k')
    xlim([0, soapWidth(i)])
    ylim([0, soapHeight+1])
    titleName = strjoin(["Test N. ", num2str(i), " - Indentation angle: ", num2str(angle(i)), " [deg]"],"");
    title(titleName)
    hold off
end

figure(fig1), hold off
figure(fig2), hold off
