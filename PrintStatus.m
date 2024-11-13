%%% =======================================================================
%%  Purpose: 
%       This function is used to print out the current status of of the
%       program onto an output file, generally either the log (.log) file 
%       or results (.res) file
% 
%	    FileID = file to be written on
%	    Message = message to be written
%	    LineFeed = how many lines to move cursor to after message 
%       (i.e if LineFeed = 1, the next message will be written on the line 
%       directly under the current message. if LineFeed = 2, there cursor 
%       will skip a line and there will be a space between the current 
%       message and next message)
%% Last edit:
%       08/23/2023 by Kristin Dickerson, UCSC
%%% ======================================================================

function PrintStatus(FileID, Message,LineFeed)

if nargin<3
	fprintf(FileID,'%s', Message);
else
	Format = ['%s', repmat('\n',1,LineFeed)];
	fprintf(FileID,Format,Message);
end

end