
%%% ==============================================================================
%% 	Purpose: 
%	    This function initializes SlugHeat
%%  Last edit:
%       02/23/2024 by Kristin Dickerson, UCSC
%%% ==============================================================================

function [Version, Update, ...
			NumberOfColumns, ...
			CurrentPath, CurrentDateTime, ...
            ParFile, ParFilePath, ParFileName, ...
            DefaultParFile, ...
    	    ProgramLogId, ...
            AppPath,...
            AppOutputs] =  InitializeProgram(isBatchMode)

    % Open temporary log file
    % -------------------------------------------------------
    if isdeployed || isBatchMode
        CurrentPath = pwd;
        CurrentDateTime = char(datetime('now'));
        ProgramLogId = fopen([CurrentPath,'/outputs/','SlugHeat22.log'], 'w');
        AppPath = pwd;
        AppOutputs = [AppPath '/outputs/'];
        if ~exist(AppOutputs, 'dir')
            mkdir([AppPath '/outputs/']);
        end
    else
        CurrentPath = [pwd '/']; % location of .par and .pen file should be placed in current folder before SlugHeat is run
        ProgramLogId = fopen([CurrentPath 'outputs/SlugHeat22.log'], 'w');
    
        AppPath = [];
        AppOutputs = [];

        CurrentDateTime = char(datetime('now'));
        
        PrintStatus(ProgramLogId, '----------------------------------------------',1);
        PrintStatus(ProgramLogId, '----------------------------------------------',1);
	    PrintStatus(ProgramLogId,['SlugHeat22 start time: ' CurrentDateTime],1)
	    PrintStatus(ProgramLogId, '----------------------------------------------',1);
	    PrintStatus(ProgramLogId, '----------------------------------------------',2);
    
	    PrintStatus(ProgramLogId, [CurrentDateTime ' Processing set up and data preparation'], 1)
	    PrintStatus(ProgramLogId, '==================================================================================================',2);
        
        % Parameters (PAR) file name and path  
        % ---------------------------------------------
        PrintStatus(ProgramLogId, ' -- Finding parameter file...',1);
    end

    % Define version information and other default parameters
    % -------------------------------------------------------
    Version = '22';                         % Version number
    Update = '2022';                        % Date of last update
    NumberOfColumns = 79;                   % # of columns in Log and Res files
    DefaultParFile = 'SlugHeat22.par';

	% *****************************************************************
	% If there is no default 'SlugHeat22.par' file in the current directory,
	%	User to choose new .par file
	% If there is 'SlugHeat22.par' in the current directory,
	%	This file is used as the default parameter file
	% *****************************************************************

    if ~exist('SlugHeat22.par', 'file')
        [ParFileName, ParFilePath] = uigetfile( ...
			[CurrentPath '*.par'], ...
			'Select parameter file');
    else
        ParFileName = 'SlugHeat22.par';
        if isdeployed || isBatchMode
            ParFile = fullfile(CurrentPath,ParFileName);
            ParFilePath = CurrentPath;
        else
            CurrentPath = [pwd '/']; % location of .par and .pen file should be placed in current folder before SlugHeat is run
            ParFilePath = CurrentPath;
        end
    end

    if ~isdeployed && ~isBatchMode
        ParFile = [ParFilePath ParFileName];
        PrintStatus(ProgramLogId, ['Parameter file: ' ParFile],2);
    end

