%% Plot STEP 6 integrated-system signals
if ~exist("integratedSimulation", "var") || ~isstruct(integratedSimulation)
    error("STEP6:MissingSimulation", ...
        "Missing integratedSimulation. Run run_step06.m first.");
end
stepDirectory = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(stepDirectory));
resultDirectory = fullfile(projectRoot, "results", "step06");
if ~isfolder(resultDirectory); mkdir(resultDirectory); end
t = integratedSimulation.time_s;

f = figure("Color", "white"); stairs(t, integratedSimulation.irradiance_Wm2, "LineWidth", 1.3);
title("Integrated-System Irradiance Profile"); xlabel("Time (s)"); ylabel("W/m^2"); grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_irradiance_profile.png"), "Resolution", 150);

f = figure("Color", "white");
plot(t, integratedSimulation.pv_voltage_V, "DisplayName", "Vpv"); hold on;
plot(t, integratedSimulation.pv_reference_V, "--", "DisplayName", "Vpv ref");
plot(t, integratedSimulation.theoretical_vmpp_V, ":", "DisplayName", "Theoretical Vmpp"); hold off;
title("Integrated PV Voltage / MPPT"); xlabel("Time (s)"); ylabel("Voltage (V)"); legend; grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_pv_voltage_tracking.png"), "Resolution", 150);

f = figure("Color", "white");
plot(t, integratedSimulation.pv_power_W, "DisplayName", "Ppv"); hold on;
plot(t, integratedSimulation.theoretical_pmpp_W, "--", "DisplayName", "Theoretical Pmpp"); hold off;
title("Integrated PV Power Tracking"); xlabel("Time (s)"); ylabel("Power (W)"); legend; grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_pv_power_tracking.png"), "Resolution", 150);

f = figure("Color", "white"); tiledlayout(2,1);
nexttile; plot(t, integratedSimulation.duty_ratio); ylabel("Duty"); grid on;
nexttile; plot(t, integratedSimulation.boost_inductor_current_A); ylabel("iL (A)"); xlabel("Time (s)"); grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_boost_dynamics.png"), "Resolution", 150);

f = figure("Color", "white");
plot(t, integratedSimulation.dc_link_voltage_V, "DisplayName", "Vdc"); hold on;
plot(t, integratedSimulation.dc_link_reference_V, "--", "DisplayName", "Vdc ref"); hold off;
title("Integrated DC-Link Regulation"); xlabel("Time (s)"); ylabel("Voltage (V)"); legend; grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_dc_link_regulation.png"), "Resolution", 150);

f = figure("Color", "white"); tiledlayout(2,1);
nexttile; plot(t, integratedSimulation.grid_current_d_A, t, integratedSimulation.grid_current_d_reference_A); ylabel("Id (A)"); legend("Id","Id ref"); grid on;
nexttile; plot(t, integratedSimulation.grid_current_q_A, t, integratedSimulation.grid_current_q_reference_A); ylabel("Iq (A)"); xlabel("Time (s)"); legend("Iq","Iq ref"); grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_dq_current_tracking.png"), "Resolution", 150);

f = figure("Color", "white");
plot(t, integratedSimulation.grid_active_power_W, "DisplayName", "Pgrid"); hold on;
plot(t, integratedSimulation.grid_reactive_power_var, "DisplayName", "Qgrid"); hold off;
title("Integrated Grid Power"); xlabel("Time (s)"); ylabel("W / var"); legend; grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_grid_power.png"), "Resolution", 150);

f = figure("Color", "white");
plot(t, integratedSimulation.grid_current_a_A, t, integratedSimulation.grid_current_b_A, ...
    t, integratedSimulation.grid_current_c_A);
title("Integrated Three-Phase Grid Currents"); xlabel("Time (s)"); ylabel("Current (A)");
legend("Ia","Ib","Ic"); grid on;
exportgraphics(f, fullfile(resultDirectory, "step06_grid_currents.png"), "Resolution", 150);
