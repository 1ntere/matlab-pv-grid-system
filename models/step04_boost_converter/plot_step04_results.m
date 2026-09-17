%% Plot STEP 4 averaged converter results
if ~exist("boostSimulation", "var") || ~isstruct(boostSimulation)
    error("STEP4:MissingSimulation", ...
        "Missing boostSimulation. Run run_step04.m first.");
end

stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step04");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end

voltageFigure = figure("Name", "STEP 4 PV Voltage", "Color", "white");
plot(boostSimulation.time_s, boostSimulation.pv_voltage_V, ...
    "LineWidth", 1.3, "DisplayName", "Vpv");
hold on;
plot(boostSimulation.time_s, boostSimulation.pv_reference_V, "--", ...
    "LineWidth", 1.3, "DisplayName", "Vpv reference");
hold off;
title("PV Voltage Tracking through Averaged Boost Converter");
xlabel("Time (s)"); ylabel("Voltage (V)"); legend("Location", "best"); grid on;
exportgraphics(voltageFigure, fullfile(resultDirectory, ...
    "step04_pv_voltage_tracking.png"), "Resolution", 150);

powerFigure = figure("Name", "STEP 4 PV Power", "Color", "white");
plot(boostSimulation.time_s, boostSimulation.pv_power_W, ...
    "LineWidth", 1.3, "DisplayName", "Ppv");
hold on;
plot(boostSimulation.time_s, boostSimulation.theoretical_pmpp_W, "--", ...
    "LineWidth", 1.3, "DisplayName", "Theoretical Pmpp");
hold off;
title("PV Array Power Tracking");
xlabel("Time (s)"); ylabel("Power (W)"); legend("Location", "best"); grid on;
exportgraphics(powerFigure, fullfile(resultDirectory, ...
    "step04_pv_power.png"), "Resolution", 150);

dutyFigure = figure("Name", "STEP 4 Duty", "Color", "white");
plot(boostSimulation.time_s, boostSimulation.duty_ratio, "LineWidth", 1.3);
title("Boost Converter Duty Ratio");
xlabel("Time (s)"); ylabel("Duty ratio"); grid on;
exportgraphics(dutyFigure, fullfile(resultDirectory, ...
    "step04_duty_ratio.png"), "Resolution", 150);

dynamicsFigure = figure("Name", "STEP 4 Converter Dynamics", "Color", "white");
tiledlayout(2, 1);
nexttile;
plot(boostSimulation.time_s, boostSimulation.inductor_current_A, "LineWidth", 1.2);
title("Averaged Inductor Current");
xlabel("Time (s)"); ylabel("Current (A)"); grid on;
nexttile;
plot(boostSimulation.time_s, boostSimulation.dc_link_voltage_V, "LineWidth", 1.2);
title("DC-Link Voltage");
xlabel("Time (s)"); ylabel("Voltage (V)"); grid on;
exportgraphics(dynamicsFigure, fullfile(resultDirectory, ...
    "step04_converter_dynamics.png"), "Resolution", 150);
