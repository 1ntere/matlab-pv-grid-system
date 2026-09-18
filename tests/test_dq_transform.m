function tests = test_dq_transform
%TEST_DQ_TRANSFORM Verify the documented amplitude-invariant convention.
tests = functiontests(localfunctions);
end

function testBalancedSignalAlignsWithDaxis(testCase)
theta = linspace(0, 2*pi, 1001).';
amplitude = 325.0;
a = amplitude * cos(theta);
b = amplitude * cos(theta - 2*pi/3);
c = amplitude * cos(theta + 2*pi/3);
[d, q, zero] = abc_to_dq(a, b, c, theta);
verifyLessThan(testCase, max(abs(d - amplitude)), 1.0e-10);
verifyLessThan(testCase, max(abs(q)), 1.0e-10);
verifyLessThan(testCase, max(abs(zero)), 1.0e-10);
end

function testRoundTrip(testCase)
theta = linspace(0, 4*pi, 997).';
a = 100*cos(theta) + 3;
b = 80*cos(theta - 2*pi/3) - 2;
c = 90*cos(theta + 2*pi/3) + 1;
[d, q, zero] = abc_to_dq(a, b, c, theta);
[aRecovered, bRecovered, cRecovered] = dq_to_abc(d, q, zero, theta);
error = max(abs([aRecovered-a; bRecovered-b; cRecovered-c]));
verifyLessThan(testCase, error, 1.0e-10);
end
