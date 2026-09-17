# MATLAB Grid-Connected PV System

MATLAB/Simulink 기반으로 계통연계형 태양광 발전 시스템을 단계적으로 설계하고 검증하는 학습 프로젝트입니다. 최종 목표는 약 1 MW급 PV array, MPPT, boost converter, DC-link, 3상 인버터, 필터, 변압기 및 계통/부하를 통합하고 일사량 변화에 대한 과도응답을 분석하는 것입니다.

## Current status

- 완료: STEP 0 — 저장소 구조, 환경 점검 스크립트, 프로젝트 초기화 스크립트
- 구현됨, 실행 검증 전: STEP 1 — MATLAB/Simulink 기초 동적 시스템
- 예정: STEP 2~6 — PV array부터 통합 계통연계 시스템까지 단계별 구현

STEP 1 코드는 작성되었지만 MATLAB/Simulink에서 아직 runtime validation을 수행하지 않았습니다. 현재 저장소에는 PV 또는 전력변환 모델이 포함되어 있지 않습니다. 각 단계의 모델과 결과는 실행·검증 후에만 완료로 표시합니다.

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
