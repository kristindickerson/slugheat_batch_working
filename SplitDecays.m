%%% ======================================================================
%%  Purpose: 
%       This function splits the penetration data into two sets: 
%       (a) thermal response  following penetration and 
%       (b) thermal response following the calibrated heat pulse
%       - These are marked on the .pen file header
%	        1st indicates beginning of the frictional decay
%	        2nd indicates beginning of the heat pulse decay
%%  Last edit:
%       08/10/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function [FricTime, ...
        FricTemp, ...
        PulseData, ...
        PulseTime, ...
        PulseTemp ...
        ] = SplitDecays( ...
            PenetrationRecord, ...
            HeatPulseRecord, ...
            EndRecord, ...   
            AllRecords, ...
            TimeScalingFactor, ...
            AllSensorsTemp, LogFileId, PenStartChanged, ...
            HeatPulseChanged, PenEndChanged, ProgramLogId, ...
            NumberOfColumns, PulseData)

    % Define if there a heat pulse during this penetration
    % ------------------------------------------------------
    if ~PulseData
        EndFricRecord = EndRecord;
    else
        EndFricRecord = HeatPulseRecord-1;
    end
    
    % Define frictional decay record numbers, time, and temperatures
    % ----------------------------------------------------------------
    ind1 = find(AllRecords==PenetrationRecord);
    ind2 = find(AllRecords==EndFricRecord);
    Fric0 = AllRecords(ind1:ind2);
    FricTime = TimeScalingFactor*(Fric0-Fric0(1));
    FricTemp = AllSensorsTemp(ind1:ind2,:);
    
    % If there is a heat pulse, define heat pulse decay record numbers, 
    % time, and temperatures
    % ----------------------------------------------------------------
    if PulseData
        ind1 = find(AllRecords==HeatPulseRecord);
        ind2 = find(AllRecords==EndRecord);
        PulseTime = AllRecords(ind1:ind2);
        PulseTime = TimeScalingFactor*(PulseTime-Fric0(1));
        PulseTemp = AllSensorsTemp(ind1:ind2,:);
    else
        PulseTime = [];
        PulseTemp = [];
    end
    
    
    % Update .log files 
    % ------------------
    PrintStatus(LogFileId,'Split penetration and heat pulse data:',1);
        
        if PulseData
            PrintStatus(LogFileId,'There is a heat pulse record ...',2);
        else
            PrintStatus(LogFileId,'There is NO heat pulse record ...',2);
        end
        
        if PenStartChanged==0 && HeatPulseChanged==0 && PenEndChanged==0
            PrintStatus(LogFileId,['Penetration Record: ' int2str(PenetrationRecord)],1);
            PrintStatus(LogFileId,['Heat Pulse Record:  ' int2str(HeatPulseRecord)],1);
            PrintStatus(LogFileId,['End of Data Record: ' int2str(EndRecord)],2);
        elseif PenStartChanged==1
                    PrintStatus(LogFileId, [repmat('-',1,NumberOfColumns)],1)
                    PrintStatus(LogFileId, ['Penetration Start record number has been manually changed by user. New penetration start: ' PenetrationRecord])
        elseif HeatPulseChanged==1
                    PrintStatus(LogFileId, [repmat('-',1,NumberOfColumns)],1)
                    PrintStatus(LogFileId, ['Heat Pulse record number has been manually changed by user. New heat pulse: ' HeatPulseRecord])
        elseif PenEndChanged==1
                    PrintStatus(LogFileId, [repmat('-',1,NumberOfColumns)],1)
                    PrintStatus(LogFileId, ['Penetration End record number has been manually changed by user. New penetration end: ' EndRecord])
        end
    
    PrintStatus(ProgramLogId,'-- Splitting penetration and heat pulse data',2);
    
    
        