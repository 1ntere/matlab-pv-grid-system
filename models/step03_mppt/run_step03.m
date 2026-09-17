%% Run STEP 3 P&O MPPT tracking simulation
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
step02Directory = fullfile(projectRoot, "models", "step02_pv_array");
addpath(step02Directory, stepDirectory);

run(fullfile(step02Directory, "step02_pv_parameters.m"));
run(fullfile(stepDirectory, "step03_mppt_parameters.m"));

mpptSimulation = simulate_po_mppt(moduleParameters, mpptParameters);
run(fullfile(stepDirectory, "plot_step03_mppt_results.m"));

resultDirectory = fullfile(projectRoot, "results", "step03");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end
summaryFile = fullfile(resultDirectory, "step03_tracking_summary.csv");
writetable(mpptSimulation.tracking_summary, summaryFile);

fprintf("\nP&O MPPT Summary\n");
disp(mpptSimulation.tracking_summary);
fprintf("Saved tracking summary: %s\n", summaryFile);
fprintf("STEP 3 finished. Validate the results in MATLAB before marking complete.\n");
