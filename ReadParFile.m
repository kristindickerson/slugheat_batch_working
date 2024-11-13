%%% =======================================================================
%%   Purpose: 
%       This function reads in the parameters from .par file 	
%       -- The parameter (.par) file defines the default parameters to run the 
%          program. User can edit the text file or manually change
%          parameters in SlugHeat GUI.
%%   Last edit:
%       01/14/2023 by Kristin Dickerson, UCSC
%%% =======================================================================

function  [S_ParFile, ...
        NumberOfSensors, ...	
        WaterThermistor, ...
        TimeScalingFactor, ...
        DeltaTime, ...
        SensorRadius, ...
        SensorDistance, ...
        TempError, ...
        CalibrationCoeffs, ...
        HyndmanCoeffs, ...
        FrictionalDelays, ...
        FricMaxStep, ...
        TimeInc, ...
        FricTauMin, ...
        FricTauMax, ...
        PulseDelays, ...
        kInit, ...
        ktype, ...
        PulsePower, ...
        TimeShiftInit, ...
        TimeShiftInc, ...
        PulseMaxStep, ...
        kTolerance, ...
        PulseTauMin, ...
        PulseTauMax, ...
        HeatPulseLength, ...
        MinTotalkChange, ...
        MaxNumberOfIterations, ...
        MaxSAIterations, ...
        Sigmak0, ...
        kMin, ...
        kMax, ...
        MinThickness, ...
        kAnisotropy, ...
        TopSensorDepth, ...
        ProbeLength, ...
        Offset] = ReadParFile(ParFile, ProgramLogId, ParFileName, ~)

% ===========================================
% If using generic PAR file (SlugHeat22.par)
% ===========================================

