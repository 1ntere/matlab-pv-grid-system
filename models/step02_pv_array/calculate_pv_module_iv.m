function characteristic = calculate_pv_module_iv(module, irradiance_Wm2, temperature_C, pointCount)
%CALCULATE_PV_MODULE_IV Calculate a simplified single-diode PV curve.
%   The implicit current equation includes diode, series-resistance, and
%   shunt-resistance terms. Monotonic bisection solves the current at each
%   voltage sample without requiring an Optimization Toolbox.

arguments
    module (1,1) struct
    irradiance_Wm2 (1,1) double {mustBePositive}
    temperature_C (1,1) double {mustBeGreaterThan(temperature_C, -273.15)}
    pointCount (1,1) double {mustBeInteger, mustBeGreaterThan(pointCount, 2)} = 500
end

requiredFields = ["Voc_ref_V", "Isc_ref_A", "Vmp_ref_V", "Imp_ref_A", ...
    "Pmp_ref_W", "temperature_coefficient_Voc_per_C", ...
    "temperature_coefficient_Isc_per_C", "T_ref_C", "G_ref_Wm2", ...
    "series_cell_count", "diode_ideality_factor", ...
    "series_resistance_ohm", "shunt_resistance_ohm"];
if ~all(isfield(module, requiredFields))
    error("STEP2:MissingModuleParameter", ...
        "The module parameter structure is missing one or more required fields.");
end

elementaryCharge_C = 1.602176634e-19;
BoltzmannConstant_JK = 1.380649e-23;
absoluteTemperature_K = temperature_C + 273.15;
temperatureDifference_C = temperature_C - module.T_ref_C;
irradianceRatio = irradiance_Wm2 / module.G_ref_Wm2;

thermalVoltage_V = module.diode_ideality_factor * module.series_cell_count * ...
    BoltzmannConstant_JK * absoluteTemperature_K / elementaryCharge_C;

shortCircuitCurrent_A = module.Isc_ref_A * irradianceRatio * ...
    (1 + module.temperature_coefficient_Isc_per_C * temperatureDifference_C);
openCircuitVoltage_V = module.Voc_ref_V * ...
    (1 + module.temperature_coefficient_Voc_per_C * temperatureDifference_C) + ...
    thermalVoltage_V * log(irradianceRatio);
openCircuitVoltage_V = max(openCircuitVoltage_V, eps);

photoCurrent_A = shortCircuitCurrent_A * ...
    (1 + module.series_resistance_ohm / module.shunt_resistance_ohm);
diodeSaturationCurrent_A = ...
    (photoCurrent_A - openCircuitVoltage_V / module.shunt_resistance_ohm) / ...
    expm1(openCircuitVoltage_V / thermalVoltage_V);
diodeSaturationCurrent_A = max(diodeSaturationCurrent_A, realmin);

voltage_V = linspace(0, openCircuitVoltage_V, pointCount);
current_A = zeros(size(voltage_V));
maximumIterations = 80;
currentTolerance_A = 1.0e-10;

for voltageIndex = 1:pointCount
    terminalVoltage_V = voltage_V(voltageIndex);
    lowerCurrent_A = 0.0;
    upperCurrent_A = photoCurrent_A;
    for iterationIndex = 1:maximumIterations
        currentGuess_A = 0.5 * (lowerCurrent_A + upperCurrent_A);
        diodeArgument = (terminalVoltage_V + ...
            currentGuess_A * module.series_resistance_ohm) / thermalVoltage_V;
        diodeArgument = min(diodeArgument, 700.0);
        diodeExponential = exp(diodeArgument);

        residual_A = currentGuess_A - photoCurrent_A + ...
            diodeSaturationCurrent_A * (diodeExponential - 1) + ...
            (terminalVoltage_V + currentGuess_A * module.series_resistance_ohm) / ...
            module.shunt_resistance_ohm;
        if residual_A > 0
            upperCurrent_A = currentGuess_A;
        else
            lowerCurrent_A = currentGuess_A;
        end
        if (upperCurrent_A - lowerCurrent_A) <= currentTolerance_A
            break;
        end
    end
    current_A(voltageIndex) = 0.5 * (lowerCurrent_A + upperCurrent_A);
end

power_W = voltage_V .* current_A;
[maximumPower_W, maximumPowerIndex] = max(power_W);

characteristic = struct( ...
    "irradiance_Wm2", irradiance_Wm2, ...
    "temperature_C", temperature_C, ...
    "voltage_V", voltage_V, ...
    "current_A", current_A, ...
    "power_W", power_W, ...
    "Voc_V", openCircuitVoltage_V, ...
    "Isc_A", current_A(1), ...
    "Vmp_V", voltage_V(maximumPowerIndex), ...
    "Imp_A", current_A(maximumPowerIndex), ...
    "Pmp_W", maximumPower_W);
end
