%% Build the STEP 1 Simulink model
% Run step01_parameters.m first. Only standard Simulink blocks are used.

requiredVariables = ["step_time_s"; "step_initial_value_V"; ...
    "step_amplitude_V"; "simulation_stop_time_s"; ...
    "max_step_size_s"; "R_ohm"; "L_H"; "C_F"];

for variableIndex = 1:numel(requiredVariables)
    if ~exist(requiredVariables(variableIndex), "var")
        error("STEP1:MissingParameter", ...
            "Missing parameter '%s'. Run step01_parameters.m first.", ...
            requiredVariables(variableIndex));
    end
end

modelName = "step01_basic_system";
scriptDirectory = fileparts(mfilename("fullpath"));
modelFile = fullfile(scriptDirectory, modelName + ".slx");

if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if isfile(modelFile)
    delete(modelFile);
end

new_system(modelName);
set_param(modelName, "SolverType", "Variable-step", "Solver", "ode45", ...
    "StopTime", "simulation_stop_time_s", "MaxStep", "max_step_size_s", ...
    "ReturnWorkspaceOutputs", "on");

add_block("simulink/Sources/Step", modelName + "/Voltage Step", ...
    "Time", "step_time_s", "Before", "step_initial_value_V", ...
    "After", "step_amplitude_V", "Position", [60 90 120 120]);
add_block("simulink/Continuous/Transfer Fcn", modelName + "/RLC Dynamics", ...
    "Numerator", "[1]", "Denominator", "[L_H*C_F R_ohm*C_F 1]", ...
    "Position", [210 82 350 128]);
add_block("simulink/Signal Routing/Mux", modelName + "/Input-Output Mux", ...
    "Inputs", "2", "Position", [430 62 435 148]);
add_block("simulink/Sinks/Scope", modelName + "/Input and Output Scope", ...
    "Position", [515 85 565 125]);
add_block("simulink/Sinks/To Workspace", modelName + "/Input To Workspace", ...
    "VariableName", "input_signal", "SaveFormat", "Timeseries", ...
    "Position", [210 175 350 205]);
add_block("simulink/Sinks/To Workspace", modelName + "/Output To Workspace", ...
    "VariableName", "output_signal", "SaveFormat", "Timeseries", ...
    "Position", [430 175 570 205]);

add_line(modelName, "Voltage Step/1", "RLC Dynamics/1", "autorouting", "on");
add_line(modelName, "Voltage Step/1", "Input To Workspace/1", "autorouting", "on");
add_line(modelName, "Voltage Step/1", "Input-Output Mux/1", "autorouting", "on");
add_line(modelName, "RLC Dynamics/1", "Input-Output Mux/2", "autorouting", "on");
add_line(modelName, "RLC Dynamics/1", "Output To Workspace/1", "autorouting", "on");
add_line(modelName, "Input-Output Mux/1", "Input and Output Scope/1", "autorouting", "on");

save_system(modelName, modelFile);
fprintf("Created Simulink model: %s\n", modelFile);
open_system(modelName);
