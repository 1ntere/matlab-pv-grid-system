# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

현재 구현 범위는 MATLAB 기반 PV Module / PV Array characterization과 array sizing까지이다. STEP 2에서는 MPPT나 전력변환 회로를 연결하지 않는다.

향후 통합 순서는 다음과 같다.

`PV Array → MPPT → Boost Converter → DC-Link → Inverter → Grid`

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다.
