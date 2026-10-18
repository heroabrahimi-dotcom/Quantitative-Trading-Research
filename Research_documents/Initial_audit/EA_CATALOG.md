# EA catalog — 2026-10-09

## How to read this catalog

32 installed EAs have source, binary and one matching-name preset each. These are observed files, not 32 independently validated strategies. The original batch contains 30 sources; 26 are byte-identical to installed sources, BTCUSD/US30/US500 have changed, and original USDJPY has been replaced by USDJPY 3EA. GOLD 3ea and NAS100 3ea are additional strategies. Snapshots preserve exact bytes. Matching source/binary names do not establish a verified build relationship.

Source defaults below are distinct from saved preset values and from inputs in a particular report. Exact paths, SHA-256 hashes and preset values are in installed_eas.json. Report inventory retains older/deleted runs; catalog links do not restore them to the dashboard.

## Shared Q30 rule language

Each session evaluates C1 and C2; actions A0/A1/A2/A3 correspond respectively to true/true, true/false, false/true, false/false. BUY=+1; SELL=-1; REV reverses the referenced direction; MAJ_X123 takes the majority of three nonzero directions. Missing/flat references skip the signal. B=NY, I=Asia, P=London.

For a NY entry, Bn means NY n trading days ago, In/Pn means Asia/London n−1 trading days ago. For Asia/London entry, Bn is NY n+1 days ago, In/Pn is n days ago. Trading days are detected from available M30 data. None of the currently extracted NY rule tables uses P1 or MAJ_P; do not claim a current unfinished-London leak. Future rules must retain this availability guard.

Shared session clock: Asia 09:00–15:00 Tokyo (00:00–06:00 UTC), London 08:30–16:30 local (10:30–18:30 broker), NY 09:30–16:00 local. Broker UTC+2 winter/+3 summer follows EU DST; NY follows US DST. Keep existing logic unchanged for baseline reproduction, and test DST mismatch weeks explicitly.

26 fixed-lot EAs use 0.10 lots by default, no SL/TP, first available entry tick in a 30-minute window, and session-end closure. This is not equal monetary risk across symbols. Missing data, restart behavior, overlapping sessions and account netting mode require tests; see SOURCE_AUDIT.md.

BTCUSD/US30/US500 risk variants size from 144 historical same-session ranges, default monetary sizing target 600 and SL enabled. USDJPY 3EA has a distinct implementation with a confirmed lookback defect. GOLD/NAS100 use different rule engines described in SOURCE_AUDIT.md.

## Installed strategies

### GOLD 3ea

- Family: Session2 GOLD EMA + A/B cycle
- Symbol: _Symbol (tester/chart supplied); internal timeframe: M30 session data; H1 EMA
- Source: [GOLD 3ea.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\ACTIVE\GOLD 3ea.mq5>)
- Source SHA-256: `2c2dfc886e59884561382f91b4ae41973c2dcfff22f0f43a2f8a36d21569c34e`
- Binary SHA-256: `39fb6146d3796de2c95e1a96d2e088097f9706e83b1edeb616d413501bb66638`
- Frozen source: [2c2dfc886e59_GOLD 3ea.mq5](<../01_EXISTING_EAS/installed/2c2dfc886e59_GOLD 3ea.mq5>)
- Build correspondence: unverified.

Signal rules: see the GOLD/NAS100 sections of SOURCE_AUDIT.md; these are not generic Q30 tables.

| Input | Source default | Current preset |
| --- | --- | --- |
| MagicNumber | 26091602 | 26091602 |
| EnableAsia | true | true |
| EnableLondon | true | true |
| EnableNY | true | true |
| SheetRiskAmount | 600.0 | 600.0 |
| UseStopLoss | false | false |
| SL_Multiplier | 1.0 | 1.0 |
| UseSameDirectionStopOrder | true | true |
| StopOrdersOnly | false | false |
| StopOrderDistanceMultiplier | 1.0 | 1.0 |
| StopOrderLotMultiplier | 1.0 | 1.0 |
| UseStopOrderSL | false | false |
| StopOrderSLMultiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |
| SheetPipsPerPriceUnit | 10.0 | 10.0 |
| MaxEntryDelaySeconds | 120 | 120 |
| MaxDeviationPoints | 30 | 30 |
| RequireHedgingAccount | true | true |
| EMA_Period | 50 | 50 |
| Broker_UTC_Offset_Winter | 2 | 2 |
| Broker_UTC_Offset_Summer | 3 | 3 |
| Broker_Follows_EU_DST | true | true |
| ReverseAllSignals | false | false |
| ShowRegimePanel | false | false |
| PanelX | 10 | 10 |
| PanelY | 25 | 25 |
| PanelWidth | 330 | 330 |
| PanelHeight | 390 | 390 |
| RegimeShortTrades | 20 | 20 |
| RegimeLongTrades | 60 | 60 |
| RegimeATRPeriod | 14 | 14 |
| RegimeATRBaselineBars | 20 | 20 |
| RegimeEMA200Period | 200 | 200 |
| RegimeEMABaselineBars | 20 | 20 |
| UseHistoricalRegimeBackfill | true | true |
| TrackRegimeBacktestStats | true | true |

Preset: [GOLD 3ea.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\GOLD 3ea.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\ACTIVE_GOLD_3ea_e9adec08ca\b61ff97a89e045c5830447387de36fc2\full\report.htm>). Range 2022-01-01 → 2026-10-05; 4240 trades; PF 1.1; native relative equity DD 25.59%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### NAS100 3ea

- Family: Session2 NAS100 decision rules + EMA
- Symbol: _Symbol (tester/chart supplied); internal timeframe: M30 session data; H1 EMA
- Source: [NAS100 3ea.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\ACTIVE\NAS100 3ea.mq5>)
- Source SHA-256: `1d60c734b7e62e7b8038df6f8d20363db21ea2ccc02475675cccc56ee38753b0`
- Binary SHA-256: `4c2aa2b80f1248f12b3b3e2c8d72515453607322c6b32f3f97f5f7f8c2d77d7c`
- Frozen source: [1d60c734b7e6_NAS100 3ea.mq5](<../01_EXISTING_EAS/installed/1d60c734b7e6_NAS100 3ea.mq5>)
- Build correspondence: unverified.

