%%% =======================================================================
%%  Purpose: 
%       This function reads in the information from the penetration that was 
%       chosen in 'GetFiles' function and defined now as variable `PenFile`. 
%       This file should have been created by SlugPen. Instead of using the 
%       .pen text file, this function uses the .mat file `MATFile` that 
%       houses structures containing these variables.
%%  Last edit:
%       01/14/2024 Kristin Dickerson, UCSC
%%% =======================================================================

function [S_MATFile, FullExpeditionName, ...
            StationName, ...
            Penetration, ...
            CruiseName, ...
            Datum, ...
            Latitude, ...
            Longitude, ...
            DepthMean, ...
            TiltMean, ...
            LoggerId, ...
            ProbeId, ...
            NumberOfSensors, ...
            NumberOfSensorsWorking,...
            PenetrationRecord, ...
            HeatPulseRecord, ...
            EndRecord, ...
            AllRecords, ...
            AllSensorsRawData, ...
            WaterSensorRawData, ...
            MeanCalibTemps, ...
            PulsePower...
            ] = ReadPenFile_withPulse(MATFile, ...
            LogFileId, PenFile, ProgramLogId, figure_Main)

%% Read in data

    % Load the MAT file
    % ----------------------------
    
    S_MATFile = load(MATFile);
    
    
    % Read in preliminary penetrtation information and data from 
    % saved MAT file from SlugPen
    % ----------------------------------------------------------------------
    
    StationName         = S_MATFile.S_PenHandles.StationName;
    Penetration         = S_MATFile.S_PenHandles.Penetration;
    CruiseName          = S_MATFile.S_PenHandles.CruiseName;
    Datum               = S_MATFile.S_PenHandles.Datum;
    Latitude            = S_MATFile.S_PenHandles.Latitude;
    Longitude           = S_MATFile.S_PenHandles.Longitude;
    DepthMean           = str2double(S_MATFile.S_PenHandles.Depth);
    TiltMean            = str2double(S_MATFile.S_PenHandles.Tilt);
    LoggerId            = S_MATFile.S_PenHandles.LoggerId;
    ProbeId             = S_MATFile.S_PenHandles.ProbeId;
    NumberOfSensors     = str2double(S_MATFile.S_PenHandles.NoTherm);
    PulsePower          = str2double(S_MATFile.S_PenHandles.PulsePower);
    PenetrationRecord   = S_MATFile.S_PENVAR.PenetrationRecord;
    HeatPulseRecord     = S_MATFile.S_PENVAR.HeatPulseRecord;
    EndRecord           = S_MATFile.S_PENVAR.EndRecord;
    AllRecords          = S_MATFile.S_PENVAR.AllRecords';
    AllSensorsRawData   = S_MATFile.S_PENVAR.AllSensorsRawData;
    WaterSensorRawData  = S_MATFile.S_PENVAR.WaterSensorRawData;
    MeanCalibTemps      = S_MATFile.S_PENVAR.CalibrationTemps;
    
    FullExpeditionName  = strcat(CruiseName, StationName, Penetration);

    % Update LOG file
    % -------------------------------------
    
    PrintStatus(LogFileId, ['Penetration file ' PenFile ' read ...'],1)
    
    PrintStatus(ProgramLogId, '-- Reading in penetatration file',2)


%% Remove any sensors with all NaN or -999 temperatures

    % Notify user that bad sensors were removed
    if any(all(isnan(AllSensorsRawData)))
        disp(['One or more sensors on this .pen or .mat file ' ...
            'did not record any data. These sensors have been removed.']);
    end
    
    % Remove data from bad sensors
    AllSensorsRawData = AllSensorsRawData(:, ~all(isnan(AllSensorsRawData)));
    AllSensorsRawData = AllSensorsRawData(:, ~all(AllSensorsRawData==-999));
    if ~all(MeanCalibTemps==-999)
        MeanCalibTemps        = MeanCalibTemps(:, ~isnan(MeanCalibTemps));
        MeanCalibTemps        = MeanCalibTemps(:, MeanCalibTemps~=-999);
    end
    

    % Remove these sensors from number of sensors
    [~,NumSensTot]   = size(AllSensorsRawData);
    
    if ~all(WaterSensorRawData==-999) && ~all(isnan(WaterSensorRawData))
        [~,NumWaterSens] = size(WaterSensorRawData);
    else
        NumWaterSens=0;
    end
    
    % Set number of working sensors
    NumberOfSensorsWorking = NumSensTot-NumWaterSens;

%% Inform user if no calibration period was selected

    if all(MeanCalibTemps==-999)
        disp(['No calibration period was selected ' newline newline ...
       'Temperature sensors will not be calibrated unless a ' ...
       'calibration period is chosen in SlugPen or mean calibration ' ...
       'temperatures for each sensor are manually input in ' ...
       '.pen file or .mat file by user'])
    end
   
    