# STEP 3 — P&O MPPT

## Objective

Isolate and inspect Perturb and Observe MPPT logic before introducing Boost Converter dynamics.

## Why This Step Exists

A simplified voltage-following abstraction separates MPPT decisions from inductor, capacitor, duty, and switching effects. This makes controller direction and reference generation easier to diagnose.

## Model Scope

The plant moves `Vpv` toward `Vpv_ref`; it is not a physical Boost model. The configured irradiance sequence at 25 °C is:

| Time | Irradiance |
| --- | ---: |
| 0–1 s | 600 W/m² |
| 1–2 s | 1000 W/m² |
| 2–3 s | 800 W/m² |
| 3–4 s | 400 W/m² |

## System / Control Structure

```text
Vpv, Ipv → Ppv = Vpv × Ipv → ΔP, ΔV → P&O decision → Vpv_ref
```

The sign combination of `ΔP` and `ΔV` determines whether the voltage perturbation direction is retained or reversed. Fixed perturbation is expected to leave motion around the MPP rather than an exact stationary point.

## Parameters

The implementation samples at 0.005 s, uses a 0.20 V module-level perturbation, and evaluates metrics over the final 20% of each one-second irradiance interval. Theoretical references come from STEP 2 curves.

## Implementation / Engineering Flow

The runner loads PV and MPPT parameters, simulates the voltage follower, compares measured behavior with curve-derived MPP references, then prepares plots and a summary table.

## Run

```matlab
run("scripts/setup_project.m")
run("models/step03_mppt/run_step03.m")
```

## Expected Outputs

Four figures and `results/step03/step03_tracking_summary.csv`, including `Vpv`, `Ipv`, `Ppv`, `Vpv_ref`, and interval metrics. Their presence and values require runtime confirmation.

## Validation Criteria

Check P&O branch decisions, reference bounds, transition handling, and metric-window selection. Evaluate voltage error, power error, or tracking efficiency only against thresholds defined before inspecting results; no new pass threshold is set here.

## Current Status

Implemented. Runtime validation pending.

## Known Limitations

The follower omits converter physics. Irradiance changes can also perturb measured power and temporarily confound the basic P&O decision.

## Role in Later Steps / Transition

STEP 4 connects the same reference concept to a physical averaged Boost plant and PV-voltage PI loop.

## Related Files

- `models/step03_mppt/step03_mppt_parameters.m`
- `models/step03_mppt/po_mppt_step.m`
- `models/step03_mppt/simulate_po_mppt.m`
- `models/step03_mppt/run_step03.m`
