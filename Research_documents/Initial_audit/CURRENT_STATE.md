# Astra research state — 2026-10-09

## Initial audit completed; strategy validation remains open

Read ASTRA_START_HERE.md and AGENT_RULES.md. Located the existing work outside the initially empty research EA folder, preserved versioned source/binary/settings copies, and created a catalog plus baseline protocol. No EA source, production preset, dashboard implementation or original report was changed. No MT5 performance run or live trading action was taken during this audit.

### Verified inventory

- 32 installed EAs: 26 common fixed-lot Q30 engines, three Q30 risk variants, USDJPY 3EA, GOLD 3ea and NAS100 3ea. All have source and a matching-name preset.
- Original batch of 30 source EAs under C:/PCBot/NewBot/Quant30EAs. 26 remain identical; BTCUSD/US30/US500 differ; USDJPY has a different current variant. Archive mapping is explicit.
- 38 historical source files plus 32 installed source files represent 43 distinct source hashes. Snapshot count is not a count of independent strategies. A separate PhantomGrid binary has unknown logic.
- 165 reports inventoried; 114 saved dashboard results in 35 manifests. All 114 saved report hashes match, and 95 saved EA hashes match current binaries. Compile/launch provenance is not established by these hashes alone.
- 17 market CSVs checked within the permitted date range, three Trading OHLC databases checked read-only, broker caches inventoried. Two 100-symbol workbooks located (32 sheets each). Workbook formulas and rule-search chronology remain unvalidated.

### Most important findings

1. Confirmed USDJPY sizing defect: 144 sampled observations can contain only 14 unique dates. A synthetic fixture and source hash are preserved. Repair in a new candidate is the first controlled experiment.
2. 29 of the 30 original Full reports show 36% history quality; XAUUSD shows 100%. Reproduce with documented coverage before treating the batch ranking as reliable.
3. NAS100 and US500 have positive results in each saved year and warrant replication first. This is retrospective prioritization, not a validated winner. GOLD has negative 2023/2024 and materially higher reported drawdown; current options disable stops and add exposure.
4. No untouched holdout is established. Existing rule-search spreadsheets, overlapping rolling reports and embedded reconciliation harnesses are not independent OOS evidence.
5. Legacy scheduled-trade sources can close positions without symbol/magic filtering; keep them archival and isolated. The current research does not run those tools.

### Read next

1. [EA catalog](EA_CATALOG.md) and [registry](ea_registry.csv).
2. [Source findings](SOURCE_AUDIT.md).
3. [Historical results assessment](../04_BACKTEST_RESULTS/ASSESSMENT.md).
4. [Data coverage audit](../03_MARKET_DATA/DATA_AUDIT.md).
5. [Baseline and chronological validation protocol](../05_VALIDATION/BASELINE_PROTOCOL.md).
6. [Session handoff](../08_LOGS/SESSION_HANDOFF_20261009.md).

### Not yet completed

Fresh broker-quality baseline runs, source/binary compile attestation, full spreadsheet formula/selection audit, true OOS validation, equity-path portfolio analysis, and candidate implementation. Those remain explicit research work; no strategy is approved for promotion.
