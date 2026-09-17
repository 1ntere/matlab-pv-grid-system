# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

현재 구현 범위는 다음과 같다.

`PV Module / PV Array → P&O MPPT (Vref abstraction)`

MPPT 출력은 현재 simplified voltage-following plant의 기준전압이다. Boost Converter의 duty ratio나 switching dynamics는 포함하지 않으며 STEP 4에서 physical converter control에 연결할 예정이다.

향후 통합 순서는 다음과 같다.

`PV Array → MPPT → Boost Converter → DC-Link → Grid-Side Inverter → Grid`

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다.
