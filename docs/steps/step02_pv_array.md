# STEP 2 — PV Module and Array Modeling

## Objective

Generate PV I-V/P-V characteristics, identify MPP values, and size an approximately 1 MW array.

## Why This Step Exists

Later MPPT and converter stages need a nonlinear PV source and a transparent link from module ratings to system scale.

## Model Scope

The source is a simplified single-diode engineering model with series/shunt effects and bounded solution of implicit current. It compares irradiance at 400, 600, 800, and 1000 W/m² at 25 °C, and temperature at 25 and 45 °C at 1000 W/m².

## System / Mathematical Structure

For each curve, `P = V × I` and the sampled maximum gives `Vmp`, `Imp`, and `Pmp`. Sizing rounds upward:

```text
Ns = ceil(target voltage / module Vmp)
Np = ceil(target power / (Ns × module Pmp))
```

The repository parameters give `Ns = 25`, `Np = 74`, 1,850 modules, and `1,005,752.5 W ≈ 1.006 MW` nominal power.

## Parameters

The example module uses `Vmp = 41.5 V`, `Imp = 13.1 A`, and `Pmp = 543.65 W`; targets are 1 MW and 1000 V. This is a replaceable engineering example, not manufacturer-specific accuracy.

## Run

```matlab
run("scripts/setup_project.m")
run("models/step02_pv_array/run_step02.m")
```

## Expected Outputs

I-V/P-V and temperature-comparison figures under `results/step02/`, plus module, sizing, and condition-specific MPP summaries in the Command Window.

## Validation Criteria

Check curve shape and irradiance/temperature direction, reproduce MPP extraction, and independently recalculate the array counts and rating. Quantitative tolerances must be declared before evaluation.

## Current Status

Implemented. Runtime validation pending.

## Known Limitations

No manufacturer parameter fitting or accuracy claim is included.

## Role in Later Steps / Transition

The PV calculation and sizing are reused by MPPT, Boost, and integrated simulations.

## Related Files

- `models/step02_pv_array/step02_pv_parameters.m`
- `models/step02_pv_array/calculate_pv_module_iv.m`
- `models/step02_pv_array/calculate_pv_array_size.m`
- `models/step02_pv_array/run_step02.m`
