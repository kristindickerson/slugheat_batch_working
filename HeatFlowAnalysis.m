%%% ======================================================================
%%   Purpose: 
%       This function computes heat flow using the Bullard method 
%%   Last edit:
%       08/09/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function   [ ...
             SensorsUsedForBullardFit, ...
             GoodkIndex, ...
             CTRToUse, ... 
             CTR, ...
             ShiftedCTR, ...
             ShiftedRelativeDepths, ...
             TToUse, ...
             kToUse, ...
             PenetrationLag, ...
             Slope, ...
             Shift, ...
             HeatFlow, HFErr, ...
             HFShift, HFShiftErr, ...
             Averagek, kErr, ...
             Gradient, GradErr, ...
             GradShift, GradShiftErr] = HeatFlowAnalysis(NumberOfSensors, ...
             RelativeDepths, ...
             Currentk, ...
             MinimumFricEqTemp, ...
             Badk, ...
             BadT, ...
             SensorsToUse)

    %% Define what sensors to use
    % --------------------------
    GoodT = setxor(1:NumberOfSensors,BadT);
    Goodk = setxor(1:NumberOfSensors,Badk);
    
    TToUse = intersect(GoodT,SensorsToUse);    % SensorsToUse for temperature calculations (T)
    kToUse = intersect(Goodk,SensorsToUse);    % SensorsToUse for thermal conductivity calculations (k)

    
    %% Least-squares fit of the temperatures 
    % --------------------------------------------------

    MinimumFricEqTemp = MinimumFricEqTemp';
    
    % ====================================================================
    %%           ORIGINAL ERROR ASSESSMENT for TEMPERATURES
    %              - this is a similar error assessment as
    %                described in Villinger and Davis, 1987

            %% NOTE:
            % pz returns a vector of coefficients for a polynomial with 
            % 1 degree 
            % y = mx + b
                % y = relative depths
                % x = equilibrium temperatures
                % m = pz(1) = slope of linear best fit line
                % b = pz(2) = y intercept of the linear best fit line

        %% Fit a linear regression through the data
        % ---------------------------------------
        [pz, ~] = polyfit(MinimumFricEqTemp(TToUse),RelativeDepths(TToUse),1);
    
        % Get the shift and slope
        Shift(1) = -pz(2);
        Slope(1) = pz(1);
        
        % Shift the relative depths so that the linear best fit line goes
        % through zero at the seafloor 
        ShiftedRelativeDepths = RelativeDepths + Shift(1);	
        
        % Define the shifted depth of the SHALLOWEST (top most) sensor as the
        % penetation lag (how far the shallowest sensor is form the seafloor)
        PenetrationLag(1) = ShiftedRelativeDepths(max(TToUse));  

    %%           ORIGINAL ERROR ASSESSMENT for TEMPERATURES
    % ====================================================================


    %% BP error assessment of thermal gradient
    % -----------------------------------------
    [ShiftGrad,SlopeGrad,ShiftGradErr,SlopeGradErr]=...
        ChiSquaredFit(MinimumFricEqTemp(TToUse)',RelativeDepths(TToUse)'); % BP
    ShiftGrad=-ShiftGrad;


    %% Compute Cumulative Thermal Resistance
    % -------------------------------------
    
    % Compute Cumulative Thermal Resistance using all conductivity 
    % estimations that are not ignored or discarded (even if the 
    % temperature was discarded)
    
    CTR = NaN*ones(NumberOfSensors,1);

    CTR(kToUse) = ShiftedRelativeDepths(max(kToUse))/Currentk(max(kToUse)) ...
        + fliplr(cumtrapz(fliplr(ShiftedRelativeDepths(kToUse)),1./fliplr(Currentk(kToUse))));
    
    % Now we need to determine the indices of the CTR vector that correspond to
    % to the valid temperatures (i.e., those not discarded - we can forget about the Sensors
    % originally ignored because their conductivities were ignored in the
    % Cumulative Thermal Resistance calculation.)
    
    %[CTRToUse, ~, ~] = intersect(TToUse,kToUse); 
    CTRToUse = kToUse;
    GoodkIndex=CTRToUse;
    SensorsUsedForBullardFit = CTRToUse;

        % ===========================================================
        %%            ORIGINAL ERROR ASSESSMENT for CTR
    
        % Get linear best fit line of temperature vs cumulative thermal resistance (instead of depth)
        % but only for sensors used in cumulative thermal resistance calculation
        [pR,~] = polyfit(MinimumFricEqTemp(CTRToUse),CTR(CTRToUse),1);
    
        % Define shift and slope of temperature vs CTR 
        Shift(2) = -pR(2);
        Slope(2) = pR(1);
    
        % Shift the cumulative thermal resistance so that the linear best fit 
        % line goes through zero when CTR is zero 
        ShiftedCTR = CTR + Shift(2);

        %%            ORIGINAL ERROR ASSESSMENT for CTR
        % ===========================================================


    %% BP error assessment of CTR
    % ---------------------------
    [ShiftCTR,SlopeCTR,ShiftCTRErr,SlopeCTRErr,~]=...
        ChiSquaredFit(MinimumFricEqTemp(CTRToUse)',CTR(CTRToUse)); % BP
    ShiftCTR=-ShiftCTR; 
   

%% Calculate thermal gradient, average k, and heat flow
% -------------------------------------------------
     
    % Calculate thermal gradient and depth to top sensor
    % -------------------------------------------------
    Gradient = 1/Slope(1);
    GradErr=mean([abs((1/SlopeGrad)-(1/(SlopeGrad+SlopeGradErr))),...
         abs((1/SlopeGrad)-(1/(SlopeGrad-SlopeGradErr)))]); % BP

    GradShift = ShiftGrad;
    GradShiftErr = mean([abs((ShiftGrad)-((ShiftGrad+ShiftGradErr))),...
            abs((ShiftGrad)-((ShiftGrad-ShiftGradErr)))]); % BP

    % Calculate average thermal conductivity +/- 1 std
    % ------------------------------------------------
    kmean = mean(Currentk(kToUse));
    kErr  = std(Currentk(kToUse));
    Averagek = kmean;

    % Calculate heat flow and heat flow shift
    % ---------------------------------------
    HeatFlow = round((1/Slope(2))*1000);
    HFErr=mean([abs((1/SlopeCTR)-(1/(SlopeCTR+SlopeCTRErr))),...
            abs((1/SlopeCTR)-(1/(SlopeCTR-SlopeCTRErr)))]); % BP
    HFErr = HFErr*1000;
    HFShift = ShiftCTR;
    HFShiftErr=mean([abs((ShiftCTR)-((ShiftCTR+ShiftCTRErr))),...
            abs((ShiftCTR)-((ShiftCTR-ShiftCTRErr)))]); % BP


    