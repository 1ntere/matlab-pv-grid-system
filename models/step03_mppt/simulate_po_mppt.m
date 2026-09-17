function simulation = simulate_po_mppt(module, parameters)
%SIMULATE_PO_MPPT Simulate P&O against a voltage-following PV abstraction.
%   STEP 2 I-V curves provide current lookup and theoretical MPP values.
%   No boost converter, switching device, or duty-ratio dynamics are used.

arguments
    module (1,1) struct
    parameters (1,1) struct
end

if parameters.sample_time_s <= 0 || parameters.simulation_time_s <= 0
    error("STEP3:InvalidSimulationTime", ...
        "Simulation time and sample time must be positive.");
end
if parameters.steady_state_fraction <= 0 || ...
        parameters.steady_state_fraction > 1
    error("STEP3:InvalidSteadyStateFraction", ...
        "steady_state_fraction must be in the interval (0, 1].");
end

time_s = (0:parameters.sample_time_s:parameters.simulation_time_s).';
sampleCount = numel(time_s);
segmentCount = numel(parameters.irradiance_levels_Wm2);
if numel(parameters.irradiance_transition_times_s) ~= segmentCount + 1
    error("STEP3:InvalidIrradianceProfile", ...
        "Transition times must contain one more element than irradiance levels.");
end
if parameters.irradiance_transition_times_s(1) ~= 0 || ...
        any(diff(parameters.irradiance_transition_times_s) <= 0) || ...
        parameters.irradiance_transition_times_s(end) ~= ...
        parameters.simulation_time_s
    error("STEP3:InvalidTransitionTimes", ...
        "Transitions must increase from zero to simulation_time_s.");
end
if any(parameters.irradiance_levels_Wm2 <= 0)
    error("STEP3:InvalidIrradiance", "All irradiance levels must be positive.");
end
if parameters.plant_response_alpha <= 0 || parameters.plant_response_alpha > 1
    error("STEP3:InvalidPlantAlpha", ...
        "plant_response_alpha must be in the interval (0, 1].");
end

referenceCurves = cell(1, segmentCount);
for segmentIndex = 1:segmentCount
    referenceCurves{segmentIndex} = calculate_pv_module_iv( ...
        module, parameters.irradiance_levels_Wm2(segmentIndex), ...
        parameters.temperature_C, parameters.iv_voltage_point_count);
end

irradiance_Wm2 = zeros(sampleCount, 1);
referenceVmpp_V = zeros(sampleCount, 1);
referencePmpp_W = zeros(sampleCount, 1);
curveIndex = zeros(sampleCount, 1);
for segmentIndex = 1:segmentCount
    segmentStart_s = parameters.irradiance_transition_times_s(segmentIndex);
    segmentEnd_s = parameters.irradiance_transition_times_s(segmentIndex + 1);
    if segmentIndex < segmentCount
        segmentMask = time_s >= segmentStart_s & time_s < segmentEnd_s;
    else
        segmentMask = time_s >= segmentStart_s & time_s <= segmentEnd_s;
    end
    curve = referenceCurves{segmentIndex};
    irradiance_Wm2(segmentMask) = parameters.irradiance_levels_Wm2(segmentIndex);
    referenceVmpp_V(segmentMask) = curve.Vmp_V;
    referencePmpp_W(segmentMask) = curve.Pmp_W;
    curveIndex(segmentMask) = segmentIndex;
end

pvVoltage_V = zeros(sampleCount, 1);
pvCurrent_A = zeros(sampleCount, 1);
pvPower_W = zeros(sampleCount, 1);
referenceVoltage_V = zeros(sampleCount, 1);

pvVoltage_V(1) = parameters.initial_pv_voltage_V;
referenceVoltage_V(1) = min(max( ...
    parameters.initial_vref_V + parameters.perturb_step_V, ...
    parameters.vref_min_V), parameters.vref_max_V);
initialCurve = referenceCurves{curveIndex(1)};
pvCurrent_A(1) = interpolateCurrent(initialCurve, pvVoltage_V(1));
pvPower_W(1) = pvVoltage_V(1) * pvCurrent_A(1);

