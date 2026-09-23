# Validation Strategy

## Principle

**Implementation is not treated as validation.** Present and coherent source files do not establish executability, plausible behavior, quantitative acceptance, or acceptable behavior after coupling.

## Validation Hierarchy

### Level 1 — Implemented

Required files, equations, parameters, signal paths, and controls are present. Source inspection is evidence only for implementation.

### Level 2 — Executable

The runner completes in the reference MATLAB/Simulink environment without unintended errors and produces its documented artifacts. Record environment, invocation, completion, and outputs.

### Level 3 — Behavior Checked

Signals have expected qualitative direction, sequence, bounds, and relationships. Examples include I-V/P-V shape, MPPT perturb direction, bounded duty, and intended current sign.

### Level 4 — Quantitatively Validated

Predefined metrics and acceptance thresholds are evaluated against saved results. Record the window, reference, units, calculation, threshold, and outcome. Thresholds must be defined before results are interpreted, not chosen retrospectively to fit observations.

### Level 5 — Integrated Validation

STEP 6 is assessed for numerical integrity, subsystem behavior, shared-state dynamics, and cross-boundary power consistency under the planned operating sequence.

## Current State

| Stage | Implemented | Executable | Behavior Checked | Quantitatively Validated | Integrated Validation |
| --- | :---: | :---: | :---: | :---: | :---: |
| STEP 1 | ✅ | ⏳ | ⏳ | ⏳ | N/A |
| STEP 2 | ✅ | ⏳ | ⏳ | ⏳ | N/A |
| STEP 3 | ✅ | ⏳ | ⏳ | ⏳ | N/A |
| STEP 4 | ✅ | ⏳ | ⏳ | ⏳ | N/A |
| STEP 5 | ✅ | ⏳ | ⏳ | ⏳ | N/A |
| STEP 6 | ✅ | ⏳ | ⏳ | ⏳ | ⏳ |

Runtime validation was not performed during the documentation refactor.

## Evidence Expected

For each run, record MATLAB release and products, commit and runner, parameters and inputs, reproducible outputs, evaluation windows and equations, thresholds defined in advance, and observed outcomes including failures. Generated metrics remain observations until a declared criterion and suitable reference make them evidence.

## STEP-Specific Considerations

### STEP 1

Confirm model generation, simulation, `SimulationOutput`, and export; inspect expected second-order RLC behavior before applying predefined quantitative criteria.

### STEP 2

Inspect I-V/P-V curve shape and recalculate `Ns`, `Np`, module count, nominal voltage, and power. Do not infer manufacturer accuracy.

### STEP 3

Check P&O decisions, bounds, and transitions at 1, 2, and 3 seconds. Evaluate only the configured final 20% of each interval, using criteria defined in advance.

### STEP 4

Check numerical finiteness, state bounds, duty saturation, anti-windup, controller sign, inductor current, PV tracking, and temporary-load power consistency. Conclusions apply only to that test boundary.

### STEP 5

Check transforms, angle convention, outer-loop sign, current tracking, voltage limiting, and power calculation. Review `Id`, `Iq`, DC voltage, power, and saturation. Do not claim PLL performance.

### STEP 6

Repeat all relevant checks after coupling. Evaluate in layers: (1) numerical integrity, (2) PV-side behavior, (3) DC-link behavior, (4) grid-side behavior, and (5) integration consistency. Account for stored-energy changes in instantaneous power comparisons.

## Coupling Rule

```text
STEP 4 validated in isolation
              +
STEP 5 validated in isolation
              ≠
STEP 6 validated after coupling
```

Coupling removes fixed load/source boundaries and adds controller interaction through `Vdc`; it can expose saturation, timescale, initialization, or energy-balance behavior absent from isolated tests.

## Related Documentation

- [System Architecture](architecture.md)
- [STEP Documents](README.md#step-by-step-development)
