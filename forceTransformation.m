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

function forceDataSet = forceTransformation(forceDataSet, numPerson)
% This function is used to transform the force in order to have the wanted
% Fy resultant referenced to the OF. So being initially referred to th F/T
% sensor reference frame, using fwd kinematics the signal is transformed
% into the hand reference frame and then its rotated to the OF using the
% quaternions.
    if numPerson < 0
        % up to know the only dataset that could be analyzed that way are
        % the baseline sets.
        
    end
end