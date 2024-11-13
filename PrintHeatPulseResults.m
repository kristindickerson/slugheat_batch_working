%%% ======================================================================
%%   Purpose: 
%       This function prints results of frictional decay processing to 
%       results (.res) files
%%   Last edit:
%       08/08/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function PrintHeatPulseResults(PulseTime, NumberOfUsedPoints, MeankPointAtMinkDiff, ...
    kError, TempAtInf, MinimumPulseDelays, kSlopeAtMinkDiff, ...
    MeankPointAtZeroInfTemp, MeankPointAtMinRMS, kSlopeAtMinRMS, ...
    kSlopeAtZeroInfTemp, Iteration, ResFileId, SensorsToUse, Trial)


    %% Organize frictional results
    % ----------------------------
    NumberOfSensorsUsed = length(SensorsToUse);
    
        a = SensorsToUse';
        b = repmat(length(PulseTime),NumberOfSensorsUsed,1);
        c = repmat(NumberOfUsedPoints,NumberOfSensorsUsed,1);
        d = MeankPointAtMinkDiff(SensorsToUse);
        e = kError(SensorsToUse);
        f = TempAtInf(SensorsToUse);
        g = MinimumPulseDelays(SensorsToUse);
        h = kSlopeAtMinkDiff(SensorsToUse);
        i = MeankPointAtZeroInfTemp(SensorsToUse);
        j = MeankPointAtMinRMS(SensorsToUse);
        k = kSlopeAtMinRMS(SensorsToUse);
        l = kSlopeAtZeroInfTemp(SensorsToUse);
    
        HeatPulseResults = [a b c d e f g h i j k l]';
    
    %% Print only FINAL iteration to results (.res) file 
    % ==========================================
    Id = ResFileId;
    
    fprintf(Id,'%s\n',' ');
    fprintf(Id,'%s',['Heat Pulse Decay - Iteration ' num2str(Iteration, ...
        '%02d')]);
    if Iteration > 1    
        fprintf(Id,'\n%s\n\n', ...
            ['=============================================================' ...
            '===========']);
    else
        fprintf(Id,'\n%s\n\n', ...
            '===============================');   
    end
    fprintf(Id,'%s\n', ...
        'Sensor  Data Points Mean kPoint Error  Eq. Temp  Delay    kSlope      kPt@Teq   kPt@minRMS   kSlp@minRMS  kSlp@Teq');
    fprintf(Id,'%s\n', ...
        '        Tot. / Used  (W/deg/m)  (95%)    (deg)    (sec)   (W/deg/m)   (W/deg/m)  (W/deg/m)    (W/deg/m)   (W/deg/m)');
    fprintf(Id,'%s\n\n', ...
        '------  -----------  ---------  -------  -------  -----  ----------  ---------  ----------  -----------  ----------');
    fprintf(Id, ...
        '%4i %7d / %2d %11.3f %9.1e %8.3f %5d %11.3f %11.3f %11.3f %11.3f %11.3f\n',HeatPulseResults);
    fprintf(Id,'\n%s\n\n\n', ...
        '-------------------------------------------------------------------------------------------------------------------');
    
    fprintf(Id, '\n%s\n', ['*********   ' char(datetime('now')) ...
            ' - End heat pulse decay reduction of Trial ' int2str(Trial) ' !   *********']);
    
    
    fprintf(Id, '\n\n\n');
    