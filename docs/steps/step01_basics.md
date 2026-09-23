# STEP 1 — MATLAB/Simulink Modeling Workflow

## Objective

Establish a reproducible MATLAB/Simulink **modeling → execution → result-export** workflow using a small dynamic system.

## Why This Step Exists

The second-order RLC baseline is intentionally compact. It exercises parameter scripts, programmatic model generation, `Simulink.SimulationInput`, simulation output collection, plotting, and artifact export before PV and converter complexity is introduced.

## Model Scope

A series-RLC capacitor-voltage response is represented as:

```text
Vin(s) → 1 / (LCs² + RCs + 1) → Vc(s)
```

The generated model uses basic Simulink blocks and a variable-step `ode45` solver; it is a workflow baseline rather than a power-converter model.

## Implementation / Engineering Flow

1. `step01_parameters.m` defines input, simulation, and RLC values.
2. `build_step01_model.m` generates the Simulink model.
3. `run_step01.m` injects variables and runs it.
4. `plot_step01_results.m` compares input/output and exports a PNG.

## Run

```matlab
run("scripts/setup_project.m")
run("models/step01_basics/run_step01.m")
```

## Expected Outputs

The run is designed to create/update `step01_basic_system.slx`, return input and output timeseries through `simOut`, and save `results/step01/step01_rlc_step_response.png`. The underdamped parameterization is expected to produce a decaying oscillation approaching the unit-step final value; this remains to be confirmed at runtime.

## Validation Criteria

Confirm model generation, update, execution, signal export, plot creation, and qualitative second-order response. Define numerical thresholds before measuring overshoot, settling, or final-value error.

## Current Status

Implemented. Runtime validation pending.

## Known Limitations

This transfer-function exercise does not represent switching hardware or the later PV-grid system.

## Role in Later Steps / Transition

The same parameter → run → collect → plot pattern supports every later STEP.

## Related Files

- `models/step01_basics/step01_parameters.m`
- `models/step01_basics/build_step01_model.m`
- `models/step01_basics/run_step01.m`
- `models/step01_basics/plot_step01_results.m`
