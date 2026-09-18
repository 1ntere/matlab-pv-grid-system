function validate_integrated_states(sampleIndex, pvVoltage_V, boostCurrent_A, ...
    dcVoltage_V, gridCurrentD_A, gridCurrentQ_A, limits)
%VALIDATE_INTEGRATED_STATES Stop on non-finite or runaway integrated states.

states = [pvVoltage_V, boostCurrent_A, dcVoltage_V, ...
    gridCurrentD_A, gridCurrentQ_A];
if any(~isfinite(states))
    error("STEP6:NonFiniteState", ...
        "Non-finite state detected at sample %d.", sampleIndex);
end
if boostCurrent_A > limits.maximum_boost_current_A || ...
        hypot(gridCurrentD_A, gridCurrentQ_A) > limits.maximum_grid_current_A
    error("STEP6:CurrentRunaway", ...
        "Current safety bound exceeded at sample %d.", sampleIndex);
end
if dcVoltage_V > limits.maximum_dc_voltage_V
    error("STEP6:DcVoltageRunaway", ...
        "DC-link voltage safety bound exceeded at sample %d.", sampleIndex);
end
end
