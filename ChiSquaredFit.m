%%% =======================================================================
%%   Purpose:
%       This function computes the linear regression and associated 
%       uncertaintiesfor whatever data is input. 
%%  Last edit:
%       01/10/2024 by Kristin Dickerson, UCSC
%%% =======================================================================

%% ============================================================================
%% Notes from Abdella Cherkaoui (original writer of this function):

    % function [a,b,Sigmaa,Sigmab,Chi2,Scatter,Covab,rab,Q] = ChiSqauredFit(X,Y,Sigma) - 02.22.2001
    %
    % CHI2FIT fits a linear function Y = a + b.X to N points (X,Y) with associated 
    % uncertainties (standard deviations) Sigma.  The fit minimizes Chi-square
    % which yields the maximum likelihood parameter estimation of a & b.  Note
    % that if the errors are not normally distributed then the estimations are
    % not maximum likelihood, but may still be useful in a practical sense.
    % Sigmaa and Sigmab are the probable uncertainty in the estimates of a & b.
    % Covab is the covariance of a & b and is required to estimate rab, the
    % coefficient of correlation  between the uncertainty in a & b. -1 < rab < 1
    % with negative values indicating an anticorrelation and positive ones a
    % normal correlation.
    % Q estimates the goodness-of-fit:  It is the probability that Chi2 exceeds 
    % a certain value of Chi2 by chance.  When Q is larger than 0.1 the goodness-
    % of-fit is believable; above 0.001 it remains acceptable.   Note that if
    % Sigma is unavailable then Sigma = 1 for all points which is equivalent to
    % assume a good fit and Q is meaningless.
    %
    % X, Y, and Sigma are either column vectors or matrices which columns 
    % correspond to multiple vectors x, y, Sigma to fit.
    %
    % Based on the FIT routine from Numerical Recipes (p.502-509, 1989 edition)
    %
    % Abdellah Cherkaoui - abdul@emerald.ucsc.edu

%% =============================================================================


function [a,b,Sigmaa,Sigmab,Chi2,Scatter,Covab,rab,Q] = ChiSquaredFit(X,Y,Sigma)

    %% Initialize
    % --------------
    
    [Dimension1, Dimension2] = size(X);
    if nargin<3 
        Sigma=ones(Dimension1,Dimension2); 
    end
    
    N = Dimension1;
    
    %% Compute intermediate sums
    % -------------------------
    
    S = repmat(sum(1./Sigma.^2),N,1);
    Sx = repmat(sum(X./Sigma.^2),N,1);
    Sy = repmat(sum(Y./Sigma.^2),N,1);
    t = (X-Sx./S)./Sigma;
    Stt = repmat(sum(t.^2),N,1);
    
    %% Compute output arguments
    % ------------------------
    
    b = repmat(sum((X-Sx./S).*Y./Sigma.^2),N,1)./Stt;
    a = (Sy-b.*Sx)./S;
    Sigmaa = sqrt((1+Sx.^2./S./Stt)./S);
    Sigmab = sqrt(1./Stt);
    Covab = -Sx./S./Stt;
    rab = Covab./(Sigmaa.*Sigmab);
    
    Chi2 = sum((Y-a-b.*X).^2./Sigma.^2);
    Scatter = sqrt(Chi2/(N-1));
    Q = 1-gammainc(Chi2/2,(N-2)/2);
    
    %% If Sigma is unavailable correct Sigmaa and Sigmab
    % -------------------------------------------------
    
    if nargin<3
        Sigmaa = Sigmaa.*sqrt(repmat(Chi2,N,1)/(N-2));
        Sigmab = Sigmab.*sqrt(repmat(Chi2,N,1)/(N-2));
    end
    
    %% Output results of first row only (it is repeated to vectorize calculations)
    % ---------------------------------------------------------------------------
    
    a = a(1,:);
    b = b(1,:);
    Sigmaa = Sigmaa(1,:);
    Sigmab = Sigmab(1,:);
    Covab = Covab(1,:);
    rab = rab(1,:);






