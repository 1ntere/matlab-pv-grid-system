# MATLAB Grid-Connected PV System

MATLAB/Simulink 기반으로 계통연계형 태양광 발전 시스템을 단계적으로 설계하고 검증하는 학습 프로젝트입니다. 최종 목표는 약 1 MW급 PV array, MPPT, boost converter, DC-link, 3상 인버터, 필터, 변압기 및 계통/부하를 통합하고 일사량 변화에 대한 과도응답을 분석하는 것입니다.

## Current status

- 완료: STEP 0 — 저장소 구조, 환경 점검 스크립트, 프로젝트 초기화 스크립트
- 구현됨, 실행 검증 전: STEP 1 — MATLAB/Simulink 기초 동적 시스템
- 구현됨, 실행 검증 전: STEP 2 — PV module/array 특성 및 sizing
- 구현됨, 실행 검증 전: STEP 3 — P&O MPPT tracking
- 구현됨, 실행 검증 전: STEP 4 — averaged Boost Converter 및 DC-link
- 예정: STEP 5~6 — Grid-side inverter 및 통합 시스템

STEP 1부터 STEP 4까지 코드는 작성되었지만 MATLAB/Simulink에서 아직 runtime validation을 수행하지 않았습니다. 현재 전력변환 구현은 averaged Boost model까지이며 switching model과 AC 계통연계 stage는 포함되어 있지 않습니다. 각 단계의 모델과 결과는 실행·검증 후에만 완료로 표시합니다.

## Requirements

기준 버전은 MATLAB/Simulink R2025a이며, 가능한 범위에서 R2024b와의 호환성을 유지합니다.

- MATLAB
- Simulink
- Simscape
- Simscape Electrical

설치 및 라이선스 상태는 MATLAB에서 다음 명령으로 확인할 수 있습니다.

```matlab
run("scripts/check_environment.m")
```

## Getting started

저장소 루트에서 MATLAB을 연 뒤 다음을 실행합니다.

```matlab
run("scripts/setup_project.m")
```

스크립트는 프로젝트 폴더를 MATLAB path에 추가하고 `results/` 폴더를 준비한 뒤 환경 점검을 실행합니다.

## STEP 1 — MATLAB/Simulink basics

직렬 RLC 회로의 커패시터 전압을 `Vin(s) → 1/(L*C*s^2 + R*C*s + 1) → Vc(s)`로 표현한 2차 시스템입니다. Simscape 없이 `Step`, `Transfer Fcn`, `Mux`, `Scope`, `To Workspace` 기본 블록을 사용합니다.

저장소 루트에서 다음을 실행합니다.

```matlab
run("scripts/setup_project.m")
run("models/step01_basics/run_step01.m")
```

두 번째 명령은 파라미터 로드, `step01_basic_system.slx` 생성, simulation, `simOut` 결과 수집, plot 및 `results/step01/step01_rlc_step_response.png` 저장을 순서대로 수행합니다. 정상 동작 시 단위 계단 입력 이후 커패시터 전압이 감쇠 진동하며 약 1 V에 수렴해야 합니다. 실제 결과는 MATLAB/Simulink에서 확인해야 합니다.

## STEP 2 — PV module and array characteristics

STEP 2는 simplified single-diode 식으로 module I-V/P-V 특성을 계산하고 약 1 MW, 1000 V급 array의 직렬·병렬 개수를 산정합니다. 입력값은 특정 강의자료나 제조사 제품을 복제한 값이 아닌 교체 가능한 example engineering parameters입니다.

- 일사량 비교: 400, 600, 800, 1000 W/m² (25 °C)
- 온도 비교: 25, 45 °C (1000 W/m²)
- 배열 구성: `Ns = ceil(target voltage / module Vmp)`, 이후 `Np = ceil(target power / string power)`
- 상태: Implemented / Not yet runtime-validated

저장소 루트에서 실행합니다.

```matlab
run("scripts/setup_project.m")
run("models/step02_pv_array/run_step02.m")
```

실행 시 I-V, P-V 및 온도 비교 그림을 `results/step02/`에 저장하고 module, array sizing, 조건별 MPP 요약을 Command Window에 출력합니다.