if contains(ParFileName,'SlugHeat22')
    
    % Initialize
    % ----------

    % Opens the parameter file
    fid = fopen(ParFile);

    % Finds all Carriage Line Returns (ascii code = 10) 
    Lookup = fread(fid,inf);
    CR = find(Lookup==10);
    
    % ==============================================
    %             Reading parameters
    % ==============================================
    
    % Line 1: Number of sensors
    fseek(fid,0,'bof');
    NumberOfSensors = fscanf(fid,'%d',1);
    
    % Line 2: Is there a water thermistor ?
    fseek(fid,CR(1)+1,'bof');
    WaterThermistor = fscanf(fid,'%d',1);
    
    % Line 3: Time scaling factor (sec/unit)
    fseek(fid,CR(2)+1,'bof');
    TimeScalingFactor = fscanf(fid,'%g',1);
    
    % Line 4: Time between thermistor readings (sec)
    fseek(fid,CR(3)+1,'bof');
    DeltaTime = fscanf(fid,'%g',1);
    
    % Line 5: Sensor radius (m)
    fseek(fid,CR(4)+1,'bof');
    SensorRadius = fscanf(fid,'%g',1);
    
    % Line 6: Distance between sensors (m)
    fseek(fid,CR(5)+1,'bof');
    SensorDistance = fscanf(fid,'%g',1);
    
    % Line 7: Assumed temperature error (K)
    fseek(fid,CR(6)+1,'bof');
    TempError = fscanf(fid,'%g',1);
    
    % Line 8: Length of heat pulse (sec)
    fseek(fid,CR(7)+1,'bof');
    HeatPulseLength = fscanf(fid,'%g',1);
    
    % Line 9, 10 & 11: Calibration coefficients
    % Readings to milliKelvins
    
    Format = repmat('%g,',1,NumberOfSensors);
    Format = [Format '%g'];
    fseek(fid,CR(9)+1,'bof');
    qc = fscanf(fid,Format,NumberOfSensors+WaterThermistor)'; % quadratic coefficients
    fseek(fid,CR(10)+1,'bof');
    bb =  fscanf(fid,Format,NumberOfSensors+WaterThermistor)'; % readings to milliKelvins 
    fseek(fid,CR(11)+1,'bof');
    cc =  fscanf(fid,Format,NumberOfSensors+WaterThermistor)';
    
    CalibrationCoeffs = [qc;bb;cc];
    
    % Line 12: Hyndman Coefficients for k
    fseek(fid,CR(12)+1,'bof');
    HyndmanCoeffs = fscanf(fid,'%g %g %g',3)';
    
    % Line 13: Frictional time delays (sec)
    Format = repmat('%g ',1,NumberOfSensors);
    Format = [Format '%g'];
    fseek(fid,CR(13)+1,'bof');
    FrictionalDelays = fscanf(fid,Format,NumberOfSensors)';
    
    % Line 14: Maximum number of steps and Time
    % increment in frictional delay calculation (sec)
    fseek(fid,CR(14)+1,'bof');
    FricMaxStep = fscanf(fid,'%g',1);
    TimeInc = fscanf(fid,'%g',1);
    
    % Line 15: Minimum and max Tau values used for the 
    % frictional delay
    fseek(fid,CR(15)+1,'bof');
    FricTauMin = fscanf(fid,'%g',1);
    FricTauMax = fscanf(fid,'%g',1);
    
    % Line 16: Pulse time delays (sec)
    fseek(fid,CR(16)+1,'bof');
    PulseDelays = fscanf(fid,Format,NumberOfSensors)';
    
    % Line 17: Initial Conductivities (W m/K)
    fseek(fid,CR(17)+1,'bof');
    ktype=fscanf(fid,Format,1);
    fseek(fid,CR(17)+1,'bof');
    if ktype == 99
      kInit = fscanf(fid,Format,7)';
    else 
      kInit = fscanf(fid,Format,NumberOfSensors)';
    end

    kInit(1) = [];
    
    % Line 18: Heat pulse power (J/m/s)
    fseek(fid,CR(18)+1,'bof');
    PulsePower = fscanf(fid,'%g',1);
    
    % Line 19: Initial time shit & Increment (sec)
    fseek(fid,CR(19)+1,'bof');
    TimeShiftInit = fscanf(fid,'%g',1);
    TimeShiftInc  = fscanf(fid,'%g',1);
    
    % Line 20: Maximum iteration number & error
    % tolerance on conductivity iteration
    fseek(fid,CR(20)+1,'bof');
    PulseMaxStep = fscanf(fid,'%g',1);
    kTolerance = fscanf(fid,'%g',1);
    
    % Line 21: Minimum and max Tau values used for the
    % heat pulse delay
    fseek(fid,CR(21)+1,'bof');
    PulseTauMin = fscanf(fid,'%g',1);
    PulseTauMax = fscanf(fid,'%g',1);
    
    % KD: added these that were hard coded, now in the PAR file
    % ---------------------------------------------------------
    % Line 22: Minimum change of Sigma(k)
    fseek(fid,CR(22)+1,'bof');
    MinTotalkChange = fscanf(fid,'%g',1);
    
    % Line 23: Maximum number of iterations for k computations
    fseek(fid,CR(23)+1,'bof');
    MaxNumberOfIterations = fscanf(fid,'%g',1);
    
    % Line 24: Number of Iterations for Sensitivity analysis
    fseek(fid,CR(24)+1,'bof');
    MaxSAIterations = fscanf(fid,'%g',1);
    
    % Line 25: Standard deviation in k for Sensitivity analysis
    fseek(fid,CR(25)+1,'bof');
    Sigmak0 = fscanf(fid,'%g',1);
    
    % Line 26: Minimum thermal conductivity cutoff for Sensitivity analysis
    fseek(fid,CR(26)+1,'bof');
    kMin = fscanf(fid,'%g',1);
    
    % Line 27: Maximum thermal conductivity cutoff for Sensitivity analysis
    fseek(fid,CR(27)+1,'bof');
    kMax = fscanf(fid,'%g',1);
    
    % Line 28: Mininum layer thickness for Sensitivity analysis
    fseek(fid,CR(28)+1,'bof');
    MinThickness = fscanf(fid,'%g',1);
    
    % Line 30: Horizontal thermal conductivity Anisotropy
    fseek(fid,CR(29)+1,'bof');
    kAnisotropy = fscanf(fid,'%g',1);
    
    % Line 31: Depth of first thermistor below weight stand
    %       1.86 = MH SlugHeat 15 6 m probe - 13 sensors with 11 active
    %       0.25 = Traditional 3.5m probe - 11 sensors 
    fseek(fid,CR(30)+1,'bof');
    TopSensorDepth = fscanf(fid,'%g',1);
    
    % Line 32: Length of probe
    fseek(fid,CR(31)+1,'bof');
    ProbeLength = fscanf(fid,'%g',1);

    % Line 33: Length of probe
    fseek(fid,CR(32)+1,'bof');
    Offset = fscanf(fid,'%g',1);


