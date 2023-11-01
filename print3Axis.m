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

function print3Axis(posDataSet, forceDataSet, numPerson)
% This function is used to initially plot the 3 axis components of force
% and position in order to analyze them properly
    %% Position plotting
    elapsedTimePos = minutesDataPointsConverter(posDataSet);

    fig1 = figure('Name','Position X-Y-Z');
    fig1.WindowState = 'maximized';
    grid on, hold on
    plot(elapsedTimePos,posDataSet.xPos,'b-','DisplayName','x position')
    plot(elapsedTimePos,posDataSet.yPos,'r-','DisplayName','y position')
    plot(elapsedTimePos,posDataSet.zPos,'g-','DisplayName','z position')
    titleName = strjoin(["Position X-Y-Z - Test N. ",num2str(numPerson)],"");
    title(titleName)
    xlabel("Elapsed Time [ min ]")
    ylabel("Position [ m ]")
    legend('show','Location','eastoutside')

    mkdir ..\ProcessedData;
    mkdir ..\ProcessedData\3AxisPosition;
    if numPerson < 0
        path = strjoin(["..\ProcessedData\3AxisPosition\B",num2str(3+numPerson),".png"],"");
    else
        path = strjoin(["..\ProcessedData\3AxisPosition\P",num2str(numPerson),".png"],"");
    end
    exportgraphics(fig1,path);
    close(fig1);

    %% Force plotting
    elapsedTimeForce = minutesDataPointsConverter(forceDataSet);

    fig2 = figure('Name','Force X-Y-Z');
    fig2.WindowState = 'maximized';
    grid on, hold on
    plot(elapsedTimeForce,forceDataSet.Fx,'b-','DisplayName','x force')
    plot(elapsedTimeForce,forceDataSet.Fy,'r-','DisplayName','y force')
    plot(elapsedTimeForce,forceDataSet.Fz,'g-','DisplayName','z force')
    titleName = strjoin(["Force X-Y-Z - Test N. ",num2str(numPerson)],"");
    title(titleName)
    xlabel("Elapsed Time [ min ]")
    ylabel("Force [ N ]")
    legend('show','Location','eastoutside')

    mkdir ..\ProcessedData\3AxisForce;
    if numPerson < 0
        path = strjoin(["..\ProcessedData\3AxisForce\B",num2str(3+numPerson),".png"],"");
    else
        path = strjoin(["..\ProcessedData\3AxisForce\P",num2str(numPerson),".png"],"");
    end
    exportgraphics(fig2,path);
    close(fig2);
end