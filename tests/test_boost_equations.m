function tests = test_boost_equations
%TEST_BOOST_EQUATIONS Minimal averaged Boost and controller checks.
tests = functiontests(localfunctions);
end

function testIdealOutputIncreasesWithDuty(testCase)
inputVoltage_V = 1000;
lowDutyOutput_V = inputVoltage_V / (1 - 0.20);
highDutyOutput_V = inputVoltage_V / (1 - 0.40);
verifyGreaterThan(testCase, highDutyOutput_V, lowDutyOutput_V);
end

function testZeroDutyIdealGain(testCase)
inputVoltage_V = 1000;
verifyEqual(testCase, inputVoltage_V / (1 - 0), inputVoltage_V);
end

function testControllerUpperSaturation(testCase)
[duty, nextIntegrator] = pv_voltage_controller( ...
    1000, 0.3, 0.0, 0.01, 1.0, 1.0e-3, 0.05, 0.90);
verifyEqual(testCase, duty, 0.90);
verifyEqual(testCase, nextIntegrator, 0.0);
end
function testControllerLowerSaturation(testCase)
[duty, nextIntegrator] = pv_voltage_controller( ...
    -1000, 0.3, 0.0, 0.01, 1.0, 1.0e-3, 0.05, 0.90);
verifyEqual(testCase, duty, 0.05);
verifyEqual(testCase, nextIntegrator, 0.0);
end
