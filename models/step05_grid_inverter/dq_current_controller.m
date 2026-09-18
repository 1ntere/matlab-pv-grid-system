function [voltageDCommand_V, voltageQCommand_V, nextIntegratorD_V, ...
    nextIntegratorQ_V, modulationMagnitude, isSaturated] = ...
    dq_current_controller(currentD_A, currentQ_A, referenceD_A, ...
    referenceQ_A, gridVoltageD_V, gridVoltageQ_V, dcVoltage_V, ...
    integratorD_V, integratorQ_V, kp_V_per_A, ki_V_per_As, ...
    sampleTime_s, angularFrequency_rad_s, filterInductance_H, ...
    filterResistance_ohm, modulationIndexMaximum)
%DQ_CURRENT_CONTROLLER PI current control with grid/cross-coupling feedforward.
%   Voltage-vector saturation uses m*Vdc/sqrt(3), consistent with an
%   averaged two-level VSI under space-vector modulation assumptions.

errorD_A = referenceD_A - currentD_A;
errorQ_A = referenceQ_A - currentQ_A;
candidateIntegratorD_V = integratorD_V + ki_V_per_As * errorD_A * sampleTime_s;
candidateIntegratorQ_V = integratorQ_V + ki_V_per_As * errorQ_A * sampleTime_s;

unsaturatedD_V = gridVoltageD_V + filterResistance_ohm * currentD_A - ...
    angularFrequency_rad_s * filterInductance_H * currentQ_A + ...
    kp_V_per_A * errorD_A + candidateIntegratorD_V;
unsaturatedQ_V = gridVoltageQ_V + filterResistance_ohm * currentQ_A + ...
    angularFrequency_rad_s * filterInductance_H * currentD_A + ...
    kp_V_per_A * errorQ_A + candidateIntegratorQ_V;

availableVoltage_V = modulationIndexMaximum * dcVoltage_V / sqrt(3);
unsaturatedMagnitude_V = hypot(unsaturatedD_V, unsaturatedQ_V);
if unsaturatedMagnitude_V > availableVoltage_V
    scale = availableVoltage_V / max(unsaturatedMagnitude_V, eps);
    voltageDCommand_V = unsaturatedD_V * scale;
    voltageQCommand_V = unsaturatedQ_V * scale;
    isSaturated = true;
else
    voltageDCommand_V = unsaturatedD_V;
    voltageQCommand_V = unsaturatedQ_V;
    isSaturated = false;
end
modulationMagnitude = hypot(voltageDCommand_V, voltageQCommand_V) / ...
    max(dcVoltage_V / sqrt(3), eps);

errorDotVoltageCommand = errorD_A * unsaturatedD_V + errorQ_A * unsaturatedQ_V;
if ~isSaturated || errorDotVoltageCommand < 0
    nextIntegratorD_V = candidateIntegratorD_V;
    nextIntegratorQ_V = candidateIntegratorQ_V;
else
    nextIntegratorD_V = integratorD_V;
    nextIntegratorQ_V = integratorQ_V;
end
end
