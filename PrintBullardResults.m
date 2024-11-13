%%% ======================================================================
%%   Purpose: 
%       This function prints results from heat flow analysis to .res file. 
%       Results include shifted depths, equilibrium 
%       temperatures, equilibrium relative to bottom water, and final
%       calculated thermal conductivity.
%%   Last edit:
%       08/07/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function PrintBullardResults(ResFileId, ...
    Iteration, ...
    Trial, ...
    PulseData, ...
    TChange, ...
    SensorsToUse, ...
    ShiftedRelativeDepths, ...
    MinimumFricEqTemp, ...
    BottomWaterTemp, ...
    MinimumFricError, ...
    Currentk, ...
    HeatFlow, ...
    HFErr, ...
    HFShift, ...
    HFShiftErr, ...
    Gradient, ...
    GradErr, ...
    Converged, ...
    TotkChange, ...
    kChange)

    % Initialize
    
    Id = ResFileId;
    
    NC = 79;
    TChange = sum(TChange);
    
    if Converged==0
        Converge = 'No';
    elseif Converged==1
        Converge = 'Yes';
    end
    
    kChange_s = [];
    for i=SensorsToUse
        kChange_s = [kChange_s ' | ' num2str(kChange(i),3)]; %#ok<AGROW>
    end
    
    %% Organize Bullard Analysis results
    % ----------------------------
    SensorsUsed     = SensorsToUse';
    Depths = ShiftedRelativeDepths(SensorsToUse)';
    EqTempsRelBW = MinimumFricEqTemp(SensorsToUse);
    BottomWaterTemp = BottomWaterTemp(1,SensorsToUse)';
    EqTemps = EqTempsRelBW + BottomWaterTemp;
    FricTempError = MinimumFricError(SensorsUsed);
    FinalCalculatedk = Currentk(SensorsToUse)';
    
    BullardResults = [SensorsUsed Depths EqTempsRelBW BottomWaterTemp ...
        EqTemps FricTempError FinalCalculatedk]';
    
        if PulseData
    
            String = ['BULLARD ANALYSIS - TRIAL # ' int2str(Trial)];
            fprintf(Id,'\n%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
            fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
            fprintf(Id,'%s\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
    
        else
            String = ['BULLARD ANALYSIS - NO HEAT PULSE - TRIAL # ' int2str(Trial)];
            fprintf(Id,'\n%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
            fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
            fprintf(Id,'%s\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
    
        end
    fprintf(Id,'\n%s',['Iterations: ' num2str(Iteration,'%02d')]);
    fprintf(Id, '\n%s', ['Convergence reached? ' Converge]);
    fprintf(Id, '\n%s', ['Sum of difference in k for all sensors (W/m°C): ' num2str(TotkChange)]);
    fprintf(Id, '\n%s', ['Difference in k for each sensor (W/m°C): ' kChange_s]);
    fprintf(Id,'\n%s',['Thermal Gradient (°C/m): ' num2str(Gradient, '%8.3f'), ' +/- ' num2str(GradErr, '%8.3f')]);    
    fprintf(Id,'\n%s',['Heat Flow (mW/m2): ' num2str(HeatFlow, '%8.0f'), ' +/- ' num2str(HFErr, '%8.3f')]);
    fprintf(Id,'\n%s',['Heat Flow Shift (m): ' num2str(HFShift, '%8.0f'), ' +/- ' num2str(HFShiftErr, '%8.3f')]);
    if Iteration > 2
        fprintf(Id,'\n%s',['Total change in Temperature (°C): ' num2str(TChange,'%+4.3e')]);
        fprintf(Id,'\n%s\n\n', ...
            '=======================================================================');
    else
        fprintf(Id,'\n%s\n\n', ...
            '======================================================================='); 
    end
    
    fprintf(Id,'%s\n', ...
        'Sensor  Depth     Equilibrium          Bottom Water    Equilibrium   Temp. Error   Therm. Con.');
    fprintf(Id,'%s\n', ...
        '         (m)      Temp. Relative to    Temp. (°C)      Temp.(°C)     (95%)         (W/m°C)');
    fprintf(Id,'%s\n', ...
        '                  Bottom Water (°C)                       ');
    fprintf(Id,'%s\n\n', ...
        '------  --------  -------------------  ------------    ------------  -----------   -----------');
    fprintf(Id, ...
        '%4d    %6.3f      %6.3f                 %6.3f            %6.3f          %6.3d      %6.3f\n',BullardResults);
    
    if ~PulseData
      fprintf(Id,'\n%s\n\n', ...
        '------------------------------------------------------------------------------------------------');
    end
    
    fprintf(Id, '\n%s\n\n\n', ['*********   ' char(datetime('now')) ...
            ' - End heat flow processing of Trial ' int2str(Trial) ' !   *********']);
    
    
    