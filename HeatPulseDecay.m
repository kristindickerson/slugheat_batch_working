%%% ======================================================================
%%  Purpose: 
%       This function computes thermal conductivities for each sensor
%       iteratively from the thermal response following the calibrated heat
%       pulse 
%%  Last edit:
%       08/11/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function [ ...
            MeankPointAtMinkDiff, ...
            kSlopeAtMinkDiff, ...
            MeankPointAtZeroInfTemp, ...
            MeankPointAtMinRMS, ...
            kSlopeAtZeroInfTemp, ...
            kSlopeAtMinRMS, ...
            TempAtInf, ...
            NumberOfUsedPoints, ...
            MinimumPulseDelays, ...
            kError, ...
            HeatPulseTime, ...
            MinkDiffShift, ...
            ShiftedTime, ...
            DataTemp, ...
            TimeShifts, ...
            kSlopeRMS, ...
            TempAtInfinity, ...
            OneOverTime, ...
            kSlope,  ...
            DataLimits ...
                ] = HeatPulseDecay( ...
                figure_Main,...
                SensorsToUse, ...
                PulseTime, ...
                PulseDelays, ...
                MinimumFricEqTemp, ...
                MinimumFricSlope, ...
                PulseTemp, ...
                Currentk, ...
                HyndmanCoeffs, ...
                SensorRadius, ...	
                PulseMaxStep, ...
                TimeShiftInc, ...
                PulseTauMin, ...
                PulseTauMax, ...
                PulsePower, ...
                HeatPulseLength, ...
                NumberOfSensors)  

