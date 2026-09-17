%% Set up the MATLAB path for this repository
% Run this script from any working directory. It derives the repository root
% from its own location, adds source folders to the path, and checks the
% planned MATLAB product environment.

scriptPath = mfilename("fullpath");
scriptsDirectory = fileparts(scriptPath);
projectRoot = fileparts(scriptsDirectory);

if ~isfolder(projectRoot)
    error("Project root could not be resolved from: %s", scriptPath);
end

foldersToAdd = [ ...
    "scripts"
    "analysis"
    "models"
    "tests"
];

for folderIndex = 1:numel(foldersToAdd)
    folderPath = fullfile(projectRoot, foldersToAdd(folderIndex));
    if isfolder(folderPath)
        addpath(genpath(folderPath));
    end
end

resultsDirectory = fullfile(projectRoot, "results");
if ~isfolder(resultsDirectory)
    mkdir(resultsDirectory);
end

fprintf("Project root: %s\n", projectRoot);
fprintf("Project folders added to the MATLAB path.\n\n");
run(fullfile(scriptsDirectory, "check_environment.m"));
