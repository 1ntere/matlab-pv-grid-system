%% Run STEP 5 averaged grid-side inverter simulation
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
addpath(stepDirectory);
run(fullfile(stepDirectory, "step05_inverter_parameters.m"));

inverterSimulation = simulate_grid_inverter(inverterParameters);
run(fullfile(stepDirectory, "plot_step05_results.m"));

resultDirectory = fullfile(projectRoot, "results", "step05");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end
summaryFile = fullfile(resultDirectory, "step05_summary.csv");
writetable(inverterSimulation.summary, summaryFile);

fprintf("\nAveraged Grid-Side Inverter Summary\n");
fprintf("Grid: %.1f V line-line RMS, %.1f Hz\n", ...
    inverterParameters.grid_voltage_ll_rms_V, inverterParameters.grid_frequency_Hz);
disp(inverterSimulation.summary);
fprintf("Saved STEP 5 summary: %s\n", summaryFile);
fprintf("Validate results in MATLAB before marking STEP 5 complete.\n");
