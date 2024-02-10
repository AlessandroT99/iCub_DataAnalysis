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

function plot_mean_stdError(x,xMultiplier,y,MarkerDimension,ErrorBarCapSize,ErrorBarLineWidth,trendLineVisualProperty)
    scatter(mean(x.*xMultiplier),mean(y),2*MarkerDimension,"black",'filled')
    p = polyfit(x.*xMultiplier, y, 1);
    yfit = polyval(p, x.*xMultiplier);
    plot(x.*xMultiplier, yfit, trendLineVisualProperty);
    stdError1 = std(x.*xMultiplier)./sqrt(length(x));
    stdError2 = std(y)./sqrt(length(y));
    errorbar(mean(x.*xMultiplier),mean(y), -stdError1/2,stdError1/2, ...
        'Horizontal', 'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
    errorbar(mean(x.*xMultiplier),mean(y), -stdError2/2,stdError2/2, ...
        'k', 'LineStyle','none','CapSize',ErrorBarCapSize,'LineWidth',ErrorBarLineWidth)
end