%%% =======================================================================
%%   Purpose:
%       This function prints results of frictional decay processing to 
%       results (.res) file
%%   Last edit
%       08/08/2023 by Kristin Dickerson, UCSC
%%% =======================================================================

function PrintFricResults(...
    FricTime, NumberOfFricUsedPoints, MinimumFricEqTemp, ...
    MinimumFricError, SensorDistance, MinimumFricDelays, ...
    MinimumFricSlope, TChange, ResFileId, NumberOfColumns, ...
    Iteration, Trial, PulseData, SensorsToUse)

        %% Organize frictional results
        % ----------------------------
        NumberOfSensorsUsed = length(SensorsToUse);
        
        a = SensorsToUse';
        b = repmat(length(FricTime),NumberOfSensorsUsed,1);
        c = repmat(NumberOfFricUsedPoints,NumberOfSensorsUsed,1);
        d = MinimumFricEqTemp(SensorsToUse);
        e = MinimumFricError(SensorsToUse);
        f = [-1000*diff(MinimumFricEqTemp(SensorsToUse)')/SensorDistance 0]';
        g = MinimumFricDelays(SensorsToUse);
        h = MinimumFricSlope(SensorsToUse);
        
        FrictionalResults = [a b c d e f g h]';
        
        NC = NumberOfColumns;
        
        TChange = sum(TChange);
        
        %% Print only FINAL iteration to results (.res) file 
        % ---------------------------------------------------
        Id = ResFileId;
        
        if PulseData
        
            % Print frictional decay header if there was a heat pulse
            % ------------------------------------------------------
            String = ['FRICTIONAL AND HEAT PULSE DECAYS REDUCTION - TRIAL # ' ...
                int2str(Trial)];
            fprintf(Id,'\n%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
            fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
            fprintf(Id,'%s\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
        
        else
            % Print frictional decay header if there was NOT a heat pulse
            % ----------------------------------------------------------
            String = ['FRICTIONAL DECAY REDUCTION - NO HEAT PULSE - TRIAL # ' ...
                int2str(Trial)];
            fprintf(Id,'\n%s\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
            fprintf(Id,'%s\n',[repmat(' ',1,fix((NC-length(String))/2)) String]);
            fprintf(Id,'%s\n\n',[repmat(' ',1,fix((NC-length(String))/2)) ...
                    repmat('-',1,length(String))]);
        
        end
        
        % Print frictional decay results 
        % -------------------------------
        fprintf(Id,'\n%s',['Frictional Decay - Iteration ' num2str(Iteration, ...
            '%02d')]);
        
        % Print total change in frictional decay results between iterations
        % -----------------------------------------------------------------
        if Iteration > 2
            fprintf(Id,'%s',[' - Total change in Temperature: ' num2str(TChange, ...
                '%+4.3e')]);
            fprintf(Id,'\n%s\n\n', ...
                ['===============================================================' ...
                '========']);
        else
            fprintf(Id,'\n%s\n\n', ...
                '==============================='); 
        end
        
        % Print equilibrium tempeartures, error, gradient, delay, slope,
        % and error
        % ---------------------------------------------------------------
        fprintf(Id,'%s\n', ...
            'Sensor  Data Points  Eq. temp.   Error   Gradient  Delay   Slope');
        fprintf(Id,'%s\n', ...
            '        Tot. / Used    (deg)     (95%)   (mdeg/m)  (sec)   (/deg)');
        fprintf(Id,'%s\n\n', ...
            '------  -----------  ---------  -------  --------  ------  ------');
        fprintf(Id, ...
            '%4d %7d / %2d %10.3f %10.1e %9.3f %6d %8.3f\n',FrictionalResults);
        
        if ~PulseData
          fprintf(Id,'\n%s\n\n', ...
            '-----------------------------------------------------------------');
        end
        
        % Print end of frictional decay
        % -----------------------------
        fprintf(Id, '\n%s\n', ['*********   ' char(datetime('now')) ...
                ' - End frictional decay reduction of Trial ' int2str(Trial) ' !   ' ...
                '*********']);



        
        
        