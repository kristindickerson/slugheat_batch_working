%%% =======================================================================
%%  Purpose: 
%       This function determines "scatter" of heat flow and how it varies 
%       with decreasing the number of sensors.
%%  Last edit:
%       01/20/2024 by Kristin Dickerson, UCSC
%%% =======================================================================

function [Scatter, ...
        ScatterHeatFlow, ...
        Sigmaa, ...
        Sigmab] =  HeatFlowRegression(...
            SensorsUsedForBullardFit, ...
            GoodkIndex, ...
            ShiftedBullardDepths, ...
            MinimumFricEqTemp, ...
            MinimumFricError)

    %% Initiate
    % ----------
     MinimumFricEqTemp = MinimumFricEqTemp';
     MinimumFricError = MinimumFricError';

    % Go through N trials
    % -------------------
    lUsable = length(SensorsUsedForBullardFit);
    NFit = lUsable-2;

    A = zeros(1,length(NFit));
    B = zeros(1,length(NFit));
    Sigmaa = zeros(1,length(NFit));
    Sigmab = zeros(1,length(NFit));
    Chi2 = zeros(1,length(NFit));
    Scatter = zeros(1,length(NFit));
    Covab = zeros(1,length(NFit));
    rab = zeros(1,length(NFit));
    Q = zeros(1,length(NFit));

    % MH errortrap. If only 2 sensors penetrate, then the following loop will
    % crash - no purpose in doing the regression analysis. Simply return
    if NFit == 0
        Scatter = [];
        Sigmaa = [];
        Sigmab = [];
        return    
    end
    
    % Define what sensors to use
    % --------------------------
    
    BullardDepthsToUse = ShiftedBullardDepths(GoodkIndex);
    EqTempToUse = MinimumFricEqTemp(SensorsUsedForBullardFit);
    EqTempErrorToUse = MinimumFricError(SensorsUsedForBullardFit);
    idx = find(EqTempErrorToUse < 1e-8);
    if ~isempty(idx)
        EqTempErrorToUse(idx) = mean(EqTempErrorToUse)/100 + 1e-8;
    end    
    UseLength = lUsable;
    
    %% Scatter analysis using Chi2 function
    % -----------------------------------
    for i=1:NFit
        if length(1:UseLength-(NFit-i)) > 1
            X = BullardDepthsToUse(1:UseLength-(NFit-i));
            Y = EqTempToUse(1:UseLength-(NFit-i))';
            Sigma = EqTempErrorToUse(1:UseLength-(NFit-i))'/2;    
            [A(i),B(i),Sigmaa(i),Sigmab(i),Chi2(i),Scatter(i),Covab(i),rab(i),Q(i)] ...
                = ChiSquaredFit(X,Y,Sigma);
        end   
    end

    ScatterHeatFlow = B;
    ScatterHeatFlow = ScatterHeatFlow*1000;