## STEP 3 — P&O MPPT tracking

P&O는 직전 측정과 비교한 `ΔP` 및 `ΔV`의 부호로 PV voltage reference(`Vref`)의 perturb 방향을 결정합니다. 이 단계는 Boost Converter 없이 1차 voltage-following plant abstraction을 사용하여 MPPT 논리만 분리해 검증합니다. 실제 converter dynamics나 duty-ratio 제어를 나타내지 않으며 STEP 4에서 physical Boost Converter 제어와 연결할 예정입니다.

- 일사량: 0–1 s 600, 1–2 s 1000, 2–3 s 800, 3–4 s 400 W/m²
- 추적 신호: Vpv, Ipv, Ppv, Vref
- 기준값: STEP 2 I-V curve에서 계산한 theoretical Vmpp/Pmpp
- 평가: 각 일사량 구간 마지막 20%의 평균 voltage/power error와 tracking efficiency
- 상태: Implemented / Not yet runtime-validated

저장소 루트에서 실행합니다.

```matlab
run("scripts/setup_project.m")
run("models/step03_mppt/run_step03.m")
```

그림 네 개와 `step03_tracking_summary.csv`가 `results/step03/`에 생성됩니다.

## STEP 4 — Averaged Boost Converter and DC-link

STEP 4 validates converter-level dynamics using an averaged Boost Converter model before introducing detailed switching behavior. 상태는 PV input-capacitor voltage, inductor current, DC-link capacitor voltage이며, P&O의 `Vpv_ref`를 PI voltage controller가 duty command로 변환합니다.

Boost에서는 duty 증가가 inductor current를 높여 PV-side voltage를 낮추는 방향으로 작용하므로 PI error는 `Vpv - Vpv_ref`를 사용합니다. Duty는 0.05–0.90으로 제한하고 conditional integration anti-windup을 적용합니다. 출력의 고정 등가 저항은 Grid-Side Inverter가 추가되기 전까지 사용하는 temporary DC load이며 실제 inverter load를 나타내지 않습니다.

- averaged model: `diL/dt = (Vpv-(1-D)Vdc)/L`
- DC-link: `dVdc/dt = ((1-D)iL-Iload)/Cdc`
- 입력단: `dVpv/dt = (Ipv-iL)/Cpv`
- 일사량: STEP 3과 동일한 600 → 1000 → 800 → 400 W/m²
- 상태: Implemented / Not yet runtime-validated

```matlab
run("scripts/setup_project.m")
run("models/step04_boost_converter/run_step04.m")
```

결과 그림 네 개와 `step04_summary.csv`가 `results/step04/`에 생성됩니다. STEP 5에서는 temporary load 대신 Grid-Side Inverter stage를 연결할 예정입니다.

## Repository structure

- `docs/`: 프로젝트 범위, 아키텍처, 학습 기록
- `scripts/`: 환경 점검 및 프로젝트 설정
- `models/`: STEP별 Simulink 모델과 생성·실행 스크립트
- `analysis/`: 결과 시각화와 과도응답 분석(향후 작성)
- `results/`: 직접 생성한 결과 파일(대용량/자동 생성 파일은 Git 제외)
- `references/`: 외부 자료의 출처와 메모만 기록하며 원본은 저장하지 않음
- `tests/`: 단계별 검증 코드(향후 작성)

## Roadmap

1. Repository setup
2. MATLAB/Simulink basics
3. PV array modeling
4. P&O MPPT
5. Boost converter and DC-link
6. Grid-side inverter and control
7. Integrated 1 MW grid-connected PV system
8. Irradiance transient-response analysis

## Source-material policy

교수 제공 PDF, 강의자료, 과제 원문, 개인 이메일은 이 저장소에 올리지 않습니다. 저장소에는 직접 작성한 코드·모델·설명·도표 및 직접 생성한 결과만 포함합니다.

## License

포트폴리오 공개 전 코드 및 제3자 자료의 라이선스를 검토한 뒤 라이선스 파일을 추가할 예정입니다.
