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

function [xValues, yValues] = bisector(P1,P2)
    % Calculate the midpoint of the line segment
    midpoint = 0.5 * (P1 + P2);
    
    % Calculate the slope of the perpendicular bisector
    slope_perpendicular = 1 / ((P2(2) - P1(2)) / (P2(1) - P1(1)));
    
    % Calculate the y-intercept of the perpendicular bisector
    y_intercept = midpoint(2) - slope_perpendicular * midpoint(1);
    
    % Create a range of x-values
    xValues = linspace(min([P1(1), P2(1)]), max([P1(1), P2(1)]), 100);
    
    % Calculate corresponding y-values for the bisector
    yValues = slope_perpendicular * xValues + y_intercept;
end