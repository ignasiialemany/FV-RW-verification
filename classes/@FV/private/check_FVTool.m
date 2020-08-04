function [hasFVTool] = check_FVTool(required)
% checks if the FVTool is activated and if not, tries to do so

% handle input arguments
narginchk(0, 1);
if nargin == 0
    required = false;
end

% set function to handle messages if the tool is not found
if required
    errfun = @error;
else
    errfun = @warning;
end

hasFVTool = false; % initialise as false in case we don't throw an error

if exist('CellVariable', 'class') && exist('solvePDE', 'file') % test two things
    % good to go
    hasFVTool = true;
else % class does not exist
    if exist('FVToolStartUp', 'file') % on path, not activated
        hasFVTool = startup_FVTool(errfun);
    else % script not on path
        % we are trying local FVTool (e.g. with git submodule)
        thisdir = fileparts(mfilename('fullpath'));
        fvtooldir = fullfile(thisdir, 'FVTool');
        if exist(fvtooldir, 'dir')
            if exist(fullfile(fvtooldir, 'FVToolStartUp.m'), 'file')
                addpath(fvtooldir);
                hasFVTool = startup_FVTool(errfun);
            else
                errfun('Found FVTool directory "%s", but no startup script!', fvtooldir);
            end
        else
            errfun('No FVTool directory found!');
        end
    end
end

end

function success = startup_FVTool(errfun)
% start the FVTool safely

bakdir = cd();
bakpath = path();

try
    FVToolStartUp(); % load FVTool
    success = true;
catch me
    success = false; % did not succeed
    path(bakpath); % reset path in case the tool failed half-way
    errfun(me.identifier, '%s', me.message); % rethrow
end

cd(bakdir); % FVToolStartUp does `cd`, so we now return to where we were

end
