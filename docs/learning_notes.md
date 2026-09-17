# Learning Notes

각 STEP에서 다음 내용을 기록한다.

- 새로 사용한 MATLAB/Simulink 기능
- 블록과 파라미터의 물리적 의미 및 단위
- 제어기 입력과 출력
- 예상 정상 동작과 실제 결과
- 오류 증상, 원인, 확인 절차 및 수정 내용
- 다음 STEP으로 넘어가기 전에 남은 질문

## STEP 1 — MATLAB/Simulink Basics

### 상태

- Implemented
- Not yet runtime-validated in MATLAB/Simulink

### 목표 및 모델

MATLAB script에서 파라미터를 정의하고 단순한 Simulink 모델을 생성·실행한 뒤, `Simulink.SimulationOutput`으로 결과를 받아 시각화하는 흐름을 익힌다. 모델은 `Vin(s) → 1/(L*C*s^2 + R*C*s + 1) → Vc(s)`인 직렬 RLC 등가 2차 시스템이다.

사용 블록은 `Step`, `Transfer Fcn`, `Mux`, `Scope`, `To Workspace`이며 variable-step `ode45` solver를 사용한다.

### MATLAB ↔ Simulink 연결

1. `step01_parameters.m`이 입력, simulation, RLC 파라미터를 정의한다.
2. 생성 스크립트는 숫자 대신 `R_ohm`, `L_H`, `C_F` 같은 변수 이름과 식을 블록에 설정한다.
3. `run_step01.m`이 `Simulink.SimulationInput`으로 변수들을 전달한다.
4. 입력과 출력 timeseries는 `simOut.input_signal`, `simOut.output_signal`로 반환된다.
5. plot 스크립트가 두 신호를 비교하고 PNG를 저장한다.

### 예상 결과와 미검증 항목

감쇠비가 1보다 작아 출력은 overshoot와 감쇠 진동을 보인 뒤 약 1 V로 수렴할 것으로 예상한다. 모델 생성·update, simulation, Scope 파형, `simOut` timeseries와 PNG 생성은 MATLAB GUI에서 실제 확인해야 한다.
