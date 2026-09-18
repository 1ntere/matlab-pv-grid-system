# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

현재 두 subsystem을 독립적으로 구현한 상태다.

`PV Array → P&O MPPT → PV Voltage PI → Averaged Boost Converter → DC-Link`

`DC-Link source → Vdc PI → Id_ref → dq Current PI → Averaged Grid-Side Inverter → L Filter → Grid`

Grid-side q-axis reference는 0 A이며 ideal grid angle을 사용한다. PLL, PWM switching, transformer는 아직 포함하지 않는다.

향후 통합 순서는 다음과 같다.

STEP 6에서 Boost의 DC-link와 Grid-Side Inverter subsystem을 연결하고 전체 power balance를 검토한다.

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다.
