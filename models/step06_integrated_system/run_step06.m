%% Run STEP 6 integrated approximately 1 MW grid-connected PV simulation
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
step02 = fullfile(projectRoot, "models", "step02_pv_array");
step03 = fullfile(projectRoot, "models", "step03_mppt");
step04 = fullfile(projectRoot, "models", "step04_boost_converter");
step05 = fullfile(projectRoot, "models", "step05_grid_inverter");
addpath(step02, step03, step04, step05, stepDirectory);

run(fullfile(step02, "step02_pv_parameters.m"));
run(fullfile(step03, "step03_mppt_parameters.m"));
run(fullfile(step04, "step04_boost_parameters.m"));
run(fullfile(step05, "step05_inverter_parameters.m"));
run(fullfile(stepDirectory, "step06_system_parameters.m"));

arraySizing = calculate_pv_array_size(moduleParameters, target_power_W, target_dc_voltage_V);
firstCurve = calculate_pv_module_iv(moduleParameters, ...
    systemParameters.irradiance_levels_Wm2(1), systemParameters.temperature_C, ...
    systemParameters.iv_voltage_point_count);
initialConditions = calculate_integrated_initial_conditions(moduleParameters, ...
    arraySizing, firstCurve, boostParameters, inverterParameters, mpptParameters);

integratedSimulation = simulate_integrated_pv_grid_system(moduleParameters, ...
    arraySizing, mpptParameters, boostParameters, inverterParameters, ...
    systemParameters, initialConditions);
run(fullfile(stepDirectory, "plot_step06_results.m"));

resultDirectory = fullfile(projectRoot, "results", "step06");
if ~isfolder(resultDirectory); mkdir(resultDirectory); end
summaryFile = fullfile(resultDirectory, "step06_system_summary.csv");
writetable(integratedSimulation.summary, summaryFile);

fprintf("\nIntegrated Approximately 1 MW PV-Grid System Summary\n");
fprintf("Array: Ns=%d, Np=%d, modules=%d, nominal=%.3f MW\n", ...
    arraySizing.series_module_count, arraySizing.parallel_string_count, ...
    arraySizing.total_module_count, arraySizing.nominal_array_power_W/1e6);
disp(integratedSimulation.summary);
fprintf("Saved STEP 6 summary: %s\n", summaryFile);
fprintf("Runtime validation remains pending until executed and reviewed in MATLAB.\n");
