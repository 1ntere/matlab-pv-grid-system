function tests = test_integrated_system_setup
%TEST_INTEGRATED_SYSTEM_SETUP Static setup checks without full simulation.
tests = functiontests(localfunctions);
end
function testInitialConditionsAndDependencies(testCase)
projectRoot = fileparts(fileparts(mfilename("fullpath")));
step02 = fullfile(projectRoot, "models", "step02_pv_array");
step03 = fullfile(projectRoot, "models", "step03_mppt");
step04 = fullfile(projectRoot, "models", "step04_boost_converter");
step05 = fullfile(projectRoot, "models", "step05_grid_inverter");
step06 = fullfile(projectRoot, "models", "step06_integrated_system");
addpath(step02, step03, step04, step05, step06);
run(fullfile(step02, "step02_pv_parameters.m"));
run(fullfile(step03, "step03_mppt_parameters.m"));
run(fullfile(step04, "step04_boost_parameters.m"));
run(fullfile(step05, "step05_inverter_parameters.m"));
run(fullfile(step06, "step06_system_parameters.m"));
arraySizing = calculate_pv_array_size(moduleParameters, target_power_W, target_dc_voltage_V);
curve = calculate_pv_module_iv(moduleParameters, 600, 25, 500);
initial = calculate_integrated_initial_conditions(moduleParameters, arraySizing, ...
    curve, boostParameters, inverterParameters, mpptParameters);

verifyTrue(testCase, all(isfinite(cell2mat(struct2cell(initial)))));
verifyGreaterThan(testCase, initial.dc_link_voltage_V, initial.pv_voltage_V);
verifyGreaterThanOrEqual(testCase, initial.duty_ratio, boostParameters.duty_min);
verifyLessThanOrEqual(testCase, initial.duty_ratio, boostParameters.duty_max);
verifyEqual(testCase, inverterParameters.grid_voltage_ll_rms_V, 380.0);
verifyNotEmpty(testCase, which("po_mppt_step"));
verifyNotEmpty(testCase, which("dq_current_controller"));
end