Signal rules: see the GOLD/NAS100 sections of SOURCE_AUDIT.md; these are not generic Q30 tables.

| Input | Source default | Current preset |
| --- | --- | --- |
| MagicNumber | 26092701 | 26092701 |
| EnableAsia | true | true |
| EnableLondon | true | true |
| EnableNY | true | true |
| SheetRiskAmount | 600.0 | 600.0 |
| UseStopLoss | true | true |
| SL_Multiplier | 1.0 | 1.0 |
| UseSameDirectionStopOrder | false | false |
| StopOrdersOnly | false | false |
| StopOrderDistanceMultiplier | 1.0 | 1.0 |
| StopOrderLotMultiplier | 1.0 | 1.0 |
| UseStopOrderSL | false | false |
| StopOrderSLMultiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |
| SheetPipsPerPriceUnit | 10.0 | 10.0 |
| MaxEntryDelaySeconds | 120 | 120 |
| MaxDeviationPoints | 30 | 30 |
| RequireHedgingAccount | true | true |
| EMA_Period | 50 | 50 |
| Broker_UTC_Offset_Winter | 2 | 2 |
| Broker_UTC_Offset_Summer | 3 | 3 |
| Broker_Follows_EU_DST | true | true |
| ReverseAllSignals | false | false |
| ShowRegimePanel | false | false |
| PanelX | 10 | 10 |
| PanelY | 25 | 25 |
| PanelWidth | 330 | 330 |
| PanelHeight | 390 | 390 |
| RegimeShortTrades | 20 | 20 |
| RegimeLongTrades | 60 | 60 |
| RegimeATRPeriod | 14 | 14 |
| RegimeATRBaselineBars | 20 | 20 |
| RegimeEMA200Period | 200 | 200 |
| RegimeEMABaselineBars | 20 | 20 |
| UseHistoricalRegimeBackfill | true | true |
| TrackRegimeBacktestStats | true | true |

