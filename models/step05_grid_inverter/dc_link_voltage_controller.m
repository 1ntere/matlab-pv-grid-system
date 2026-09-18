function [idReference_A, nextIntegrator] = dc_link_voltage_controller( ...
    dcVoltage_V, dcVoltageReference_V, dcInputPower_W, gridVoltageD_V, ...
    integratorState_A, kp_A_per_V, ki_A_per_Vs, sampleTime_s, ...
    idMinimum_A, idMaximum_A)
%DC_LINK_VOLTAGE_CONTROLLER Outer-loop PI with active-power feedforward.
%   Error is Vdc-Vdc_ref: a high DC voltage requests more positive d-axis
%   current and therefore more active power export to the grid.

arguments
    dcVoltage_V (1,1) double {mustBePositive}
    dcVoltageReference_V (1,1) double {mustBePositive}
    dcInputPower_W (1,1) double {mustBeNonnegative}
    gridVoltageD_V (1,1) double {mustBePositive}
    integratorState_A (1,1) double
    kp_A_per_V (1,1) double {mustBeNonnegative}
    ki_A_per_Vs (1,1) double {mustBeNonnegative}
    sampleTime_s (1,1) double {mustBePositive}
    idMinimum_A (1,1) double {mustBeNonnegative}
    idMaximum_A (1,1) double {mustBeGreaterThan(idMaximum_A, idMinimum_A)}
end

voltageError_V = dcVoltage_V - dcVoltageReference_V;
feedforwardCurrent_A = dcInputPower_W / (1.5 * gridVoltageD_V);
candidateIntegrator_A = integratorState_A + ...
    ki_A_per_Vs * voltageError_V * sampleTime_s;
unsaturatedReference_A = feedforwardCurrent_A + ...
    kp_A_per_V * voltageError_V + candidateIntegrator_A;
idReference_A = min(max(unsaturatedReference_A, idMinimum_A), idMaximum_A);

isNotSaturated = unsaturatedReference_A >= idMinimum_A && ...
    unsaturatedReference_A <= idMaximum_A;
isUnwindingUpper = unsaturatedReference_A > idMaximum_A && voltageError_V < 0;
isUnwindingLower = unsaturatedReference_A < idMinimum_A && voltageError_V > 0;
if isNotSaturated || isUnwindingUpper || isUnwindingLower
    nextIntegrator = candidateIntegrator_A;
else
    nextIntegrator = integratorState_A;
end
end
