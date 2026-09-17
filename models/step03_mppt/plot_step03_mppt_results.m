%% Plot STEP 3 irradiance and MPPT tracking results
if ~exist("mpptSimulation", "var") || ~isstruct(mpptSimulation)
    error("STEP3:MissingSimulation", ...
        "Missing mpptSimulation. Run run_step03.m first.");
end

stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step03");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end

irradianceFigure = figure("Name", "STEP 3 Irradiance", "Color", "white");
stairs(mpptSimulation.time_s, mpptSimulation.irradiance_Wm2, "LineWidth", 1.5);
title("MPPT Irradiance Profile");
xlabel("Time (s)");
ylabel("Irradiance (W/m^2)");
grid on;
exportgraphics(irradianceFigure, fullfile(resultDirectory, ...
    "step03_irradiance_profile.png"), "Resolution", 150);

voltageFigure = figure("Name", "STEP 3 Voltage Tracking", "Color", "white");
plot(mpptSimulation.time_s, mpptSimulation.pv_voltage_V, ...
    "LineWidth", 1.4, "DisplayName", "Vpv");
hold on;
plot(mpptSimulation.time_s, mpptSimulation.reference_voltage_V, "--", ...
    "LineWidth", 1.2, "DisplayName", "Vref");
plot(mpptSimulation.time_s, mpptSimulation.theoretical_vmpp_V, ":", ...
    "LineWidth", 1.6, "DisplayName", "Theoretical Vmpp");
hold off;
title("P&O PV Voltage Tracking");
xlabel("Time (s)");
ylabel("Module voltage (V)");
legend("Location", "best");
grid on;
exportgraphics(voltageFigure, fullfile(resultDirectory, ...
    "step03_voltage_tracking.png"), "Resolution", 150);

powerFigure = figure("Name", "STEP 3 Power Tracking", "Color", "white");
plot(mpptSimulation.time_s, mpptSimulation.pv_power_W, ...
    "LineWidth", 1.4, "DisplayName", "Tracked Ppv");
hold on;
plot(mpptSimulation.time_s, mpptSimulation.theoretical_pmpp_W, "--", ...
    "LineWidth", 1.5, "DisplayName", "Theoretical Pmpp");
hold off;
title("P&O PV Power Tracking");
xlabel("Time (s)");
ylabel("Module power (W)");
legend("Location", "best");
grid on;
exportgraphics(powerFigure, fullfile(resultDirectory, ...
    "step03_power_tracking.png"), "Resolution", 150);

errorFigure = figure("Name", "STEP 3 Tracking Error", "Color", "white");
bar(categorical(string(mpptSimulation.tracking_summary.irradiance_Wm2)), ...
    abs(mpptSimulation.tracking_summary.power_error_pct));
title("Steady-State MPPT Power Error");
xlabel("Irradiance (W/m^2)");
ylabel("Absolute power error (%)");
grid on;
exportgraphics(errorFigure, fullfile(resultDirectory, ...
    "step03_tracking_error.png"), "Resolution", 150);
