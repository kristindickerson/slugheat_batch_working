%%% =======================================================================
%%  Purpose: 
%       This function reads in the information from the penetration that was 
%       chosen in 'GetFiles' function. 
%       This file should have been created by SlugPen. Instead of using the 
%       .tap text file, this function uses the .mat file `MATFile` that 
%       houses structures containing these variables. Once tilt data is 
%       loaded in, distances between sensors (SensorDistance) are 
%       corrected for instrument tilt.
%%  Last edit:
%       01/14/2024 Kristin Dickerson, UCSC
%%% =======================================================================

function [TAPRecord, ...
         Tilt, Depth, SensorDistance ...
         ] = ReadTAPFile(S_MATFile, SensorDistance)


% Read in preliminary penetrtation tilt and pressure information 
% and data from saved MAT file from SlugPen
% * pressure = depth
% ----------------------------------------------------------------------
    TAPRecord = S_MATFile.S_TAPVAR.TAPRecord;
    Tilt      = S_MATFile.S_TAPVAR.Tilt;
    Depth     = S_MATFile.S_TAPVAR.Depth;

% Apply tilt correction
% ---------------------

    if mean(Tilt) <= 50 
        if mean(Tilt)>0
        SensorDistance = SensorDistance * cos(mean(Tilt,'omitnan')*pi/180);
        end
    end
    
    