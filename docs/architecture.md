# System Architecture

향후 목표 시스템의 에너지 흐름은 다음과 같다.

`PV Array → Boost Converter → DC-Link → 3-Phase Inverter → Filter → Transformer → Grid / Local Load`

현재 integrated averaged architecture는 다음과 같다.

```text
[ Irradiance / Temperature ]
            |
        [ PV Array ] <------ Vpv feedback ------+
            |                                    |
      [ P&O MPPT ] -> Vpv_ref -> [ PV Voltage PI ]
                                      |
                                    Duty
                                      |
                         [ Averaged Boost Converter ]
                                      |
                  Boost current -> [ DC-Link ] <- Inverter DC power
                                      |
                  Vdc feedback -> [ Vdc PI ] -> Id_ref
                                      |
                  Iq_ref = 0 -> [ dq Current PI ]
                                      |
                      [ Averaged Grid-Side Inverter ]
                                      |
                                 [ L Filter ]
                                      |
                                   [ Grid ]
```

DC-link는 Boost와 inverter의 energy coupling point다. PV Voltage PI는 PV operating point를 duty로 제어하고, Vdc PI는 grid active-current reference를 조정해 DC energy를 제어한다. Grid angle은 ideal source이며 PLL, PWM switching, transformer는 포함하지 않는다.

제어 구조와 정격 파라미터는 각 STEP에서 검증한 뒤 이 문서에 추가한다.
