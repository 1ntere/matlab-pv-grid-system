%% Run STEP 2 PV module characterization and array sizing
stepDirectory = fileparts(mfilename("fullpath"));
addpath(stepDirectory);
run(fullfile(stepDirectory, "step02_pv_parameters.m"));

irradianceCurveCount = numel(irradiance_conditions_Wm2);
irradianceCurves = cell(1, irradianceCurveCount);
for conditionIndex = 1:irradianceCurveCount
    irradianceCurves{conditionIndex} = calculate_pv_module_iv( ...
        moduleParameters, irradiance_conditions_Wm2(conditionIndex), ...
        moduleParameters.T_ref_C, iv_voltage_point_count);
end

temperatureCurveCount = numel(temperature_conditions_C);
temperatureCurves = cell(1, temperatureCurveCount);
for conditionIndex = 1:temperatureCurveCount
    temperatureCurves{conditionIndex} = calculate_pv_module_iv( ...
        moduleParameters, moduleParameters.G_ref_Wm2, ...
        temperature_conditions_C(conditionIndex), iv_voltage_point_count);
end

arraySizing = calculate_pv_array_size( ...
    moduleParameters, target_power_W, target_dc_voltage_V);

fprintf("\nPV Module Summary (placeholder engineering parameters)\n");
fprintf("Voc = %.2f V, Isc = %.2f A\n", ...
    moduleParameters.Voc_ref_V, moduleParameters.Isc_ref_A);
fprintf("Vmp = %.2f V, Imp = %.2f A, Pmp = %.2f W\n", ...
    moduleParameters.Vmp_ref_V, moduleParameters.Imp_ref_A, ...
    moduleParameters.Pmp_ref_W);

fprintf("\nArray Sizing Summary\n");
fprintf("Series modules (Ns): %d\n", arraySizing.series_module_count);
fprintf("Parallel strings (Np): %d\n", arraySizing.parallel_string_count);
fprintf("Total modules: %d\n", arraySizing.total_module_count);
fprintf("Nominal Vmp: %.2f V\n", arraySizing.nominal_array_Vmp_V);
fprintf("Nominal Imp: %.2f A\n", arraySizing.nominal_array_Imp_A);
fprintf("Nominal power: %.2f W\n", arraySizing.nominal_array_power_W);
fprintf("Power sizing error: %.3f %%\n", ...
    arraySizing.power_sizing_error_percent);

fprintf("\nMPP Summary at %.1f degC\n", moduleParameters.T_ref_C);
fprintf("G [W/m^2]    Vmp [V]    Imp [A]    Pmp [W]\n");
for conditionIndex = 1:irradianceCurveCount
    curve = irradianceCurves{conditionIndex};
    fprintf("%8.0f    %7.2f    %7.2f    %8.2f\n", ...
        curve.irradiance_Wm2, curve.Vmp_V, curve.Imp_A, curve.Pmp_W);
end

run(fullfile(stepDirectory, "plot_step02_iv_pv.m"));
fprintf("\nSTEP 2 calculations finished. Validate figures and values in MATLAB.\n");
