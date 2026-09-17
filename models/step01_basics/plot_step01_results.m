%% Plot STEP 1 input and output
if ~exist("simOut", "var") || ~isa(simOut, "Simulink.SimulationOutput")
    error("STEP1:MissingSimulationOutput", ...
        "Simulation output 'simOut' is unavailable. Run run_step01.m first.");
end

inputSignal = simOut.get("input_signal");
outputSignal = simOut.get("output_signal");
if ~isa(inputSignal, "timeseries") || ~isa(outputSignal, "timeseries")
    error("STEP1:UnexpectedResultFormat", ...
        "Expected input_signal and output_signal to be timeseries objects.");
end

figureHandle = figure("Name", "STEP 1 RLC Equivalent Response", "Color", "white");
plot(inputSignal.Time, inputSignal.Data, "--", "LineWidth", 1.4);
hold on;
plot(outputSignal.Time, outputSignal.Data, "-", "LineWidth", 1.6);
hold off;
title("Series-RLC Equivalent Second-Order Step Response");
xlabel("Time (s)");
ylabel("Voltage (V)");
legend("Input voltage", "Capacitor voltage", "Location", "best");
grid on;

stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step01");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end
resultFile = fullfile(resultDirectory, "step01_rlc_step_response.png");
exportgraphics(figureHandle, resultFile, "Resolution", 150);
fprintf("Saved STEP 1 plot: %s\n", resultFile);
