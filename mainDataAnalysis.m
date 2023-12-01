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
    if ~isempty(e.identifier)
        fprintf(2,'\n\nThe identifier was:\n%s',e.identifier);
    end
    fprintf(2,'\nThere was an error! The message was:\n%s',e.message);
    if TELEGRAM_LOG
        outputText = strjoin(["An error occurred! The simulation has been interrupted. Come to check the problem.",newline,newline,"The error output was: ",e.message],"");
        pyrunfile("telegramLogging.py",txtMsg=outputText,TEXT=1,filePath="");
    end
end

