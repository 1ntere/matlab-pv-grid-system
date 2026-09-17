# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다. STEP 0에서는 Simulink 모델을 생성하지 않는다.
