function tests = test_grid_power
%TEST_GRID_POWER Verify P/Q scaling for balanced unity-power-factor data.
tests = functiontests(localfunctions);
end

function testUnityPowerFactorPower(testCase)
lineLineRms_V = 380.0;
phaseCurrentRms_A = 100.0;
voltageD_V = sqrt(2) * lineLineRms_V / sqrt(3);
currentD_A = sqrt(2) * phaseCurrentRms_A;
[activePower_W, reactivePower_var] = calculate_three_phase_power( ...
    voltageD_V, 0.0, currentD_A, 0.0);
expectedPower_W = sqrt(3) * lineLineRms_V * phaseCurrentRms_A;
verifyEqual(testCase, activePower_W, expectedPower_W, "RelTol", 1.0e-12);
verifyEqual(testCase, reactivePower_var, 0.0, "AbsTol", 1.0e-12);
end
