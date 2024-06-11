clear all, close all, clc
format compact

% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');

data = readtable("..\iCub_ProcessedData\AbsoluteRelativeVelocity\AbsoluteRelativeVelocity.xlsx");

for i = 1:height(data)
    if mod(i,2) == 0 % The i value is even -> Human Test
        
    else % the i value is odd -> Robot Test

    end
end