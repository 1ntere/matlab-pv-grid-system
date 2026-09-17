function simulation = simulate_boost_converter(module, arraySizing, ...
    boost, mppt)
%SIMULATE_BOOST_CONVERTER Simulate a lossless averaged Boost stage.
%   States are PV input-capacitor voltage, inductor current, and DC-link
%   capacitor voltage. The DC load is a temporary fixed equivalent resistor.

arguments
    module (1,1) struct
    arraySizing (1,1) struct
    boost (1,1) struct
    mppt (1,1) struct
end

validateParameters(boost);
time_s = (0:boost.sample_time_s:boost.simulation_time_s).';
sampleCount = numel(time_s);
segmentCount = numel(boost.irradiance_levels_Wm2);
mpptUpdateSamples = round(boost.mppt_update_period_s / boost.sample_time_s);
if mpptUpdateSamples < 1 || abs(mpptUpdateSamples * boost.sample_time_s - ...
        boost.mppt_update_period_s) > 10 * eps(boost.mppt_update_period_s)
    error("STEP4:InvalidMpptPeriod", ...
        "mppt_update_period_s must be an integer multiple of sample_time_s.");
end

referenceCurves = cell(1, segmentCount);
for segmentIndex = 1:segmentCount
    referenceCurves{segmentIndex} = calculate_pv_module_iv( ...
        module, boost.irradiance_levels_Wm2(segmentIndex), ...
        boost.temperature_C, boost.iv_voltage_point_count);
end

[irradiance_Wm2, curveIndex, theoreticalVmpp_V, theoreticalPmpp_W] = ...
    buildReferenceSignals(time_s, referenceCurves, arraySizing, boost);

minimumPower_W = min(theoreticalPmpp_W(theoreticalPmpp_W > 0));
dcLoadResistance_ohm = boost.dc_link_voltage_ref_V^2 / minimumPower_W;
firstSegmentPower_W = referenceCurves{1}.Pmp_W * ...
    arraySizing.total_module_count;
initialDcVoltage_V = sqrt(firstSegmentPower_W * dcLoadResistance_ohm);
initialDuty = 1 - boost.initial_pv_voltage_V / initialDcVoltage_V;
initialDuty = min(max(initialDuty, boost.duty_min), boost.duty_max);

pvVoltage_V = zeros(sampleCount, 1);
pvCurrent_A = zeros(sampleCount, 1);
pvPower_W = zeros(sampleCount, 1);
pvReference_V = zeros(sampleCount, 1);
dutyRatio = zeros(sampleCount, 1);
inductorCurrent_A = zeros(sampleCount, 1);
dcLinkVoltage_V = zeros(sampleCount, 1);
dcOutputPower_W = zeros(sampleCount, 1);

pvVoltage_V(1) = boost.initial_pv_voltage_V;
pvReference_V(1) = boost.initial_vref_V + ...
    mppt.perturb_step_V * arraySizing.series_module_count;
dcLinkVoltage_V(1) = initialDcVoltage_V;
initialCurve = referenceCurves{curveIndex(1)};
pvCurrent_A(1) = arrayCurrentAtVoltage(initialCurve, pvVoltage_V(1), arraySizing);
inductorCurrent_A(1) = pvCurrent_A(1);
pvPower_W(1) = pvVoltage_V(1) * pvCurrent_A(1);
dutyRatio(1) = initialDuty;
dcOutputPower_W(1) = dcLinkVoltage_V(1)^2 / dcLoadResistance_ohm;

integratorState = 0.0;
previousMpptVoltage_V = pvVoltage_V(1);
previousMpptPower_W = pvPower_W(1);

