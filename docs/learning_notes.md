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

## STEP 2 — PV Module / Array Characteristics

### 상태

- Implemented
- Not yet runtime-validated in MATLAB

### 핵심 개념

- I-V curve는 단자 전압 변화에 따라 PV 전류가 어떻게 감소하는지 보여주며 knee 이후 전류가 급격히 감소한다.
- P-V curve는 `P = V*I`이며 최고점이 maximum power point(MPP)이다.
- 일사량 증가는 주로 광전류와 단락전류를 증가시켜 가용 전력을 높인다.
- 온도 상승은 단락전류를 소폭 높일 수 있지만 개방전압을 낮춰 최대 전력을 감소시키는 경향이 있다.
- 직렬 연결 수 `Ns`는 array 전압을, 병렬 string 수 `Np`는 array 전류와 전력을 주로 결정한다.
- sizing은 목표 MPP 전압을 만족하도록 `Ns`를 올림한 뒤 목표 전력을 만족하도록 `Np`를 올림한다.

### 모델 범위

교육용 simplified single-diode 식에 series/shunt resistance를 포함하고 bounded bisection으로 implicit current를 계산한다. 예제 파라미터는 실제 module 선정 시 datasheet 기반 값으로 교체해야 하며, 이번 단계에서는 nonlinear parameter fitting을 수행하지 않는다.
