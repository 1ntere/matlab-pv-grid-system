%% STEP 1 parameters: series-RLC equivalent second-order system
% Vc(s)/Vin(s) = 1 / (L*C*s^2 + R*C*s + 1)

%% Input and simulation settings
step_time_s = 0.01;
step_initial_value_V = 0.0;
step_amplitude_V = 1.0;
simulation_stop_time_s = 0.10;
max_step_size_s = 1.0e-4;

%% Series-RLC equivalent parameters
R_ohm = 10.0;
L_H = 0.10;
C_F = 100.0e-6;

%% Derived characteristics used for interpretation
natural_frequency_rad_s = 1.0 / sqrt(L_H * C_F);
damping_ratio = (R_ohm / 2.0) * sqrt(C_F / L_H);
dc_gain = 1.0;

fprintf("STEP 1 parameters loaded.\n");
fprintf("Natural frequency: %.3f rad/s\n", natural_frequency_rad_s);
fprintf("Damping ratio: %.3f\n", damping_ratio);