for sampleIndex = 2:sampleCount
    activeCurve = referenceCurves{curveIndex(sampleIndex - 1)};
    arrayVoc_V = activeCurve.Voc_V * arraySizing.series_module_count;
    pvCurrent_A(sampleIndex - 1) = arrayCurrentAtVoltage( ...
        activeCurve, pvVoltage_V(sampleIndex - 1), arraySizing);
    pvPower_W(sampleIndex - 1) = pvVoltage_V(sampleIndex - 1) * ...
        pvCurrent_A(sampleIndex - 1);

    if sampleIndex > 2 && mod(sampleIndex - 2, mpptUpdateSamples) == 0
        dynamicVrefMax_V = 0.995 * arrayVoc_V;
        pvReference_V(sampleIndex - 1) = po_mppt_step( ...
            pvVoltage_V(sampleIndex - 1), pvCurrent_A(sampleIndex - 1), ...
            previousMpptVoltage_V, previousMpptPower_W, ...
            pvReference_V(sampleIndex - 1), ...
            mppt.perturb_step_V * arraySizing.series_module_count, ...
            mppt.mppt_power_tolerance_W * arraySizing.total_module_count, ...
            mppt.mppt_voltage_tolerance_V * arraySizing.series_module_count, ...
            boost.pv_voltage_min_V, ...
            dynamicVrefMax_V);
        previousMpptVoltage_V = pvVoltage_V(sampleIndex - 1);
        previousMpptPower_W = pvPower_W(sampleIndex - 1);
    end

    feedforwardDuty = 1 - pvVoltage_V(sampleIndex - 1) / ...
        max(dcLinkVoltage_V(sampleIndex - 1), 1.0);
    voltageError_V = pvVoltage_V(sampleIndex - 1) - ...
        pvReference_V(sampleIndex - 1);
    [dutyRatio(sampleIndex - 1), integratorState] = pv_voltage_controller( ...
        voltageError_V, feedforwardDuty, integratorState, ...
        boost.kp_pv_voltage_per_V, boost.ki_pv_voltage_per_Vs, ...
        boost.sample_time_s, boost.duty_min, boost.duty_max);

    loadCurrent_A = dcLinkVoltage_V(sampleIndex - 1) / dcLoadResistance_ohm;
    pvVoltageDerivative_Vs = (pvCurrent_A(sampleIndex - 1) - ...
        inductorCurrent_A(sampleIndex - 1)) / boost.pv_input_capacitance_F;
    inductorCurrentDerivative_As = (pvVoltage_V(sampleIndex - 1) - ...
        (1 - dutyRatio(sampleIndex - 1)) * dcLinkVoltage_V(sampleIndex - 1)) / ...
        boost.boost_inductance_H;
    dcVoltageDerivative_Vs = ((1 - dutyRatio(sampleIndex - 1)) * ...
        inductorCurrent_A(sampleIndex - 1) - loadCurrent_A) / ...
        boost.dc_link_capacitance_F;

    pvVoltage_V(sampleIndex) = min(max(pvVoltage_V(sampleIndex - 1) + ...
        boost.sample_time_s * pvVoltageDerivative_Vs, 1.0), arrayVoc_V);
    inductorCurrent_A(sampleIndex) = max(inductorCurrent_A(sampleIndex - 1) + ...
        boost.sample_time_s * inductorCurrentDerivative_As, 0.0);
    dcLinkVoltage_V(sampleIndex) = max(dcLinkVoltage_V(sampleIndex - 1) + ...
        boost.sample_time_s * dcVoltageDerivative_Vs, 1.0);

    pvReference_V(sampleIndex) = pvReference_V(sampleIndex - 1);
    dutyRatio(sampleIndex) = dutyRatio(sampleIndex - 1);
end

finalCurve = referenceCurves{curveIndex(end)};
pvCurrent_A(end) = arrayCurrentAtVoltage(finalCurve, pvVoltage_V(end), arraySizing);
pvPower_W(end) = pvVoltage_V(end) * pvCurrent_A(end);
dcOutputPower_W = dcLinkVoltage_V.^2 / dcLoadResistance_ohm;

summary = buildSummary(time_s, pvVoltage_V, pvReference_V, pvPower_W, ...
    theoreticalVmpp_V, theoreticalPmpp_W, dutyRatio, inductorCurrent_A, ...
    dcLinkVoltage_V, dcOutputPower_W, boost);

simulation = struct("time_s", time_s, "irradiance_Wm2", irradiance_Wm2, ...
    "pv_reference_V", pvReference_V, "pv_voltage_V", pvVoltage_V, ...
    "pv_current_A", pvCurrent_A, "pv_power_W", pvPower_W, ...
    "theoretical_vmpp_V", theoreticalVmpp_V, ...
    "theoretical_pmpp_W", theoreticalPmpp_W, "duty_ratio", dutyRatio, ...
    "inductor_current_A", inductorCurrent_A, ...
    "dc_link_voltage_V", dcLinkVoltage_V, ...
    "dc_output_power_W", dcOutputPower_W, ...
    "dc_load_resistance_ohm", dcLoadResistance_ohm, ...
    "tracking_summary", summary);
end

function validateParameters(boost)
if boost.sample_time_s <= 0 || boost.simulation_time_s <= 0
    error("STEP4:InvalidTime", "Simulation and sample times must be positive.");
end
if boost.duty_min < 0 || boost.duty_max >= 1 || ...
        boost.duty_min >= boost.duty_max
    error("STEP4:InvalidDutyLimits", "Duty limits must satisfy 0 <= min < max < 1.");
end
if any([boost.boost_inductance_H, boost.pv_input_capacitance_F, ...
        boost.dc_link_capacitance_F] <= 0)
    error("STEP4:InvalidPassiveComponent", "L and capacitances must be positive.");
