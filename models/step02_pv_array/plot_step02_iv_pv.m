%% Plot STEP 2 I-V, P-V, and temperature comparisons
requiredVariables = ["irradianceCurves", "temperatureCurves"];
for variableIndex = 1:numel(requiredVariables)
    if ~exist(char(requiredVariables(variableIndex)), "var")
        error("STEP2:MissingPlotData", ...
            "Missing '%s'. Run run_step02.m first.", requiredVariables(variableIndex));
    end
end

stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step02");
if ~isfolder(resultDirectory)
    mkdir(resultDirectory);
end

ivFigure = figure("Name", "STEP 2 I-V Curves", "Color", "white");
hold on;
for curveIndex = 1:numel(irradianceCurves)
    curve = irradianceCurves{curveIndex};
    plot(curve.voltage_V, curve.current_A, "LineWidth", 1.5, ...
        "DisplayName", sprintf("%.0f W/m^2", curve.irradiance_Wm2));
end
hold off;
title("PV Module I-V Curves at 25 degC");
xlabel("Module voltage (V)");
ylabel("Module current (A)");
legend("Location", "southwest");
grid on;
exportgraphics(ivFigure, fullfile(resultDirectory, ...
    "step02_iv_curves.png"), "Resolution", 150);

pvFigure = figure("Name", "STEP 2 P-V Curves", "Color", "white");
hold on;
for curveIndex = 1:numel(irradianceCurves)
    curve = irradianceCurves{curveIndex};
    plot(curve.voltage_V, curve.power_W, "LineWidth", 1.5, ...
        "DisplayName", sprintf("%.0f W/m^2", curve.irradiance_Wm2));
    plot(curve.Vmp_V, curve.Pmp_W, "o", "HandleVisibility", "off");
end
hold off;
title("PV Module P-V Curves at 25 degC");
xlabel("Module voltage (V)");
ylabel("Module power (W)");
legend("Location", "northwest");
grid on;
exportgraphics(pvFigure, fullfile(resultDirectory, ...
    "step02_pv_curves.png"), "Resolution", 150);

temperatureFigure = figure("Name", "STEP 2 Temperature Effect", "Color", "white");
tiledlayout(1, 2);
nexttile;
hold on;
for curveIndex = 1:numel(temperatureCurves)
    curve = temperatureCurves{curveIndex};
    plot(curve.voltage_V, curve.current_A, "LineWidth", 1.5, ...
        "DisplayName", sprintf("%.0f degC", curve.temperature_C));
end
hold off;
title("I-V Temperature Effect");
xlabel("Module voltage (V)");
ylabel("Module current (A)");
legend("Location", "southwest");
grid on;

nexttile;
hold on;
for curveIndex = 1:numel(temperatureCurves)
    curve = temperatureCurves{curveIndex};
    plot(curve.voltage_V, curve.power_W, "LineWidth", 1.5, ...
        "DisplayName", sprintf("%.0f degC", curve.temperature_C));
    plot(curve.Vmp_V, curve.Pmp_W, "o", "HandleVisibility", "off");
end
hold off;
title("P-V Temperature Effect");
xlabel("Module voltage (V)");
ylabel("Module power (W)");
legend("Location", "northwest");
grid on;
exportgraphics(temperatureFigure, fullfile(resultDirectory, ...
    "step02_temperature_effect.png"), "Resolution", 150);

fprintf("Saved STEP 2 figures in: %s\n", resultDirectory);
