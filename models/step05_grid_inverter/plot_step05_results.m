%% Plot STEP 5 averaged inverter and dq-control results
if ~exist("inverterSimulation", "var") || ~isstruct(inverterSimulation)
    error("STEP5:MissingSimulation", ...
        "Missing inverterSimulation. Run run_step05.m first.");
end
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step05");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end

vdcFigure = figure("Name", "STEP 5 DC-Link", "Color", "white");
plot(inverterSimulation.time_s, inverterSimulation.dc_voltage_V, ...
    "LineWidth", 1.3, "DisplayName", "Vdc"); hold on;
plot(inverterSimulation.time_s, inverterSimulation.dc_voltage_reference_V, ...
    "--", "LineWidth", 1.3, "DisplayName", "Vdc reference"); hold off;
title("DC-Link Voltage Regulation"); xlabel("Time (s)"); ylabel("Voltage (V)");
legend("Location", "best"); grid on;
exportgraphics(vdcFigure, fullfile(resultDirectory, ...
    "step05_dc_link_regulation.png"), "Resolution", 150);

currentFigure = figure("Name", "STEP 5 dq Currents", "Color", "white");
tiledlayout(2, 1);
nexttile; plot(inverterSimulation.time_s, inverterSimulation.current_d_A, ...
    "LineWidth", 1.2, "DisplayName", "Id"); hold on;
plot(inverterSimulation.time_s, inverterSimulation.current_d_reference_A, ...
    "--", "DisplayName", "Id reference"); hold off;
ylabel("d current (A)"); legend("Location", "best"); grid on;
nexttile; plot(inverterSimulation.time_s, inverterSimulation.current_q_A, ...
    "LineWidth", 1.2, "DisplayName", "Iq"); hold on;
plot(inverterSimulation.time_s, inverterSimulation.current_q_reference_A, ...
    "--", "DisplayName", "Iq reference"); hold off;
xlabel("Time (s)"); ylabel("q current (A)"); legend("Location", "best"); grid on;
exportgraphics(currentFigure, fullfile(resultDirectory, ...
    "step05_dq_current_tracking.png"), "Resolution", 150);

phaseFigure = figure("Name", "STEP 5 Phase Currents", "Color", "white");
plot(inverterSimulation.time_s, inverterSimulation.grid_current_a_A, ...
    inverterSimulation.time_s, inverterSimulation.grid_current_b_A, ...
    inverterSimulation.time_s, inverterSimulation.grid_current_c_A, "LineWidth", 1.0);
title("Grid Phase Currents"); xlabel("Time (s)"); ylabel("Current (A)");
legend("Ia", "Ib", "Ic", "Location", "best"); grid on;
exportgraphics(phaseFigure, fullfile(resultDirectory, ...
    "step05_three_phase_currents.png"), "Resolution", 150);

powerFigure = figure("Name", "STEP 5 Power", "Color", "white");
plot(inverterSimulation.time_s, inverterSimulation.active_power_W, ...
    "LineWidth", 1.2, "DisplayName", "Active power"); hold on;
plot(inverterSimulation.time_s, inverterSimulation.reactive_power_var, ...
    "LineWidth", 1.2, "DisplayName", "Reactive power"); hold off;
title("Grid Active and Reactive Power"); xlabel("Time (s)");
ylabel("Power (W / var)"); legend("Location", "best"); grid on;
exportgraphics(powerFigure, fullfile(resultDirectory, ...
    "step05_active_reactive_power.png"), "Resolution", 150);

modulationFigure = figure("Name", "STEP 5 Modulation", "Color", "white");
plot(inverterSimulation.time_s, inverterSimulation.modulation_magnitude, ...
    "LineWidth", 1.2);
title("Inverter Modulation Magnitude"); xlabel("Time (s)");
ylabel("Modulation magnitude"); grid on;
exportgraphics(modulationFigure, fullfile(resultDirectory, ...
    "step05_modulation.png"), "Resolution", 150);