% =========================================================================
% If using PENETRATION SPECIFIC PAR file (chinook_HF2_P1.par, for example
% =========================================================================
else
    opts = detectImportOptions(ParFile, 'FileType','text');
    opts = setvartype(opts,'string');  
    T_ParFile = readtable(ParFile, opts);
    Parameters = T_ParFile.Params;

    cc1 = str2double(split(Parameters(9))');
    cc2 = str2double(split(Parameters(10))');
    cc3 = str2double(split(Parameters(11))');
     
     NumberOfSensors       = str2double(Parameters(1));
     WaterThermistor       = str2double(Parameters(2));
     TimeScalingFactor     = str2double(Parameters(3));
     DeltaTime             = str2double(Parameters(4));
     SensorRadius          = str2double(Parameters(5));
     SensorDistance        = str2double(Parameters(6));
     TempError             = str2double(Parameters(7));
     HeatPulseLength       = str2double(Parameters(8));
     CalibrationCoeffs     = [cc1;cc2;cc3];
     HyndmanCoeffs         = str2double(split(Parameters(12))');
     FrictionalDelays      = str2double(split(Parameters(13))');
     FricMaxStep           = str2double(Parameters(14));
     TimeInc               = str2double(Parameters(15));
     FricTauMin            = str2double(Parameters(16));
     FricTauMax            = str2double(Parameters(17));
     PulseDelays           = str2double(split(Parameters(18))');
     ktype                 = str2double(Parameters(19));
     kInit                 = str2double(split(Parameters(20))');
     PulsePower            = str2double(Parameters(21));
     TimeShiftInit         = str2double(Parameters(22));
     TimeShiftInc          = str2double(Parameters(23));
     PulseMaxStep          = str2double(Parameters(24));
     kTolerance            = str2double(Parameters(25));
     PulseTauMin           = str2double(Parameters(26));
     PulseTauMax           = str2double(Parameters(27));
     MinTotalkChange       = str2double(Parameters(28));
     MaxNumberOfIterations = str2double(Parameters(29));
     MaxSAIterations       = str2double(Parameters(30));
     Sigmak0               = str2double(Parameters(31));
     kMin                  = str2double(Parameters(32));
     kMax                  = str2double(Parameters(33));
     MinThickness          = str2double(Parameters(34));
     kAnisotropy           = str2double(Parameters(35));
     TopSensorDepth        = str2double(Parameters(36));
     ProbeLength           = str2double(Parameters(37));
     Offset                = str2double(Parameters(38));

end

% Print action to LOG file
% -------------------------
    PrintStatus(ProgramLogId, ['-- Reading in parameters from parameters ' ...
        'file'],2)

% Make app parameters strings so they can be concactated for 
% writing a new PAR file
% -------------------------------------------------------------------------
    numsens      = num2str(NumberOfSensors);
    wt           = num2str(WaterThermistor);
    tsf          = num2str(TimeScalingFactor);
    dt           = num2str(DeltaTime);
    sr           = num2str(SensorRadius);
    sd           = num2str(SensorDistance);
    te           = num2str(TempError);
    hpl          = num2str(HeatPulseLength);
    cc           = num2str(CalibrationCoeffs);
    hc           = join(string(HyndmanCoeffs));
    fd           = num2str(FrictionalDelays);
    maxstep      = num2str(FricMaxStep);
    ti           = num2str(TimeInc);
    fmin         = num2str(FricTauMin);
    fmax         = num2str(FricTauMax);
    pd           = num2str(PulseDelays);
    kt           = num2str(ktype);
    initialk     = join(string(kInit));
    pp           = num2str(PulsePower);
    tsi          = num2str(TimeShiftInit);
    tsinc        = num2str(TimeShiftInc);
    pmaxstep     = num2str(PulseMaxStep);
    ktol         = num2str(kTolerance);
    pmax         = num2str(PulseTauMin);
    pmin         = num2str(PulseTauMax);
    mintolchange = num2str(MinTotalkChange);
    maxit        = num2str(MaxNumberOfIterations);
    maxsait      = num2str(MaxSAIterations);
    sigk         = num2str(Sigmak0);
    ksamin       = num2str(kMin);
    ksamax       = num2str(kMax);
    minthick     = num2str(MinThickness);
    kani         = num2str(kAnisotropy);
    tsd          = num2str(TopSensorDepth);
    pl           = num2str(ProbeLength);
    off          = num2str(Offset);
    
    S_ParFile.Params = [...
            numsens ; ...
            wt ; ...
            tsf ; ...
            dt ; ...
            sr ; ...
            sd ; ...
            te ; ...
            hpl; ...
            cc ; ...
            hc ; ...
            fd ; ...
            maxstep ; ...
            ti ; ...
            fmin ; ...
            fmax ; ...
            pd ; ...
            kt ; ...
            initialk; ... 
            pp ; ...
            tsi ; ...
            tsinc ; ...
            pmaxstep; ... 
            ktol ; ...
            pmax ; ...
            pmin ; ...
            mintolchange ; ... 
            maxit ; ...
            maxsait ; ...
            sigk ; ...
            ksamin; ...
            ksamax ; ...
            minthick; ... 
            kani ; ...
            tsd ; ...
            pl ; ...
            off];
    
    S_ParFile.Description = [" number of sensors (excluding water T)"; ...
             " water temperature thermistor? 1:Y 0:N"; ...
             " time scaling factor (sec/unit)"; ...
             " time between thermistor readings (s)"; ...
             " radius of the sensor (m)"; ...
             " distance between sensors (m)"; ...
             " assumed temperature error (K)"; ...
             " length of heat pulse (s)"; ...
             " quadratic coefficients"; ...
             " quadratic coefficients"; ...
             " quadratic coefficients"; ...
             " kappa=function(k)-coeff."; ...
             " frictional time delays (s)"; ...
             " frictional max step"; ...
             " time increment (s)"; ...
             " frictional min tau value"; ...
             " fricitonal max tau value"; ...
             " pulse time delays (s)"; ...
             " if 99, the initial function exists"; ...
             " initial thermal conductivities (k) function"; ...
             " pulse power per length (J/m)"; ...
             " initial time shift (s)"; ...
             " time shift increment (s)"; ...
             " heat pulse max step"; ...
             " k tolerance (W/m°C)"; ...
             " pulse min tau value"; ...
             " pulse max tau value"; ...
             " convergence criteria - minimum change of Sigma(k) (W/m°C)"; ...
             " max # of iterations for k"; ...
             " number of iterations for sensitivity analysis"; ...
             " standard deviation in k for sensitivity analysis"; ...
             " min k cutoff for sensitivity analysis (W/m°C)"; ...
             " max k cutoff for sensitivity analysis (W/m°C)"; ...
             " mininum layer thickness for sensitivity analysis (m)"; ...
             " k bias in the horizontal direction"; ...
             " depth of first thermistor below weight stand (m)";...
             " probe length (m)";...
             " manual offset (°C)"];