Preset: [NAS100 3ea.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\NAS100 3ea.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\ACTIVE_NAS100_3ea_24dfb03914\a31b3c919e57413fb767c9351877a9a6\full\report.htm>). Range 2022-01-01 → 2026-10-05; 3665 trades; PF 1.15; native relative equity DD 6.7%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### AUDUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "AUDUSD.a"; internal timeframe: M30 session data
- Source: [AUDUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\AUDUSD_a_2COND.mq5>)
- Source SHA-256: `c1d351b99a73aa2f4a4eeca05aba718f0e055f8ce11f1761e30abe004ed5caed`
- Binary SHA-256: `43aa9ae7453b0433a5480e0aad8cd734a6c14feae4eb2935c6df845740876777`
- Frozen source: [c1d351b99a73_AUDUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/c1d351b99a73_AUDUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I1=BUY | B3=P3 | B3 | MAJ_P123 | B1 | REV_I1 |
| LONDON | I2=P2 | P2=P3 | I1 | MAJ_B123 | REV_I1 | REV_B1 |
| NY | I3=BUY | P3=BUY | P2 | I1 | REV_B3 | I2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "AUDUSD.a" | AUDUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100005 | 26100005 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [AUDUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\AUDUSD_a_2COND.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\Quant30Auto_AUDUSD_a_2COND_acc2a9562b\62cf76925ce14dcea2cc0c9c88571f38\full\report.htm>). Range 2022-01-01 → 2026-10-04; 3683 trades; PF 1.13; native relative equity DD 1.15%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### AUS200_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "AUS200.a"; internal timeframe: M30 session data
- Source: [AUS200_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\AUS200_a_2COND.mq5>)
- Source SHA-256: `c06d94a5e4ae46909ff7df305229a5a346535fb3f10b309eb4edb95f5d324184`
- Binary SHA-256: `fc33293dd969feeaf3833557c219d8c4049737e4955f206719f642c8251f6360`
- Frozen source: [c06d94a5e4ae_AUS200_a_2COND.mq5](<../01_EXISTING_EAS/installed/c06d94a5e4ae_AUS200_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I3=BUY | P1=BUY | REV_B2 | REV_P3 | MAJ_P123 | B3 |
| LONDON | I1=P1 | I0=I1 | MAJ_I123 | B2 | P2 | I2 |
| NY | B1=BUY | I2=BUY | P3 | P3 | MAJ_I123 | REV_P2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "AUS200.a" | AUS200.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100009 | 26100009 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [AUS200_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\AUS200_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### BTCAUD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "BTCAUD.a"; internal timeframe: M30 session data
- Source: [BTCAUD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\BTCAUD_a_2COND.mq5>)
- Source SHA-256: `cd329872ec88baa90f1568156e80ffb0bfef7b923f7e7c8ecbf7d01fef8368d6`
- Binary SHA-256: `65f0461a5146883e3c6d7d38f7ad17950752dea77d12aca7518a6c7d88d4e767`
- Frozen source: [cd329872ec88_BTCAUD_a_2COND.mq5](<../01_EXISTING_EAS/installed/cd329872ec88_BTCAUD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=P1 | I2=P2 | REV_I1 | P3 | REV_I3 | REV_I1 |
| LONDON | I2=P2 | I0=B1 | MAJ_B123 | P3 | I1 | REV_P1 |
| NY | P2=BUY | B2=I2 | REV_B1 | P3 | B2 | MAJ_I123 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "BTCAUD.a" | BTCAUD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100016 | 26100016 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [BTCAUD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\BTCAUD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### BTCEUR_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "BTCEUR.a"; internal timeframe: M30 session data
- Source: [BTCEUR_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\BTCEUR_a_2COND.mq5>)
- Source SHA-256: `746a8d28ef538757c9901e76ebb2b5e92f8fce6865d2d8a45ac47e71c3c97380`
- Binary SHA-256: `5948369d55e93935cce77ad53aaf09bc611bcbb3738e424dcbd2e09a417b565e`
- Frozen source: [746a8d28ef53_BTCEUR_a_2COND.mq5](<../01_EXISTING_EAS/installed/746a8d28ef53_BTCEUR_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P2=BUY | I3=P3 | REV_I1 | I1 | REV_I3 | REV_B1 |
| LONDON | B2=I2 | I2=I3 | REV_B2 | B1 | P2 | I1 |
| NY | B1=BUY | B3=I3 | REV_B3 | B2 | I2 | REV_I1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "BTCEUR.a" | BTCEUR.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100017 | 26100017 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [BTCEUR_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\BTCEUR_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### BTCGBP_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "BTCGBP.a"; internal timeframe: M30 session data
- Source: [BTCGBP_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\BTCGBP_a_2COND.mq5>)
- Source SHA-256: `516441c8348223ace4d8be5d1fbb7e3b87434021ebea26d3c4ab2b21e6163aca`
- Binary SHA-256: `73cd89d88fa51efc37bbdf66962d72eab3405a7395e5ae5ab1e6a80050a7ae54`
- Frozen source: [516441c83482_BTCGBP_a_2COND.mq5](<../01_EXISTING_EAS/installed/516441c83482_BTCGBP_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P3=BUY | B2=B3 | REV_I3 | MAJ_P123 | REV_I1 | REV_P2 |
| LONDON | I2=I3 | I0=I1 | I1 | P3 | MAJ_P123 | REV_P3 |
| NY | B1=BUY | I1=BUY | REV_B3 | P3 | P2 | B1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "BTCGBP.a" | BTCGBP.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100018 | 26100018 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [BTCGBP_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\BTCGBP_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### BTCUSD_a_2COND

- Family: Q30 risk-sized decision tree
- Symbol: "BTCUSD.a"; internal timeframe: M30 session data
- Source: [BTCUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\BTCUSD_a_2COND.mq5>)
- Source SHA-256: `cff307b0b2c75e783437c82b80dbd284a11aece466717bc5bae7dd3315f74f81`
- Binary SHA-256: `d78e792949d4ecbca977df0c446e188a5d0aeb389024049981fc301c5025f0b6`
- Frozen source: [cff307b0b2c7_BTCUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/cff307b0b2c7_BTCUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P2=BUY | I1=P1 | REV_P2 | MAJ_P123 | REV_I3 | MAJ_P123 |
| LONDON | B2=P2 | I1=I2 | P3 | REV_P1 | MAJ_B123 | B1 |
| NY | I2=P2 | B3=P3 | I1 | REV_I1 | REV_I3 | I2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "BTCUSD.a" | BTCUSD.a |
| InpLots | 0.10 | 0.01 |
| InpMagic | 26100019 | 26100019 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |
| UseRiskSizing | true | true |
| SheetRiskAmount | 600.0 | 150 |
| UseStopLoss | true | true |
| SL_Multiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |

Preset: [BTCUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\BTCUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### Copper_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "Copper.a"; internal timeframe: M30 session data
- Source: [Copper_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\Copper_a_2COND.mq5>)
- Source SHA-256: `89186382a62a5559ae0b8211bc7f973e8c9ef36d83c8214b22de60f0ef3e11e7`
- Binary SHA-256: `d1fea026b1089d53991f50e2c7340ed5192f2bca3fad5bdf621784f7ecc0cc47`
- Frozen source: [89186382a62a_Copper_a_2COND.mq5](<../01_EXISTING_EAS/installed/89186382a62a_Copper_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=I2 | B3=P3 | B1 | B2 | REV_B1 | MAJ_P123 |
| LONDON | B2=BUY | I2=I3 | P3 | B1 | REV_I1 | I1 |
| NY | P3=BUY | B1=I1 | P2 | REV_P2 | REV_B3 | I2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "Copper.a" | Copper.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100030 | 26100030 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [Copper_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\Copper_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### ETHAUD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "ETHAUD.a"; internal timeframe: M30 session data
- Source: [ETHAUD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\ETHAUD_a_2COND.mq5>)
- Source SHA-256: `3b395ee203a5748701f0557c8d2622eb297cc8607a9312b4e7e6a57434a6326a`
- Binary SHA-256: `491336c9286529ecb13ae36d34d68dcd40ed7ebd3df0e50c4dc2af35c2566bde`
- Frozen source: [3b395ee203a5_ETHAUD_a_2COND.mq5](<../01_EXISTING_EAS/installed/3b395ee203a5_ETHAUD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P1=P2 | P2=P3 | B1 | REV_I2 | B2 | REV_B3 |
| LONDON | I1=P1 | I0=I1 | REV_I2 | P3 | REV_B2 | REV_B2 |
| NY | B2=I2 | B1=B2 | P3 | B3 | REV_B3 | MAJ_I123 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "ETHAUD.a" | ETHAUD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100020 | 26100020 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [ETHAUD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\ETHAUD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### ETHEUR_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "ETHEUR.a"; internal timeframe: M30 session data
- Source: [ETHEUR_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\ETHEUR_a_2COND.mq5>)
- Source SHA-256: `bf7895b80022174bc0c6c8a53cda5affee017dd075721f161036a01e4163ac7b`
- Binary SHA-256: `4852a214105f8bd0913eff8cc2c7b81020b4485cf759c18afd70fda9374b5507`
- Frozen source: [bf7895b80022_ETHEUR_a_2COND.mq5](<../01_EXISTING_EAS/installed/bf7895b80022_ETHEUR_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I3=BUY | B1=B2 | REV_P1 | REV_I1 | MAJ_P123 | REV_P2 |
| LONDON | B1=P1 | B2=I2 | REV_B2 | B1 | B1 | P3 |
| NY | B2=I2 | B2=B3 | MAJ_I123 | REV_I3 | REV_B2 | P2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "ETHEUR.a" | ETHEUR.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100021 | 26100021 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [ETHEUR_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\ETHEUR_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### ETHGBP_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "ETHGBP.a"; internal timeframe: M30 session data
- Source: [ETHGBP_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\ETHGBP_a_2COND.mq5>)
- Source SHA-256: `a88407ab1bcdac38fe7f9057f06e7ee054dec3ac2d2a0b565b0b6b054b34b231`
- Binary SHA-256: `58eccf78810120554c8f1461a9b9080056fb632ebbf252e23964a395abf28ee2`
- Frozen source: [a88407ab1bcd_ETHGBP_a_2COND.mq5](<../01_EXISTING_EAS/installed/a88407ab1bcd_ETHGBP_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I3=BUY | P1=P2 | B3 | REV_I1 | REV_I1 | B2 |
| LONDON | I1=BUY | I2=I3 | I2 | P3 | B3 | MAJ_B123 |
| NY | B2=BUY | P2=BUY | MAJ_I123 | I2 | P3 | I2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "ETHGBP.a" | ETHGBP.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100022 | 26100022 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [ETHGBP_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\ETHGBP_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### ETHUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "ETHUSD.a"; internal timeframe: M30 session data
- Source: [ETHUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\ETHUSD_a_2COND.mq5>)
- Source SHA-256: `44531521a241156c4aea3112bebea3ddd4714a08834a3c68abbf6d550b848d5f`
- Binary SHA-256: `de4eb84777c3a952bdf31119633ea77434cbf1ab6060dff2cd93deb14db941e6`
- Frozen source: [44531521a241_ETHUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/44531521a241_ETHUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I2=BUY | B3=I3 | REV_P2 | REV_I1 | REV_I1 | MAJ_B123 |
| LONDON | B1=BUY | I1=I2 | B1 | REV_P2 | REV_P1 | MAJ_B123 |
| NY | B3=P3 | P2=P3 | I2 | SELL | I2 | B1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "ETHUSD.a" | ETHUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100023 | 26100023 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [ETHUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\ETHUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### EURUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "EURUSD.a"; internal timeframe: M30 session data
- Source: [EURUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\EURUSD_a_2COND.mq5>)
- Source SHA-256: `857b17f8652c8fd8fe43485e3afbcb001182d7f95014dc8e7c8982318e056234`
- Binary SHA-256: `042b5994a9a6f6e006dc37d7e9b59c27836a6bce319726588b2c7fb33b541d50`
- Frozen source: [857b17f8652c_EURUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/857b17f8652c_EURUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=BUY | B3=BUY | REV_P1 | REV_P1 | P1 | I3 |
| LONDON | B1=P1 | B2=I2 | REV_I3 | REV_B3 | B2 | MAJ_P123 |
| NY | I1=BUY | P3=BUY | B3 | B1 | REV_B3 | REV_B2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "EURUSD.a" | EURUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100001 | 26100001 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [EURUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\EURUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### EUSTX50_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "EUSTX50.a"; internal timeframe: M30 session data
- Source: [EUSTX50_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\EUSTX50_a_2COND.mq5>)
- Source SHA-256: `5d286b2ad316919be8b5455914e655dda57fc89abca90ab8ec4929605c0db671`
- Binary SHA-256: `adf4bf4e889014656cd1365a25c39fad00ae54c4a69c9cdddc4a331559b02bdf`
- Frozen source: [5d286b2ad316_EUSTX50_a_2COND.mq5](<../01_EXISTING_EAS/installed/5d286b2ad316_EUSTX50_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=I1 | I3=P3 | REV_I2 | MAJ_P123 | BUY | P1 |
| LONDON | B2=I2 | B3=I3 | REV_B1 | REV_B3 | REV_I1 | P2 |
| NY | I1=BUY | B2=P2 | I2 | REV_B3 | REV_I3 | REV_B2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "EUSTX50.a" | EUSTX50.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100010 | 26100010 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [EUSTX50_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\EUSTX50_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### FRA40_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "FRA40.a"; internal timeframe: M30 session data
- Source: [FRA40_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\FRA40_a_2COND.mq5>)
- Source SHA-256: `54871022dd1137666924fd2cb40bad38c44b0b9cd98611ee271c5e516ee3b73e`
- Binary SHA-256: `5fd4f38a2388dfff7ce0c4d82d06cecd4cee9e077e4ec0b2aadeb25869742bed`
- Frozen source: [54871022dd11_FRA40_a_2COND.mq5](<../01_EXISTING_EAS/installed/54871022dd11_FRA40_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=B2 | P2=P3 | REV_B3 | REV_B1 | B3 | REV_I3 |
| LONDON | P3=BUY | I0=B1 | REV_B3 | P1 | REV_B3 | REV_P1 |
| NY | P3=BUY | B2=P2 | B2 | REV_B2 | B3 | REV_B3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "FRA40.a" | FRA40.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100011 | 26100011 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [FRA40_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\FRA40_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### GBPUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "GBPUSD.a"; internal timeframe: M30 session data
- Source: [GBPUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\GBPUSD_a_2COND.mq5>)
- Source SHA-256: `1448da8d58669da04d7379cf22bbca202d3a6cfbff421bf4cdc8c149d623c651`
- Binary SHA-256: `70febb89138355c1233cda0c09d610ba2a2a87ae723a1f5a649bf18e8f065144`
- Frozen source: [1448da8d5866_GBPUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/1448da8d5866_GBPUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P1=BUY | B1=I1 | B3 | B1 | MAJ_I123 | P3 |
| LONDON | P1=BUY | B1=B2 | I3 | MAJ_P123 | REV_I0 | I3 |
| NY | I1=BUY | I3=BUY | I2 | B1 | REV_P3 | P3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "GBPUSD.a" | GBPUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100003 | 26100003 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [GBPUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\GBPUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### GER40_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "GER40.a"; internal timeframe: M30 session data
- Source: [GER40_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\GER40_a_2COND.mq5>)
- Source SHA-256: `5bcaac17c9252c3e31a7b0c8b3902ddfd0cb08c5894800d43c313dbbccfbf1d6`
- Binary SHA-256: `035b61a1d9675a28b43c5ce11d7934a0f96e6e4960ebfea3a5a08c3eccc797e1`
- Frozen source: [5bcaac17c925_GER40_a_2COND.mq5](<../01_EXISTING_EAS/installed/5bcaac17c925_GER40_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=I2 | B1=B2 | REV_I1 | REV_P3 | REV_I3 | REV_I1 |
| LONDON | P1=BUY | I0=I1 | REV_B2 | P2 | REV_P3 | REV_P3 |
| NY | P3=BUY | B3=I3 | REV_B2 | P3 | I2 | B3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "GER40.a" | GER40.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100015 | 26100015 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [GER40_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\GER40_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### JPN225_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "JPN225.a"; internal timeframe: M30 session data
- Source: [JPN225_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\JPN225_a_2COND.mq5>)
- Source SHA-256: `58cecd24ab5c2fa7901f7d5330e89e084135c8cd9a4652b10142253d7280b3f5`
- Binary SHA-256: `a83fbce034cf277a2ea731124b369171cf926429e7d5437f1600ebe263f1cba6`
- Frozen source: [58cecd24ab5c_JPN225_a_2COND.mq5](<../01_EXISTING_EAS/installed/58cecd24ab5c_JPN225_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B3=BUY | I3=BUY | B1 | B2 | MAJ_P123 | P1 |
| LONDON | I2=I3 | I0=P1 | REV_B3 | MAJ_P123 | BUY | REV_P1 |
| NY | I2=BUY | B3=P3 | REV_B3 | MAJ_I123 | I1 | REV_I1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "JPN225.a" | JPN225.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100012 | 26100012 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [JPN225_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\JPN225_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### LTCUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "LTCUSD.a"; internal timeframe: M30 session data
- Source: [LTCUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\LTCUSD_a_2COND.mq5>)
- Source SHA-256: `61bf19383f6135d67c1a1ef77e843c7611357dd4204b3b234d82dcfa554aec90`
- Binary SHA-256: `b44795f6f006074fbd7e8d2fd92bb9df1e64cbe0c4788ca14bc491f3b80e5f29`
- Frozen source: [61bf19383f61_LTCUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/61bf19383f61_LTCUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B3=BUY | I3=BUY | B1 | REV_B3 | I2 | REV_P3 |
| LONDON | B2=BUY | I0=I1 | I1 | B1 | REV_B3 | B1 |
| NY | B2=BUY | P3=BUY | I2 | B1 | REV_B1 | REV_P2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "LTCUSD.a" | LTCUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100024 | 26100024 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [LTCUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\LTCUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### UK100_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "UK100.a"; internal timeframe: M30 session data
- Source: [UK100_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\UK100_a_2COND.mq5>)
- Source SHA-256: `5531f569bb63f1b6ce125bfaf82fa70030a42630e777a38f1a80f463a22a5274`
- Binary SHA-256: `11c7c665980365aa478c4a48ada8320e591d48aab8791de24573e02f118999f1`
- Frozen source: [5531f569bb63_UK100_a_2COND.mq5](<../01_EXISTING_EAS/installed/5531f569bb63_UK100_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=I2 | B3=P3 | REV_I1 | REV_B1 | REV_I1 | BUY |
| LONDON | B1=P1 | I2=P2 | I2 | MAJ_I123 | REV_I1 | REV_I2 |
| NY | I1=BUY | B3=I3 | REV_P2 | B2 | I2 | P3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "UK100.a" | UK100.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100013 | 26100013 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [UK100_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\UK100_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### US30_a_2COND

- Family: Q30 risk-sized decision tree
- Symbol: "US30.a"; internal timeframe: M30 session data
- Source: [US30_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\US30_a_2COND.mq5>)
- Source SHA-256: `3c842fe329d3e558384613c8b3819c88cdca564a4e7925e2fc17b84aed34e40a`
- Binary SHA-256: `dba8a79c5e8f2542eba0690e7b0e1b30c8f7290963c172a313d57c51c490ad20`
- Frozen source: [3c842fe329d3_US30_a_2COND.mq5](<../01_EXISTING_EAS/installed/3c842fe329d3_US30_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | P2=BUY | B1=P1 | MAJ_B123 | REV_I1 | REV_B2 | P3 |
| LONDON | B2=BUY | I0=P1 | MAJ_I123 | P2 | REV_P2 | MAJ_P123 |
| NY | I2=BUY | P3=BUY | I2 | REV_B2 | REV_B3 | REV_I3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "US30.a" | US30.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100014 | 26100014 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |
| UseRiskSizing | true | true |
| SheetRiskAmount | 600.0 | 600.0 |
| UseStopLoss | true | true |
| SL_Multiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |

Preset: [US30_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\US30_a_2COND.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\Quant30Auto_US30_a_2COND_269e748c0b\0fca045c4bb54fc39162c788962aeb7b\full\report.htm>). Range 2022-01-01 → 2026-10-06; 3661 trades; PF 1.16; native relative equity DD 8.41%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### US500_a_2COND

- Family: Q30 risk-sized decision tree
- Symbol: "US500.a"; internal timeframe: M30 session data
- Source: [US500_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\US500_a_2COND.mq5>)
- Source SHA-256: `e654496806db7711cf1c320875c1ffb8fbef040ee14b08f2216a3c5a5429b09c`
- Binary SHA-256: `e1408655c9a387baa0659b708d68a5cd28310af8bfad5e5d14c86bc8b8c879e5`
- Frozen source: [e654496806db_US500_a_2COND.mq5](<../01_EXISTING_EAS/installed/e654496806db_US500_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=B3 | P1=P2 | REV_I1 | REV_I3 | B1 | REV_B1 |
| LONDON | P1=BUY | P2=BUY | B2 | REV_B3 | REV_I1 | REV_B1 |
| NY | B2=P2 | I1=I2 | BUY | REV_I1 | REV_B2 | I1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "US500.a" | US500.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100004 | 26100004 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |
| UseRiskSizing | true | true |
| SheetRiskAmount | 600.0 | 600.0 |
| UseStopLoss | true | true |
| SL_Multiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |

Preset: [US500_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\US500_a_2COND.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\Quant30Auto_US500_a_2COND_ff0eef3099\6cc55e0d967c470b9194ab5a8d463fd9\full\report.htm>). Range 2022-01-01 → 2026-10-06; 3605 trades; PF 1.15; native relative equity DD 8.07%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### USDCAD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "USDCAD.a"; internal timeframe: M30 session data
- Source: [USDCAD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\USDCAD_a_2COND.mq5>)
- Source SHA-256: `740dc15a841f71eb36c882ddda45de16b442e5aaf59284a28346c2bb805cd57a`
- Binary SHA-256: `e87ff46e9406f51f5f96febb144ee54d5188ba81adaa09140da24a856882e99f`
- Frozen source: [740dc15a841f_USDCAD_a_2COND.mq5](<../01_EXISTING_EAS/installed/740dc15a841f_USDCAD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=I1 | B2=I2 | REV_B3 | P1 | MAJ_B123 | B3 |
| LONDON | I3=BUY | I1=P1 | REV_I0 | B3 | REV_B1 | REV_I1 |
| NY | B1=I1 | I2=I3 | REV_B2 | I2 | SELL | P2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "USDCAD.a" | USDCAD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100006 | 26100006 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [USDCAD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\USDCAD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### USDCHF_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "USDCHF.a"; internal timeframe: M30 session data
- Source: [USDCHF_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\USDCHF_a_2COND.mq5>)
- Source SHA-256: `91b8be1cd401b69697d3e24b49261eb0ded4c8f01a413d269bc42213a3c3418c`
- Binary SHA-256: `8cabe89d0c5030a7fbf9f30949b1077bf16458ed0501eefd48bc7ef63fb1a1d1`
- Frozen source: [91b8be1cd401_USDCHF_a_2COND.mq5](<../01_EXISTING_EAS/installed/91b8be1cd401_USDCHF_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=B3 | I2=I3 | REV_B2 | REV_P1 | REV_P2 | MAJ_P123 |
| LONDON | I2=I3 | P2=P3 | B3 | I2 | B2 | P1 |
| NY | P2=BUY | P3=BUY | REV_B2 | REV_I1 | P2 | B3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "USDCHF.a" | USDCHF.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100007 | 26100007 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [USDCHF_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\USDCHF_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### USDJPY 3EA

- Family: Q30 USDJPY risk sizing
- Symbol: "USDJPY.a"; internal timeframe: M30 session data
- Source: [USDJPY 3EA.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\USDJPY 3EA.mq5>)
- Source SHA-256: `bf105b4572a373c9019e7f88fdbb925c25b18085ba774828e0b24732613579c7`
- Binary SHA-256: `a2baac65aa14a2eca7f271a00b3c3f566d51b3d14288a4c97677b6923b8e37bd`
- Frozen source: [bf105b4572a3_USDJPY 3EA.mq5](<../01_EXISTING_EAS/installed/bf105b4572a3_USDJPY 3EA.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=BUY | I1=P1 | REV_P3 | B1 | REV_B3 | REV_I3 |
| LONDON | B2=I2 | I2=I3 | P3 | REV_P3 | REV_P1 | B1 |
| NY | B1=B2 | B2=B3 | P3 | MAJ_I123 | REV_P2 | I3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "USDJPY.a" | USDJPY.a |
| InpLots | 0.10 | 1 |
| InpMagic | 26100008 | 26100008 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |
| SheetRiskAmount | 600.0 | 600 |
| UseStopLoss | true | true |
| SL_Multiplier | 1.0 | 1.0 |
| LookbackSessions | 144 | 144 |
| SheetPipsPerPriceUnit | 100.0 | 100.0 |

Preset: [USDJPY 3EA.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\USDJPY 3EA.set>)

Latest visible Full report: [report.htm](<C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\reports\Quant30Auto_USDJPY_3EA_016d31d8c1\7d4a29a500b14054ad8f608132c8b9a9\full\report.htm>). Range 2022-01-01 → 2026-10-05; 2934 trades; PF 1.15; native relative equity DD 10.47%; recorded binary matches current: True. This is retrospective evidence; holdout not established.

### XAGAUD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XAGAUD.a"; internal timeframe: M30 session data
- Source: [XAGAUD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XAGAUD_a_2COND.mq5>)
- Source SHA-256: `c94182b314ed42e1d031959f0429ef6a0daccd5066eb2498ebb457d0a191e35a`
- Binary SHA-256: `21ee6750fad554059e3963eb654cf6bc542eb39868c86bce2209f923dc82c289`
- Frozen source: [c94182b314ed_XAGAUD_a_2COND.mq5](<../01_EXISTING_EAS/installed/c94182b314ed_XAGAUD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B2=I2 | P1=P2 | B1 | REV_I1 | REV_B3 | REV_B1 |
| LONDON | B1=P1 | B3=I3 | SELL | BUY | REV_P2 | B3 |
| NY | B1=BUY | P3=BUY | I3 | REV_I3 | P2 | I1 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XAGAUD.a" | XAGAUD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100027 | 26100027 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XAGAUD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XAGAUD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### XAGUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XAGUSD.a"; internal timeframe: M30 session data
- Source: [XAGUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XAGUSD_a_2COND.mq5>)
- Source SHA-256: `deed598d897934617fbfdda03f589d7f175cdf482f86f9ad965db5be08794c1b`
- Binary SHA-256: `c0489a0d6c934d6457ec37ba8a46dc3546be3fd6d6b2cbf96c9b8acf90ea96a4`
- Frozen source: [deed598d8979_XAGUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/deed598d8979_XAGUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=I1 | B1=P1 | REV_B2 | P3 | B1 | MAJ_B123 |
| LONDON | B1=P1 | B2=P2 | P3 | REV_B2 | I3 | REV_I1 |
| NY | I2=P2 | I1=I2 | REV_I3 | I3 | REV_B1 | REV_I3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XAGUSD.a" | XAGUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100025 | 26100025 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XAGUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XAGUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### XAUAUD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XAUAUD.a"; internal timeframe: M30 session data
- Source: [XAUAUD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XAUAUD_a_2COND.mq5>)
- Source SHA-256: `3389ddd9db6acafc5fb2ee75b8bedfc44f49dcf118ff73b6d129db0f87a9395e`
- Binary SHA-256: `dba047bf75923017e909048ae4e48897dfc127762875157b605c89af058b92cb`
- Frozen source: [3389ddd9db6a_XAUAUD_a_2COND.mq5](<../01_EXISTING_EAS/installed/3389ddd9db6a_XAUAUD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | B1=P1 | B3=P3 | REV_B3 | MAJ_I123 | REV_P2 | I3 |
| LONDON | I3=BUY | P2=BUY | P3 | REV_B3 | REV_I1 | MAJ_B123 |
| NY | P2=BUY | B2=I2 | REV_B1 | B2 | MAJ_B123 | B2 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XAUAUD.a" | XAUAUD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100026 | 26100026 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XAUAUD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XAUAUD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### XAUUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XAUUSD.a"; internal timeframe: M30 session data
- Source: [XAUUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XAUUSD_a_2COND.mq5>)
- Source SHA-256: `532a65e94197b22ebb03046aca5135bc05ddf8c3b42f7aa6a884246cc5fdf151`
- Binary SHA-256: `0729bd754ba57289a8c03226a4d9f3feef131fac44ab73680dcc3ecbb60066d7`
- Frozen source: [532a65e94197_XAUUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/532a65e94197_XAUUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I2=BUY | B1=P1 | REV_B3 | REV_I1 | REV_P3 | REV_I1 |
| LONDON | B3=BUY | P1=P2 | B3 | I0 | I3 | REV_B1 |
| NY | I1=BUY | B1=B2 | I2 | I3 | MAJ_I123 | REV_I3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XAUUSD.a" | XAUUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100002 | 26100002 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XAUUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XAUUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### XPDUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XPDUSD.a"; internal timeframe: M30 session data
- Source: [XPDUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XPDUSD_a_2COND.mq5>)
- Source SHA-256: `8be1834ca63f0355c2a79c82ac8f3979b16b49e13d6a2b7f88f2290280441d5c`
- Binary SHA-256: `3045d97e8bd868c8c1ab2553c63be86b42e54bd6fbb5082e21589cccb07df06f`
- Frozen source: [8be1834ca63f_XPDUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/8be1834ca63f_XPDUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I2=P2 | I2=I3 | BUY | BUY | REV_P1 | BUY |
| LONDON | I2=BUY | I3=P3 | REV_I2 | P1 | MAJ_P123 | REV_B3 |
| NY | I1=BUY | P2=P3 | I2 | B2 | REV_I3 | MAJ_B123 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XPDUSD.a" | XPDUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100029 | 26100029 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XPDUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XPDUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

### XPTUSD_a_2COND

- Family: Q30 fixed-lot decision tree
- Symbol: "XPTUSD.a"; internal timeframe: M30 session data
- Source: [XPTUSD_a_2COND.mq5](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Quant30Auto\XPTUSD_a_2COND.mq5>)
- Source SHA-256: `2bf79e8475f46152b094c5fcfc922337124892b67b4c1cff3101994a3a8c2b5c`
- Binary SHA-256: `3bee58be971aa425ca379d019bb8dff771828fed774b08f85242f46621f1df33`
- Frozen source: [2bf79e8475f4_XPTUSD_a_2COND.mq5](<../01_EXISTING_EAS/installed/2bf79e8475f4_XPTUSD_a_2COND.mq5>)
- Build correspondence: unverified.

| Session | C1 | C2 | A0 (TT) | A1 (TF) | A2 (FT) | A3 (FF) |
| --- | --- | --- | --- | --- | --- | --- |
| ASIA | I1=P1 | B2=B3 | BUY | REV_I3 | I2 | B1 |
| LONDON | I3=BUY | P1=P2 | P1 | REV_I3 | B1 | REV_B2 |
| NY | I1=BUY | I2=I3 | P2 | REV_P2 | REV_B2 | REV_B3 |

| Input | Source default | Current preset |
| --- | --- | --- |
| InpSymbol | "XPTUSD.a" | XPTUSD.a |
| InpLots | 0.10 | 0.1 |
| InpMagic | 26100028 | 26100028 |
| InpTradeAsia | true | true |
| InpTradeLondon | true | true |
| InpTradeNY | true | true |

Preset: [XPTUSD_a_2COND.set](<C:\Users\heroa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Profiles\Tester\XPTUSD_a_2COND.set>)

No visible saved Full dashboard result for this installed EA. Original-batch reports, if present, remain historical evidence for the original version only.

## Original 30 mapping

| Original source | Current installed name | Identical source | Original Full history quality % |
| --- | --- | --- | --- |
| AUDUSD_a_2COND.mq5 | AUDUSD_a_2COND | True | 36.0 |
| AUS200_a_2COND.mq5 | AUS200_a_2COND | True | 36.0 |
| BTCAUD_a_2COND.mq5 | BTCAUD_a_2COND | True | 36.0 |
| BTCEUR_a_2COND.mq5 | BTCEUR_a_2COND | True | 36.0 |
| BTCGBP_a_2COND.mq5 | BTCGBP_a_2COND | True | 36.0 |
| BTCUSD_a_2COND.mq5 | BTCUSD_a_2COND | False | 36.0 |
| Copper_a_2COND.mq5 | Copper_a_2COND | True | 36.0 |
| ETHAUD_a_2COND.mq5 | ETHAUD_a_2COND | True | 36.0 |
| ETHEUR_a_2COND.mq5 | ETHEUR_a_2COND | True | 36.0 |
| ETHGBP_a_2COND.mq5 | ETHGBP_a_2COND | True | 36.0 |
| ETHUSD_a_2COND.mq5 | ETHUSD_a_2COND | True | 36.0 |
| EURUSD_a_2COND.mq5 | EURUSD_a_2COND | True | 36.0 |
| EUSTX50_a_2COND.mq5 | EUSTX50_a_2COND | True | 36.0 |
| FRA40_a_2COND.mq5 | FRA40_a_2COND | True | 36.0 |
| GBPUSD_a_2COND.mq5 | GBPUSD_a_2COND | True | 36.0 |
| GER40_a_2COND.mq5 | GER40_a_2COND | True | 36.0 |
| JPN225_a_2COND.mq5 | JPN225_a_2COND | True | 36.0 |
| LTCUSD_a_2COND.mq5 | LTCUSD_a_2COND | True | 36.0 |
| UK100_a_2COND.mq5 | UK100_a_2COND | True | 36.0 |
| US30_a_2COND.mq5 | US30_a_2COND | False | 36.0 |
| US500_a_2COND.mq5 | US500_a_2COND | False | 36.0 |
| USDCAD_a_2COND.mq5 | USDCAD_a_2COND | True | 36.0 |
| USDCHF_a_2COND.mq5 | USDCHF_a_2COND | True | 36.0 |
| USDJPY_a_2COND.mq5 | USDJPY 3EA | False | 36.0 |
| XAGAUD_a_2COND.mq5 | XAGAUD_a_2COND | True | 36.0 |
| XAGUSD_a_2COND.mq5 | XAGUSD_a_2COND | True | 36.0 |
| XAUAUD_a_2COND.mq5 | XAUAUD_a_2COND | True | 36.0 |
| XAUUSD_a_2COND.mq5 | XAUUSD_a_2COND | True | 100.0 |
| XPDUSD_a_2COND.mq5 | XPDUSD_a_2COND | True | 36.0 |
| XPTUSD_a_2COND.mq5 | XPTUSD_a_2COND | True | 36.0 |

## Other historical sources and binary-only material

| Source | SHA-256 prefix | Lines | Classification |
| --- | --- | --- | --- |
| C:\PCBot\NewBot\Quant30EAs\AUDUSD_a_2COND.mq5 | c1d351b99a73aa2f | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\AUS200_a_2COND.mq5 | c06d94a5e4ae4690 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\BTCAUD_a_2COND.mq5 | cd329872ec88baa9 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\BTCEUR_a_2COND.mq5 | 746a8d28ef538757 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\BTCGBP_a_2COND.mq5 | 516441c8348223ac | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\BTCUSD_a_2COND.mq5 | 8ddc1fa87bcf90d8 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\Copper_a_2COND.mq5 | 89186382a62a5559 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\ETHAUD_a_2COND.mq5 | 3b395ee203a57487 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\ETHEUR_a_2COND.mq5 | bf7895b80022174b | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\ETHGBP_a_2COND.mq5 | a88407ab1bcdac38 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\ETHUSD_a_2COND.mq5 | 44531521a241156c | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\EURUSD_a_2COND.mq5 | 857b17f8652c8fd8 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\EUSTX50_a_2COND.mq5 | 5d286b2ad316919b | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\FRA40_a_2COND.mq5 | 54871022dd113766 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\GBPUSD_a_2COND.mq5 | 1448da8d58669da0 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\GER40_a_2COND.mq5 | 5bcaac17c9252c3e | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\JPN225_a_2COND.mq5 | 58cecd24ab5c2fa7 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\LTCUSD_a_2COND.mq5 | 61bf19383f6135d6 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\UK100_a_2COND.mq5 | 5531f569bb63f1b6 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\US30_a_2COND.mq5 | c5f6264f64514538 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\US500_a_2COND.mq5 | ead2361c1952a3af | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\USDCAD_a_2COND.mq5 | 740dc15a841f71eb | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\USDCHF_a_2COND.mq5 | 91b8be1cd401b696 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\USDJPY_a_2COND.mq5 | 927c00d8406b02de | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XAGAUD_a_2COND.mq5 | c94182b314ed42e1 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XAGUSD_a_2COND.mq5 | deed598d89793461 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XAUAUD_a_2COND.mq5 | 3389ddd9db6acafc | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XAUUSD_a_2COND.mq5 | 532a65e94197b22e | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XPDUSD_a_2COND.mq5 | 8be1834ca63f0355 | 306 | Original batch |
| C:\PCBot\NewBot\Quant30EAs\XPTUSD_a_2COND.mq5 | 2bf79e8475f46152 | 306 | Original batch |
| C:\Users\heroa\Downloads\Trading\EAs and Indicators\SchedTradeEA_ORIGINAL_v1.mq5 | a943565dfd0f2b5c | 576 | Legacy scheduled trading / source backup; not current baseline |
| C:\Users\heroa\Downloads\Trading\EAs and Indicators\ScheduledTradeEA.mq5 | bbd4b30681b4589c | 377 | Legacy scheduled trading / source backup; not current baseline |
| C:\Users\heroa\Downloads\Trading\Eurusd 3 session\ScheduledTradeEA (1).mq5 | 7155276d2637bf86 | 1018 | Legacy scheduled trading / source backup; not current baseline |
| C:\Users\heroa\Downloads\Trading\Eurusd 3 session\ScheduledTradeEA_NoStopOrder.mq5 | fe5c396aac74da57 | 811 | Legacy scheduled trading / source backup; not current baseline |
| C:\Users\heroa\Downloads\Trading\Xauusd 3 session\ScheduledTradeEA_XAUUSD (2).mq5 | db1e68a041808d70 | 1232 | Legacy scheduled trading / source backup; not current baseline |
| C:\Users\heroa\Downloads\Session2_ExactRules_Backtest_EA (1).mq5 | bfb02215e49e41d8 | 1980 | Embedded spreadsheet reconciliation harness |
| C:\Users\heroa\Downloads\Session2_ExactRules_Backtest_EA.mq5 | bfb02215e49e41d8 | 1980 | Embedded spreadsheet reconciliation harness |
| C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\ea_backups\USDJPY_a_2COND_current_20261004_143605.mq5 | 292a724d6ad0840f | 737 | Legacy scheduled trading / source backup; not current baseline |

PhantomGrid_v1_4.ex5 under Trading/EAs and Indicators is binary-only. Its trading logic is unknown and it is excluded from source-based conclusions. No decompilation was attempted.
