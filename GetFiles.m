%%% ====================================================================
%%  Purpose: 
%       This function gets these INPUT files:
%	    	1. Penetration (.pen) file -- text file created by SlugPen 
%           prior to running SlugHeat. This is the parsed data from each 
%           penetration needed to be processed by SlugHeat.
%           2. Temperature and pressure (.tap) file -- text file created 
%           by SlugPen prior to running SlugHeat.
%           3. MAT (.mat) file -- binary datafile created by SlugPen 
%           prior to running SlugHeat. This is the parsed data from each 
%           penetration needed to be processed by SlugHeat, but in .mat
%           form, housing all variables in structures rather than text.
%	    This function creates these OUPUT files:
%           1. Log (.log) file -- text file logging the individual
%           penetration's information and progress (this is different 
%           from SlugHeat22.log which was created at the start up of the 
%           application and records the entire progam's progress)
%           2. Results (.res) file -- text file recording all results of 
%           processing 
%%  Last edit:
%       01/19/2024 by Kristin Dickerson, UCSC
%%% ====================================================================

function 	[PenFileName, PenFilePath, PenFile, ...
			TAPName, TAPFileName, TAPFile, ...
            MATFileName, MATFile, ...
			LogFileName, LogFile, ...
			ResFileName, ResFile, ...
            LogFileId, ResFileId...
            ] = GetFiles(...
			CurrentPath, ProgramLogId, figure_Main, AppPath, isBatchMode, filePath, counter)
	
 	
% ====================================================================
% Get penetration (PEN) file. Create variables for names and paths of
% temp & pressure (TAP), mat (MAT), results (RES), and log (LOG) files
% -- all have same name as PEN file.
% ====================================================================

	% Penetration (PEN) file name and path
	% ---------------------------------------------
    PrintStatus(ProgramLogId, [' -- Finding penetration file from ' ...
        'SlugPen...'],1);

    %figure_Main.Interruptible='off';
    drawnow
    
    % Get pen file from user input
    % ----------------------------
    [PenFilePath, PenFileName, ~] = fileparts(filePath);

    % If there is no pen file, tell user the program needs to be restarted
    % -------------------------------------------------------------------
    if PenFileName==0
        disp('Program depricated. Please restart SlugHeat.')
        PenFileName=0;
        PenFilePath=0;
        PenFile=0;
		TAPName=0;
        TAPFileName=0;
        TAPFile=0;
        MATFileName=0;
        MATFile=0;
		LogFileName=0;
        LogFile=0;
		ResFileName=0;
        ResFile=0;
        LogFileId=0;
        ResFileId=0;
        return
    end

    %figure(figure_Main);

	PenFile = [PenFilePath '/' PenFileName '.pen'];

	PrintStatus(ProgramLogId, ['Penetration file: ' PenFile],2);

   
	% Results (RES), Log (LOG), Temperature & Pressure (TAP), and Variables 
    % from SlugPen workspace MAT files name and path
	% ---------------------------------------------------------------------

	TAPName = PenFileName;
    TAPFileName = [PenFileName '.tap'];
    MATFileName = [PenFileName '.mat'];
	ResFileName = [PenFileName '.res'];
	LogFileName = [PenFileName '.log'];

    % Make a directory for the results files for this penetration
    % ----------------------------------------------------------
    if isdeployed || isBatchMode
        PenPath = [AppPath '/outputs/' PenFileName '-out'];
        if ~exist(PenPath, 'dir')
            mkdir([AppPath '/outputs/'],[PenFileName '-out'])
        end
    else
        PenPath = [CurrentPath '/outputs/' PenFileName '-out'];
        if ~exist(PenPath, 'dir')
            mkdir([CurrentPath '/outputs/'],[PenFileName '-out'])
        end
    end
	
    TAPFile = [PenFilePath '/' TAPFileName];
    MATFile = [PenFilePath '/'  MATFileName];

    LogFile = [PenPath '/' LogFileName];
    LogFileId = fopen(LogFile,'w');
    
   
    % Ensure there is not an existing .res file in this directory that will
    % be overwritten. If there is an existing .res file with same name, ask
    % user whether to continue and overwrite or cancel and allow user to
    % move or rename the exitign .res file.
    % ---------------------------------------------------------------------
    ResFile = [PenPath '/' ResFileName];
    baseFilename = ResFileName(1:end-4);
    extension = '.res';

    if isfile(ResFile)
        % Increment the counter
        counter = counter + 1;
        % Create a new filename with the counter as suffix
        ResFile = [PenPath '/' baseFilename, '_',num2str(counter), extension];
        ResFileId = fopen(ResFile,'w');
    else
        ResFileId = fopen(ResFile,'w');
    end

    if isempty(ResFileId)
        return
    end
    
	

% Update SlugHeat22 Log file
% --------------------------

    % Temperature and pressure (TAP) file name and path
    PrintStatus(ProgramLogId, ' -- Finding tap file from SlugPen...',1);

	PrintStatus(ProgramLogId, ['TAP file: ' TAPFile],2);

   % Workspace variables MAT file name and path
    PrintStatus(ProgramLogId, ' -- Finding mat file from SlugPen...',1);

	PrintStatus(ProgramLogId, ['MAT file: ' MATFile],2);

    % Main parameters
    PrintStatus(ProgramLogId, [' -- Reading in parameters from parameter ' ...
    'file...'],1);


