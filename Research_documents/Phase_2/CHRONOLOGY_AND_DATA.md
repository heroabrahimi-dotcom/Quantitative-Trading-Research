# Chronology and historical-data findings — 2026-10-10

## Holdout exposure audit

The existing 2022–2026 Full reports and their yearly breakdowns were already available and inspected before candidate design. Earlier HQ100_Probe code explicitly tested starts 2023/2024/2025/2026 with an end of 2026-10-01. Original rule-selection chronology remains unknown: build_quant30.py is empty, and the batch README identifies an already-completed spreadsheet search. Therefore none of 2022–2026 can be certified as an untouched holdout for the existing strategies. Existing 'in/out' labels do not resolve that provenance gap.

Chronological research roles are fixed as 2022–2023 development, 2024 validation, and 2025 through each original report endpoint retrospective evaluation. Separate native runs reset the EA at each boundary; yearly attribution from Full runs is also retained. These are stability diagnostics, not new independent evidence. A genuinely prospective holdout can start only after freezing the candidate, costs and risk criteria; no forward trading has been activated.

## Why the original reports say 36%

The literal native field is '36% real ticks'. The 2026-10-01 tester journal identifies real tick availability beginning 2025-01-02 for affected weekday instruments and 2025-01-01 for crypto. XAUUSD is the exception with earlier real-price history available for warm-up and the full permitted test. All 29 original non-XAUUSD symbols appear in the journal evidence. Earlier portions of the 2022–2026 tests consequently lack the same real-tick basis. Additional minute-level absent/discarded ticks are explicitly recorded. This explains the common low real-tick share; it is not a diagnosis that 64% of all OHLC bars are invalid.

MT5's [tick-generation documentation](https://www.metatrader5.com/en/terminal/help/algotrading/tick_generation) describes generated ticks when recorded tick data is unavailable. The [tester-journal documentation](https://www.metatrader5.com/en/terminal/help/algotrading/tester_journal) describes checks against minute bars and quality diagnostics. Evidence is preserved in history_quality_evidence.json, scanned with bounded memory from the original 5.8 GB journal; no original logs were changed.

## New-report caution

The new USDJPY report prints '100% real ticks', yet the same run's native journals say real ticks begin in 2025 and explicitly record generated-tick fallback for absent/discarded minutes. Preserve both observations. The headline alone cannot establish that 2022–2024 execution used genuine recorded ticks. This discrepancy remains a data-provenance limitation and prevents calling the Full run a certified all-real-tick baseline.

## Financing discrepancy

USDJPY reproduction matches 2,934 trade exit times, sides, volumes, prices, gross profits and commissions. Net is 151.42 USD higher. Four old swap adjustments (-40.27, +8.85, -66.37, -53.63 USD, at holiday-delayed exits) are now zero. Their sum is -151.42 USD, exactly explaining the net discrepancy. This identifies the accounting source, not the broker's underlying reason for changing applied swap settings. Exact historical financing specifications have not been frozen; current broker defaults must not be advertised as historical-cost reconstruction.

## Tick-cache cross-check

Both the production data directory (read-only inspection) and dedicated tester cache lack all 36 monthly .tkc files for 2022–2024 for USDJPY.a, NAS100.a and US500.a. Their continuous monthly caches begin in 2025; USDJPY/NAS100 also have a separate 202110 file. File presence alone does not certify quality, but this supports the journal evidence that the earlier Full-period segment lacks equivalent real-tick coverage. Exact filenames, sizes and modification times are in tick_cache_evidence.json.

## Testable explanation for the new quality-label discrepancy

USDJPY and NAS100 have an isolated October-2021 tick-cache file followed by January-2025 onward files; US500 has only January-2025 onward files. In this session USDJPY/NAS100 report 100%, while US500 still reports 36%. This is a correlation, not proof of how MT5 calculates the label. A controlled follow-up should create two fresh dedicated research runtimes with identical inputs and caches, differing only in inclusion of that isolated warm-up tick file. Preserve both copies; never alter production caches or delete evidence. Compare label, journal coverage, trades and costs. Do not try to improve a reported quality number by manipulating caches.