%% Compute
    
    %% Initialize heat pulse decay processing
    % ---------------------------------------

    NumberOfSensorsUsed = length(SensorsToUse);
    
    load('SlugHeat22.mat', 'Tau00Data', 'FAT00')
    
    Alpha=2.0;                  % Set to a constant value
    LIT = length(PulseTime);
    HC = HyndmanCoeffs;
    Kappa = repmat(1e-6*Currentk(SensorsToUse)./(HC(1) ...
        - HC(2)*Currentk(SensorsToUse) ...
        + HC(3)*Currentk(SensorsToUse).^2),LIT,1);
    ResidualTime = repmat(PulseTime,[1 NumberOfSensorsUsed]);

    %% Try to get heat pulse time. If it is outside the penetrattion 
    %% time window, inform user 
    %try
        HeatPulseTime = repmat(PulseTime-PulseTime(1), ...
            [1 NumberOfSensorsUsed])-HeatPulseLength/2;
    %catch
    %    disp(['Heat pulse time is outside penetration ' ...
    %        'time. ' ...
    %        'Must adjust timing of heat pulse or ignore heat pulse ' ...
    %        'reduction.'])
    %    MeankPointAtMinkDiff = [];
    %    kSlopeAtMinkDiff = [];
    %    MeankPointAtZeroInfTemp = [];
    %    MeankPointAtMinRMS = [];
    %    kSlopeAtZeroInfTemp = [];
    %    kSlopeAtMinRMS = [];
    %    TempAtInf = [];
    %    NumberOfUsedPoints = [];
    %    MinimumPulseDelays = [];
    %    kError = [];
    %    HeatPulseTime = [];
    %    MinkDiffShift = [];
    %    ShiftedTime = [];
    %    DataTemp = [];
    %    TimeShifts = [];
    %    kSlopeRMS = [];
    %    TempAtInfinity = [];
    %    OneOverTime = [];
    %    kSlope = [];
    %    DataLimits = [];
    %    return
    %end
    
    %% Obtain Tau and  F(α,τ) values corresponding to Time
    % --------------------------------------------------------
    ResidualTau = Kappa.*ResidualTime/(SensorRadius^2);
    HeatPulseTau = Kappa.*HeatPulseTime/(SensorRadius^2);
    ResidualTauIndex = round(ResidualTau/Tau00Data(2));
    HeatPulseTauIndex = round(HeatPulseTau/Tau00Data(2));
    
    %% Don't consider data for Tau<=0 and,
    %% if greater than the maximum Tau of FAT00, approximate it with 
    %% 1/2AlphaTau !
    % ----------------------------------------------------------------
    
    ResidualTauIndex(ResidualTauIndex > Tau00Data(3)/Tau00Data(2)) = ...
        length(FAT00) + 1;
    HeatPulseTauIndex(HeatPulseTauIndex > Tau00Data(3)/Tau00Data(2)) = ...
        length(FAT00) + 1;
    ResidualTauIndex(ResidualTauIndex < 1) = length(FAT00) + 2;
    HeatPulseTauIndex(HeatPulseTauIndex < 1) = length(FAT00) + 2;
    FAT00(end+1) = 9;
    FAT00(end+1) = NaN;
    
    ResidualFAT = FAT00(ResidualTauIndex);
    HeatPulseFAT = FAT00(HeatPulseTauIndex);   
    
    iRF = find(ResidualFAT>8);
    iHPF = find(HeatPulseFAT>8);
    ResidualFAT(iRF) = 1./(4*ResidualTau(iRF))-1./(8*ResidualTau(iRF).^2);
    HeatPulseFAT(iHPF) = 1./(4*HeatPulseTau(iHPF))-1./(8*HeatPulseTau(iHPF).^2);
    
    %% Compute and remove residual temperature of the frictional decay
    % ---------------------------------------------------------------
    
    ResidualTemp = repmat(MinimumFricEqTemp(SensorsToUse)',LIT,1) ...   
        +  repmat(MinimumFricSlope(SensorsToUse)',LIT,1).*ResidualFAT;
    Temp = PulseTemp(:,SensorsToUse)-ResidualTemp; 
    
    %% Correct the heat pulse decay for early Tau
    % ------------------------------------------
    
    CorrectedTemp = Temp./(2*Alpha*HeatPulseTau.*HeatPulseFAT);
    
    %% Apply Tau window to heat pulse data
    % -----------------------------------
    
    DataTemp = NaN*ones(size(CorrectedTemp));
    [i,j] = find(HeatPulseTau > PulseTauMin & HeatPulseTau < PulseTauMax);
    DataTemp(i,j) = CorrectedTemp(i,j);
    DataTemp = repmat(DataTemp,[1 1 PulseMaxStep]);
    
   %% Compute time shifts
   % -------------------
   
   TimeShifts = repmat(PulseDelays(SensorsToUse),[PulseMaxStep 1]) ...
       + repmat(-TimeShiftInc*(0:PulseMaxStep-1)',[1 NumberOfSensorsUsed]);
   
   ShiftedTime = repmat(PulseDelays(SensorsToUse),[LIT 1 PulseMaxStep]) ...
       + repmat(HeatPulseTime,[1 1 PulseMaxStep]) ...
       + repmat(permute(-TimeShiftInc*(0:PulseMaxStep-1),[3 1 2]), ...
       [LIT NumberOfSensorsUsed 1]);

   %% Compute 1/time and remove infinite and negative 1/time
   % ------------------------------------------------------
   
   ShiftedTime(ShiftedTime<=0) = NaN;
   OneOverTime = 1./ShiftedTime;
   
   %% Get rid of NaNs in OneOverTime and DataTemp and make 2-D arrays
   % ---------------------------------------------------------------
   
   [ix,~] = find(~isnan(OneOverTime));
   [iy,~] = find(~isnan(DataTemp));
   
   DataLimits = [max([min(ix) min(iy)]) min([max(ix) max(iy)])];
   NumberOfUsedPoints = 1+diff(DataLimits);
   clear ix iy jx jy
   
   X = reshape(OneOverTime(DataLimits(1):DataLimits(2),:,:), ...
       [NumberOfUsedPoints NumberOfSensorsUsed*PulseMaxStep]);
   Y = reshape(DataTemp(DataLimits(1):DataLimits(2),:,:), ...
       [NumberOfUsedPoints NumberOfSensorsUsed*PulseMaxStep]);

   
   [a,b,~,~,Chi2] = ChiSquaredFit(X,Y);
   
   kSlope = (PulsePower/4/pi)./reshape(b,[NumberOfSensorsUsed PulseMaxStep]);
   TempAtInfinity = reshape(a,[NumberOfSensorsUsed PulseMaxStep]);
   kSlopeRMS = sqrt(reshape(Chi2,[NumberOfSensorsUsed PulseMaxStep])/(NumberOfUsedPoints-2));
   
   %% Calculate kPoint for all delays and average and variance of kPoint
   % -----------------------------------
   
   kPoint = reshape(PulsePower.*X./(4*pi.*Y),[NumberOfUsedPoints NumberOfSensorsUsed PulseMaxStep]);
   
   kPointMean = squeeze(mean(kPoint));
   
   %% Find the k's corresponding to the minimum RMS or to Zero asymptotic temperature
   % -------------------------------------------------------------------------------
   
   kError = NaN*zeros(NumberOfSensors,1);
   kSlopeAtMinkDiff = NaN*zeros(NumberOfSensors,1);
   MeankPointAtMinkDiff = NaN*zeros(NumberOfSensors,1);
   MeankPointAtZeroInfTemp = NaN*zeros(NumberOfSensors,1);
   kSlopeAtZeroInfTemp = NaN*zeros(NumberOfSensors,1);
   kSlopeAtMinRMS = NaN*zeros(NumberOfSensors,1);
   MeankPointAtMinRMS = NaN*zeros(NumberOfSensors,1);
   MinimumPulseDelays = NaN*zeros(NumberOfSensors,1);
   TempAtInf = NaN*zeros(NumberOfSensors,1);
   
   kDiff = abs(kSlope-repmat(Currentk(SensorsToUse)',[1 PulseMaxStep]));
   kTypeDiff = abs(kSlope-kPointMean);

   [~,MinkDiffShift] = min(kDiff,[],2);
   [~,~] = min(kTypeDiff,[],2);
   [~,MinkSlopeRMSIndex] = min(2*kSlopeRMS,[],2);
   [dummy,ZeroInfTempIndex] = min(abs(TempAtInfinity),[],2);
   
   kError(SensorsToUse) = dummy;
   kSlopeAtMinkDiff(SensorsToUse) = diag(kSlope(:,MinkDiffShift));
   MeankPointAtMinkDiff(SensorsToUse) = diag(kPointMean(:,MinkDiffShift));
   MeankPointAtZeroInfTemp(SensorsToUse) = diag(kPointMean(:,ZeroInfTempIndex));
   kSlopeAtZeroInfTemp(SensorsToUse) = diag(kSlope(:,ZeroInfTempIndex));
   MeankPointAtMinRMS(SensorsToUse) = diag(kPointMean(:,MinkSlopeRMSIndex));
   kSlopeAtMinRMS(SensorsToUse) = diag(kSlope(:,MinkSlopeRMSIndex));
   MinimumPulseDelays(SensorsToUse) = diag(TimeShifts(MinkDiffShift,:));
   TempAtInf(SensorsToUse) = diag(TempAtInfinity(:,MinkDiffShift));






