# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

현재 구현 범위는 다음과 같다.

`PV Array → P&O MPPT → PV Voltage PI → Averaged Boost Converter → DC-Link`

MPPT 출력 `Vpv_ref`는 이제 PI controller를 거쳐 bounded duty command로 변환된다. Boost stage는 averaged state equations와 temporary DC resistive load를 사용하며 detailed semiconductor switching은 포함하지 않는다.

향후 통합 순서는 다음과 같다.

`DC-Link → Grid-Side Inverter → Filter → Transformer → Grid`

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다.
