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

clear all, close all,  clc
format compact

TELEGRAM_LOG = 1; % Goes to 0 if no messages on telegram are wanted        

try
    dataPlotter(TELEGRAM_LOG);
catch e
    fprintf(2,'The identifier was:\n%s',e.identifier);
    fprintf(2,'There was an error! The message was:\n%s',e.message);
    if TELEGRAM_LOG
        pyrunfile("telegramLogging.py",txtMsg="An error occurred! The simulation has been interrupted. Come to check the problem.");
    end
end

