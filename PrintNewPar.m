%%% =======================================================================
%%   Purpose: 
%       This function prints all input parameters, whether they were changed
%       or not, to a new .par file that can be used to clearly see the
%       parameters used in this penetration. This can be used as the input
%       PAR file for other penetrations if desired instead of general
%       'SlugHeat22.par' file
%%   Last edit:
%       08/08/2023 by Kristin Dickerson, UCSC
%%% =======================================================================


function PrintNewPar(PulsePower, PenFileName, S_ParFile, CurrentPath, AppOutputs, isBatchMode)

    %% Update pulse power to match current
    % --------------------------------------
    S_ParFile.Params(21) = num2str(PulsePower);
    
    %% Make table of parameters and their descriptions and write to a
    %% new PAR file
    % ------------------------------------------------------------------
    T_ParFile = struct2table(S_ParFile);
    
    if isdeployed || isBatchMode
        writetable(T_ParFile, [AppOutputs PenFileName ...
            '-out/' [PenFileName '.par']], 'FileType','text', ...
            'Delimiter', '|');
    else
        writetable(T_ParFile, [CurrentPath '/outputs/' PenFileName(1:end-4) ...
            '-out/' [PenFileName(1:end-4) '.par']], 'FileType','text', ...
            'Delimiter', '|');
    end
