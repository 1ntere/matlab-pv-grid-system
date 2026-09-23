# Technical Documentation

The project is implemented through STEP 6. MATLAB runtime validation and quantitative result verification remain pending; throughout these documents, **implemented does not mean validated**.

## Documentation Map

### System-Level Documentation

- [System Architecture](architecture.md) — canonical boundary, power flow, controls, equations, and assumptions
- [Validation Strategy](validation_strategy.md) — evidence levels and stage-specific validation considerations
- Existing context: [Project Charter](project_charter.md) and [Learning Notes](learning_notes.md)

### Step-by-Step Development

- [STEP 1 — MATLAB/Simulink Modeling Workflow](steps/step01_basics.md)
- [STEP 2 — PV Module and Array Modeling](steps/step02_pv_array.md)
- [STEP 3 — P&O MPPT](steps/step03_mppt.md)
- [STEP 4 — Averaged Boost Converter and DC-Link](steps/step04_boost_dc_link.md)
- [STEP 5 — Averaged Grid-Side Inverter and dq Control](steps/step05_grid_inverter.md)
- [STEP 6 — Integrated PV-Grid System](steps/step06_integrated_system.md)

## Recommended Reading Paths

### Quick technical review

[Root README](../README.md) → [Architecture](architecture.md) → [STEP 6](steps/step06_integrated_system.md) → [Validation Strategy](validation_strategy.md)

### Implementation review

[STEP 1](steps/step01_basics.md) → [STEP 2](steps/step02_pv_array.md) → [STEP 3](steps/step03_mppt.md) → [STEP 4](steps/step04_boost_dc_link.md) → [STEP 5](steps/step05_grid_inverter.md) → [STEP 6](steps/step06_integrated_system.md)

### Validation review

[Validation Strategy](validation_strategy.md) → relevant STEP document → generated outputs under `results/`

## Development Philosophy

1. Separate subsystem development from system integration.
2. Reuse previously developed subsystem logic.
3. Separate implementation claims from validation claims.

## Documentation Conventions

- `STEP N` is a development stage, not a validation level.
- **Implemented** means the files and logic are present.
- **Runtime validation pending** means execution and evidence review are incomplete.
- `Vpv`, `Ipv`, and `Ppv` are PV terminal voltage, current, and power.
- `Vdc` is DC-link voltage; `iL` is Boost-inductor current; `D` is duty ratio.
- `Id` and `Iq` are grid-current components in the implemented dq convention.

## Repository Relationship

These documents explain but do not replace the source. Stage implementations live under `models/stepNN_*`, environment scripts under `scripts/`, and generated evidence under `results/`. When documentation and implementation disagree, the current implementation is the source of truth and the discrepancy should be corrected explicitly.
