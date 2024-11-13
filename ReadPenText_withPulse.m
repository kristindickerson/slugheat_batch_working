%%% ==============================================================================
%%  Purpose: 
%       This function reads in the information from the penetration file 
%       that was chosen by the user in 'GetFiles' function and now defined 
%       with variable `PenFile`. This file should have been created by 
%       the user in SlugPen. This function uses the TEXT .pen file. 
%%  Last edit:
%       01/14/2024 by Kristin Dickerson, UCSC
%%% ==============================================================================

function    [StationName, ...
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
            PenetrationRecord, ...
            HeatPulseRecord, ...
            EndRecord, ...
            AllRecords, ...
            AllSensorsRawData, ...
            WaterSensorRawData, ...
            CalibTemps, ...
            MeanCalibTemps, ...
            WaterThermistor, ...
            PulsePower] = ReadPenText_withPulse(PenFile, ~, WaterThermistor, figure_Main)

% ===================================
%% Open and read in the 'PEN' file
% ===================================
    if exist(PenFile, 'file')
        fid = fopen(PenFile);
    else
        return
    end
    
    % Read header and preliminary data
    % ---------------------------------

    fseek(fid,1,'cof');
    frewind(fid);
    StationName = fscanf(fid,'%s',1);
    Penetration = fscanf(fid,'%s',1);
    
    fseek(fid,0,'bof');
    Lookup = fread(fid,255,'*char');
    Quotes = find(Lookup=='''');
    fseek(fid,Quotes(1),'bof');
    CruiseName = fscanf(fid,'%c',Quotes(2)-Quotes(1)-1);

    
    
    fseek(fid,1,'cof');
    Datum = fscanf(fid,'%s',1);
    Latitude = fscanf(fid,'%f',1);
    Longitude = fscanf(fid,'%f',1);
    DepthMean = fscanf(fid,'%f',1);
    TiltMean = fscanf(fid,'%f',1);
    LoggerId = fscanf(fid,'%s',1);
    ProbeId = fscanf(fid,'%s',1);
    NumberOfSensors = fscanf(fid,'%f',1);
    PulsePower = fscanf(fid,'%f',1);
    PulsePower = round(PulsePower);
    PenetrationRecord = fscanf(fid,'%d',1);
    HeatPulseRecord = fscanf(fid,'%d',1);
   
%% GET MEAN CALIBRATION TEMPERATYRE DATA 
    Format = repmat('%f ',1,NumberOfSensors);
    MeanCalibTemps = fscanf(fid,Format, ...
        NumberOfSensors+1)';

%% GET CALIBRATION TEMP DATA (if all calibration temperatures are recorded, not just the mean)
    Format = repmat('%f ',1,NumberOfSensors);
    line = fgetl(fid);
    i=1;
    CalibTemps=cell(500,NumberOfSensors);
    CalibTemps(cellfun(@isempty,CalibTemps)) = {NaN};

    while contains(line,'$')
        CalibTemps(i, :) = cell2mat(linescan);
        line = fgetl(fid);
        linescan = textscan(line, ['%*s %f' Format]);
        i=i+1;
    end

%% GET PENENETRATION TEMPERATURE DATA

    linescan = textscan(line, ['%f %f' ,Format]);
    FirstLine = cell2mat(linescan);

    RawRead = fscanf(fid,['%f' Format],inf);
    l = length(RawRead);
    
    RawRead = reshape(RawRead, ...
        (NumberOfSensors+2), ...
        l/(NumberOfSensors+2))';
    
    PenRead = [FirstLine; RawRead];

    AllRecords = PenRead(:,1);
    EndRecord = AllRecords(end);
    AllSensorsRawData = PenRead(:,2:end);
    
    WaterSensorRawData = PenRead(:,end);
    
    fclose(fid);
    
%% Remove any sensors with all NaN or -999 temperatures
    
    % Notify user that bad sensors were removed
    if any(all(isnan(AllSensorsRawData)))
        disp(['One or more sensors on this .pen or .mat file ' ...
            'did not record any data. These sensors have been removed.']);
    end

    % Remove data from bad sensors
    AllSensorsRawData = AllSensorsRawData(:, ~all(isnan(AllSensorsRawData)));
    AllSensorsRawData = AllSensorsRawData(:, ~all(AllSensorsRawData==-999));
    MeanCalibTemps        = MeanCalibTemps(:, ~isnan(MeanCalibTemps));
    MeanCalibTemps        = MeanCalibTemps(:, MeanCalibTemps~=-999);


    % Remove these sensors from number of sensors
    [~,NumSensTot]   = size(AllSensorsRawData);
    
    if ~all(WaterSensorRawData==-999)
        [~,NumWaterSens] = size(WaterSensorRawData);
    else
        NumWaterSens=0;
    end
    
    % Set number of sensors
    NumberOfSensors = NumSensTot-NumWaterSens;

%% Tell user if no calibration period was selected
    if all(MeanCalibTemps==-999)
        disp(['No calibration period' newline newline ...
       'Temperature sensors will not be calibrated unless a ' ...
       'calibration period is chosen in SlugPen or mean calibration ' ...
       'temperatures for each sensor are manually input in ' ...
       '.pen file or .mat file by user'])
    end
    
