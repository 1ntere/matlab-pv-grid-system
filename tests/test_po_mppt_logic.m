function tests = test_po_mppt_logic
%TEST_PO_MPPT_LOGIC Unit tests for the four basic P&O direction cases.
tests = functiontests(localfunctions);
end

function testPowerUpVoltageUpIncreasesReference(testCase)
actual = runCase(31, 62, 30, 60, 30);
verifyEqual(testCase, actual, 30.5, "AbsTol", 1.0e-12);
end

function testPowerUpVoltageDownDecreasesReference(testCase)
actual = runCase(29, 61, 30, 60, 30);
verifyEqual(testCase, actual, 29.5, "AbsTol", 1.0e-12);
end

function testPowerDownVoltageUpDecreasesReference(testCase)
actual = runCase(31, 59, 30, 60, 30);
verifyEqual(testCase, actual, 29.5, "AbsTol", 1.0e-12);
end

function testPowerDownVoltageDownIncreasesReference(testCase)
actual = runCase(29, 59, 30, 60, 30);
verifyEqual(testCase, actual, 30.5, "AbsTol", 1.0e-12);
end

function nextVref_V = runCase(currentVoltage_V, currentPower_W, ...
    previousVoltage_V, previousPower_W, previousVref_V)
current_A = currentPower_W / currentVoltage_V;
nextVref_V = po_mppt_step(currentVoltage_V, current_A, ...
    previousVoltage_V, previousPower_W, previousVref_V, ...
    0.5, 0.0, 0.0, 1.0, 49.0);
end
