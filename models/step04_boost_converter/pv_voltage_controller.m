function [duty, nextIntegrator] = pv_voltage_controller( ...
    voltageError_V, feedforwardDuty, integratorState, kp, ki, ...
    sampleTime_s, dutyMin, dutyMax)
%PV_VOLTAGE_CONTROLLER PI control with conditional-integration anti-windup.
%   voltageError_V = Vpv - Vpv_ref. A positive error raises Boost duty,
%   increasing inductor current and tending to pull the PV voltage down.

arguments
    voltageError_V (1,1) double
    feedforwardDuty (1,1) double
    integratorState (1,1) double
    kp (1,1) double {mustBeNonnegative}
    ki (1,1) double {mustBeNonnegative}
    sampleTime_s (1,1) double {mustBePositive}
    dutyMin (1,1) double {mustBeNonnegative}
    dutyMax (1,1) double {mustBeGreaterThan(dutyMax, dutyMin)}
end

candidateIntegrator = integratorState + ki * voltageError_V * sampleTime_s;
unsaturatedDuty = feedforwardDuty + kp * voltageError_V + candidateIntegrator;
duty = min(max(unsaturatedDuty, dutyMin), dutyMax);

isNotSaturated = unsaturatedDuty >= dutyMin && unsaturatedDuty <= dutyMax;
isUnwindingUpperLimit = unsaturatedDuty > dutyMax && voltageError_V < 0;
isUnwindingLowerLimit = unsaturatedDuty < dutyMin && voltageError_V > 0;
if isNotSaturated || isUnwindingUpperLimit || isUnwindingLowerLimit
    nextIntegrator = candidateIntegrator;
else
    nextIntegrator = integratorState;
end
end
