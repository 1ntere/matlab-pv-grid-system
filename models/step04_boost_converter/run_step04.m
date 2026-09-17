%% Run STEP 4 averaged Boost Converter and DC-link simulation
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
step02Directory = fullfile(projectRoot, "models", "step02_pv_array");
step03Directory = fullfile(projectRoot, "models", "step03_mppt");
addpath(step02Directory, step03Directory, stepDirectory);

run(fullfile(step02Directory, "step02_pv_parameters.m"));
run(fullfile(step03Directory, "step03_mppt_parameters.m"));
run(fullfile(stepDirectory, "step04_boost_parameters.m"));

arraySizing = calculate_pv_array_size( ...
    moduleParameters, target_power_W, target_dc_voltage_V);
boostSimulation = simulate_boost_converter( ...
    moduleParameters, arraySizing, boostParameters, mpptParameters);

run(fullfile(stepDirectory, "plot_step04_results.m"));
resultDirectory = fullfile(projectRoot, "results", "step04");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end
summaryFile = fullfile(resultDirectory, "step04_summary.csv");
writetable(boostSimulation.tracking_summary, summaryFile);

nominalDuty = 1 - boostParameters.pv_voltage_nominal_V / ...
    boostParameters.dc_link_voltage_ref_V;
fprintf("\nAveraged Boost Converter Summary\n");
fprintf("Nominal duty estimate: %.4f\n", nominalDuty);
fprintf("Temporary DC load resistance: %.4f ohm\n", ...
    boostSimulation.dc_load_resistance_ohm);
disp(boostSimulation.tracking_summary);
fprintf("Saved STEP 4 summary: %s\n", summaryFile);
fprintf("Validate all results in MATLAB before marking STEP 4 complete.\n");
