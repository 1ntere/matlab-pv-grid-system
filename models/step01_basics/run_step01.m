%% Run STEP 1 from parameters through plotting
stepDirectory = fileparts(mfilename("fullpath"));
run(fullfile(stepDirectory, "step01_parameters.m"));
run(fullfile(stepDirectory, "build_step01_model.m"));

simulationInput = Simulink.SimulationInput(modelName);
simulationInput = simulationInput.setVariable("step_time_s", step_time_s);
simulationInput = simulationInput.setVariable("step_initial_value_V", step_initial_value_V);
simulationInput = simulationInput.setVariable("step_amplitude_V", step_amplitude_V);
simulationInput = simulationInput.setVariable("simulation_stop_time_s", simulation_stop_time_s);
simulationInput = simulationInput.setVariable("max_step_size_s", max_step_size_s);
simulationInput = simulationInput.setVariable("R_ohm", R_ohm);
simulationInput = simulationInput.setVariable("L_H", L_H);
simulationInput = simulationInput.setVariable("C_F", C_F);

simOut = sim(simulationInput);
run(fullfile(stepDirectory, "plot_step01_results.m"));
fprintf("STEP 1 simulation finished. Inspect the model, Scope, and saved plot.\n");