for sampleIndex = 2:sampleCount
    pvVoltage_V(sampleIndex) = pvVoltage_V(sampleIndex - 1) + ...
        parameters.plant_response_alpha * ...
        (referenceVoltage_V(sampleIndex - 1) - pvVoltage_V(sampleIndex - 1));

    activeCurve = referenceCurves{curveIndex(sampleIndex)};
    pvVoltage_V(sampleIndex) = min(max(pvVoltage_V(sampleIndex), 0), ...
        activeCurve.Voc_V);
    pvCurrent_A(sampleIndex) = interpolateCurrent( ...
        activeCurve, pvVoltage_V(sampleIndex));
    pvPower_W(sampleIndex) = pvVoltage_V(sampleIndex) * pvCurrent_A(sampleIndex);

    dynamicVrefMax_V = min(parameters.vref_max_V, 0.995 * activeCurve.Voc_V);
    referenceVoltage_V(sampleIndex) = po_mppt_step( ...
        pvVoltage_V(sampleIndex), pvCurrent_A(sampleIndex), ...
        pvVoltage_V(sampleIndex - 1), pvPower_W(sampleIndex - 1), ...
        referenceVoltage_V(sampleIndex - 1), parameters.perturb_step_V, ...
        parameters.mppt_power_tolerance_W, ...
        parameters.mppt_voltage_tolerance_V, parameters.vref_min_V, ...
        dynamicVrefMax_V);
end

summary = buildTrackingSummary(time_s, pvVoltage_V, pvPower_W, ...
    referenceCurves, parameters);

simulation = struct( ...
    "time_s", time_s, ...
    "irradiance_Wm2", irradiance_Wm2, ...
    "pv_voltage_V", pvVoltage_V, ...
    "pv_current_A", pvCurrent_A, ...
    "pv_power_W", pvPower_W, ...
    "reference_voltage_V", referenceVoltage_V, ...
    "theoretical_vmpp_V", referenceVmpp_V, ...
    "theoretical_pmpp_W", referencePmpp_W, ...
    "tracking_summary", summary);
end

function current_A = interpolateCurrent(curve, operatingVoltage_V)
boundedVoltage_V = min(max(operatingVoltage_V, 0), curve.Voc_V);
current_A = interp1(curve.voltage_V, curve.current_A, ...
    boundedVoltage_V, "linear", 0);
current_A = max(current_A, 0);
end

function summary = buildTrackingSummary(time_s, pvVoltage_V, pvPower_W, ...
    referenceCurves, parameters)
segmentCount = numel(parameters.irradiance_levels_Wm2);
trackedVoltage_V = zeros(segmentCount, 1);
trackedPower_W = zeros(segmentCount, 1);
theoreticalVoltage_V = zeros(segmentCount, 1);
theoreticalPower_W = zeros(segmentCount, 1);

for segmentIndex = 1:segmentCount
    segmentStart_s = parameters.irradiance_transition_times_s(segmentIndex);
    segmentEnd_s = parameters.irradiance_transition_times_s(segmentIndex + 1);
    steadyStateStart_s = segmentEnd_s - parameters.steady_state_fraction * ...
        (segmentEnd_s - segmentStart_s);
    if segmentIndex < segmentCount
        steadyStateMask = time_s >= steadyStateStart_s & time_s < segmentEnd_s;
    else
        steadyStateMask = time_s >= steadyStateStart_s & time_s <= segmentEnd_s;
    end
    trackedVoltage_V(segmentIndex) = mean(pvVoltage_V(steadyStateMask));
    trackedPower_W(segmentIndex) = mean(pvPower_W(steadyStateMask));
    theoreticalVoltage_V(segmentIndex) = referenceCurves{segmentIndex}.Vmp_V;
    theoreticalPower_W(segmentIndex) = referenceCurves{segmentIndex}.Pmp_W;
end

voltageError_pct = 100 * (trackedVoltage_V - theoreticalVoltage_V) ./ ...
    theoreticalVoltage_V;
powerError_pct = 100 * (trackedPower_W - theoreticalPower_W) ./ ...
    theoreticalPower_W;
trackingEfficiency_pct = 100 * trackedPower_W ./ theoreticalPower_W;

summary = table(parameters.irradiance_levels_Wm2(:), theoreticalVoltage_V, ...
    trackedVoltage_V, voltageError_pct, theoreticalPower_W, ...
    trackedPower_W, powerError_pct, trackingEfficiency_pct, ...
    "VariableNames", ["irradiance_Wm2", "theoretical_vmpp_V", ...
    "tracked_vmpp_V", "voltage_error_pct", "theoretical_pmpp_W", ...
    "tracked_pmpp_W", "power_error_pct", "tracking_efficiency_pct"]);
end
