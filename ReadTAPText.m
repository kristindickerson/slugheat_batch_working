%%% =======================================================================
%%  Purpose: 
%       This function reads in the tilt and pressure (.tap) information 
%       from the penetration that was chosen in 'GetFiles' function and 
%       defined now as variable `TAPFile`. This file should have been 
%       created by SlugPen. This function uses the TEXT file .tap file to
%       read in the data. Once tilt data is loaded in, distances between
%       sensors (SensorDistance) are corrected for instrument tilt.
%%  Last edit:
%       08/11/2023 by Kristin Dickerson, UCSC
%%% =======================================================================

function [TAPRecord, ...
         Tilt, ...
         Depth ...
         ] = ReadTAPText(...
         LogFileId, ...
         ProgramLogId, ...
         TAPName, ...
         SensorDistance, ...
         DepthMean, ...
         TiltMean, ...
         PenFilePath)

%% Define variables from data in .tap text file

   % Get the .tap text file with ending '.tap'
   % ----------------------------------------
   if exist([PenFilePath TAPName '.tap'],'file')
        TAP = load([PenFilePath TAPName '.tap']);
        TAPRecord = TAP(:,1);
        Tilt = TAP(:,2);
        Depth = TAP(:,3);
        PrintStatus(LogFileId,['TAP file ' [TAPName '.tap'] ' read ...'],2);    
        
        % Apply tilt correction
        % ---------------------
        
        if mean(Tilt) > 50
            PrintStatus(LogFileId,'Mean Tilt too high: No Tilt correction applied !',2);
        else
            if mean(Tilt) > 0
                SensorDistance = SensorDistance * cos(mean(Tilt,'omitnan')*pi/180);
                PrintStatus(LogFileId,'Applying tilt correction ...',1);
                PrintStatus(LogFileId,['Mean tilt is now :      ' num2str(mean(Tilt),'%1.1f') ' degrees.'],1); 
                PrintStatus(LogFileId,['Inter-Sensor distance : ' num2str(SensorDistance,'%1.3f') ' m.'],2);
            end
        end

        % Update penetration LOG File
        % ----------------------------
    
        PrintStatus(LogFileId, ['TAP file ' TAPName '.tap', 'read ...'], 2)
        PrintStatus(ProgramLogId, '-- Reading in TAP file',2)
  
   % Get the .tap text file with ending '.TAP'
   % ---------------------------------------
   elseif exist([PenFilePath TAPName '.TAP'],'file')
            TAP = load([PenFilePath TAPName '.TAP']);
            TAPRecord = TAP(:,1);
            Tilt = TAP(:,2);
            Depth = TAP(:,3);
            PrintStatus(LogFileId,['TAP file ' [TAPName '.TAP'] ' read ...'],2);  
   
   % If no tap record, use the mean tilt defined in .pen file
   % ----------------------------------------------------------
   else
        TAPRecord = [];
        PrintStatus(LogFileId,'TAP file not found ...',1);
        PrintStatus(LogFileId,['TAP data read in PEN file: Tilt = ' num2str(TiltMean,'%1.1f') ...
                ' deg - Depth = ' num2str(DepthMean,'%1.1f') ' m ...'],2);

        Tilt = [];
        Depth = [];
   end
    