end
if boost.steady_state_fraction <= 0 || boost.steady_state_fraction > 1
    error("STEP4:InvalidSteadyStateFraction", ...
        "steady_state_fraction must be in (0, 1].");
end
if boost.pv_voltage_min_V <= 0 || ...
        boost.pv_voltage_min_V >= boost.pv_voltage_nominal_V
    error("STEP4:InvalidPvVoltageMinimum", ...
        "pv_voltage_min_V must be positive and below the nominal PV voltage.");
end
if numel(boost.irradiance_transition_times_s) ~= ...
        numel(boost.irradiance_levels_Wm2) + 1 || ...
        boost.irradiance_transition_times_s(1) ~= 0 || ...
        any(diff(boost.irradiance_transition_times_s) <= 0) || ...
        boost.irradiance_transition_times_s(end) ~= boost.simulation_time_s
    error("STEP4:InvalidIrradianceProfile", ...
        "Irradiance transitions must span the simulation with increasing times.");
end
if any(boost.irradiance_levels_Wm2 <= 0)
    error("STEP4:InvalidIrradiance", "All irradiance levels must be positive.");
end
end

function current_A = arrayCurrentAtVoltage(curve, arrayVoltage_V, sizing)
moduleVoltage_V = min(max(arrayVoltage_V / sizing.series_module_count, 0), ...
    curve.Voc_V);
moduleCurrent_A = interp1(curve.voltage_V, curve.current_A, ...
    moduleVoltage_V, "linear", 0);
current_A = max(moduleCurrent_A, 0) * sizing.parallel_string_count;
end

function [irradiance, curveIndex, vmpp, pmpp] = buildReferenceSignals( ...
    time_s, curves, sizing, boost)
sampleCount = numel(time_s);
segmentCount = numel(boost.irradiance_levels_Wm2);
irradiance = zeros(sampleCount, 1);
curveIndex = zeros(sampleCount, 1);
vmpp = zeros(sampleCount, 1);
pmpp = zeros(sampleCount, 1);
for segmentIndex = 1:segmentCount
    start_s = boost.irradiance_transition_times_s(segmentIndex);
    end_s = boost.irradiance_transition_times_s(segmentIndex + 1);
    if segmentIndex < segmentCount
        mask = time_s >= start_s & time_s < end_s;
    else
        mask = time_s >= start_s & time_s <= end_s;
    end
    curve = curves{segmentIndex};
    irradiance(mask) = boost.irradiance_levels_Wm2(segmentIndex);
    curveIndex(mask) = segmentIndex;
    vmpp(mask) = curve.Vmp_V * sizing.series_module_count;
    pmpp(mask) = curve.Pmp_W * sizing.total_module_count;
end
end

function summary = buildSummary(time_s, pvVoltage, pvReference, pvPower, ...
    theoreticalVmpp, theoreticalPmpp, duty, inductorCurrent, dcVoltage, ...
    outputPower, boost)
segmentCount = numel(boost.irradiance_levels_Wm2);
metrics = zeros(segmentCount, 10);
for segmentIndex = 1:segmentCount
    start_s = boost.irradiance_transition_times_s(segmentIndex);
    end_s = boost.irradiance_transition_times_s(segmentIndex + 1);
    steadyStart_s = end_s - boost.steady_state_fraction * (end_s - start_s);
    if segmentIndex < segmentCount
        mask = time_s >= steadyStart_s & time_s < end_s;
    else
        mask = time_s >= steadyStart_s & time_s <= end_s;
    end
    trackedPower_W = mean(pvPower(mask));
    referencePower_W = mean(theoreticalPmpp(mask));
    metrics(segmentIndex, :) = [ ...
        mean(pvReference(mask) - pvVoltage(mask)), ...
        100 * trackedPower_W / referencePower_W, ...
        mean(dcVoltage(mask)), max(dcVoltage(mask)) - min(dcVoltage(mask)), ...
        min(duty(mask)), max(duty(mask)), min(inductorCurrent(mask)), ...
        max(inductorCurrent(mask)), mean(pvPower(mask)), mean(outputPower(mask))];
end
summary = array2table(metrics, "VariableNames", [ ...
    "pv_voltage_error_V", "tracking_efficiency_pct", ...
    "dc_link_average_V", "dc_link_variation_V", "duty_min", "duty_max", ...
    "inductor_current_min_A", "inductor_current_max_A", ...
    "input_power_average_W", "output_power_average_W"]);
summary = addvars(summary, boost.irradiance_levels_Wm2(:), ...
    "Before", 1, "NewVariableNames", "irradiance_Wm2");
end
