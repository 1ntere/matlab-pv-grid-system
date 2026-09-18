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

## STEP 3 — P&O MPPT Tracking

### 상태

- Implemented
- Not yet runtime-validated in MATLAB

### 핵심 개념

- P&O는 `ΔP`와 `ΔV`의 부호가 같으면 voltage perturb 방향을 유지하고, 다르면 반전한다.
- 고정 perturb 방식은 MPP에 도달한 뒤에도 주변 두 동작점 사이를 움직이므로 정상상태 oscillation이 남는다.
- perturb step을 키우면 수렴은 빨라지지만 정상상태 오차와 ripple이 커지고, 줄이면 반대 trade-off가 생긴다.
- 일사량 급변으로 발생한 `ΔP`를 controller perturb의 결과로 오인하면 일시적으로 잘못된 방향을 선택할 수 있다.

이번 단계의 plant는 `Vpv(k+1) = Vpv(k) + alpha*(Vref-Vpv(k))`인 voltage follower이다. 이는 MPPT 논리 검증용 abstraction이며 Boost Converter의 inductor, capacitor, switching 및 duty-ratio dynamics를 표현하지 않는다. STEP 4에서는 Vref를 실제 converter와 voltage-control 구조에 연결해야 한다.

## STEP 4 — Averaged Boost Converter / DC-Link

### 상태

- Implemented
- Not yet runtime-validated in MATLAB

### 핵심 개념

- 이상적인 Boost 관계는 `Vout = Vin/(1-D)`이며 duty가 증가하면 승압비가 커진다.
- Inductor는 입력 에너지를 저장하고 전달하며, 입력 capacitor는 PV voltage dynamics를 형성한다.
- DC-link capacitor는 입력·출력 전력의 순간 차이를 흡수하여 DC voltage를 완충한다.
- P&O의 `Vpv_ref`와 실제 `Vpv` 차이를 PI controller가 duty로 변환한다. Boost duty 증가가 Vpv를 낮추므로 error 부호는 `Vpv-Vpv_ref`이다.
- Duty saturation은 비물리적 명령을 막고, conditional integration은 saturation을 더 악화시키는 방향의 integrator 누적을 차단한다.
- Averaged model은 switching period 평균 동특성을 다루므로 semiconductor switching ripple이나 PWM 파형을 표현하지 않는다.

출력에는 향후 inverter를 대신하는 고정 등가 저항을 사용한다. 이는 임시 안정 부하이며 Grid-Side Inverter와 동일하지 않다.

## STEP 5 — Averaged Grid-Side Inverter / dq Control

### 상태

- Implemented
- Not yet runtime-validated in MATLAB

### 핵심 개념

- abc/dq transformation은 60 Hz 3상 정현파를 grid angle과 함께 회전하는 좌표계의 DC-like d/q 값으로 바꾼다.
- amplitude-invariant, negative-q Park convention을 사용하며 grid voltage를 d축에 정렬한다.
- positive d-axis current는 grid로 전달하는 active power를, q-axis current는 reactive power를 주로 결정한다.
- Vdc가 기준보다 높으면 outer PI가 Id reference를 높여 grid active-power export를 증가시킨다.
- inner current PI는 grid-voltage feedforward와 `omega*L` cross-coupling 보상으로 d/q current를 제어한다.
- L filter는 inverter-grid 전압 차이를 current dynamics로 변환한다.
- DC voltage가 허용하는 dq voltage-vector magnitude를 넘으면 command를 축소하고 integrator 누적을 제한한다.
- averaged inverter는 fundamental voltage command만 표현하며 PWM carrier, dead time, switching ripple을 포함하지 않는다.

현재 grid angle은 ideal source이며 PLL은 구현하지 않았다. 따라서 grid synchronization이 검증됐다고 볼 수 없다.
