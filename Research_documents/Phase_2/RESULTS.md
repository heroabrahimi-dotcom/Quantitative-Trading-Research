# Astra Phase 2 research results — 2026-10-10

Native tests completed: **14**. Failed/incomplete records: **0**. Five deterministic sizing fixtures passed; USDJPY candidate compiled with zero errors and warnings. These are research simulations, not live trades or deployment approval.

## Phase 1 — USDJPY repair

EXP001_v1 changes only the sizing sample traversal to unique prior calendar dates with completed sessions. The original signal lookup remains unchanged. Source and EX5 are preserved under 06_CANDIDATE_EAS/EXP001_v1; parent hashes and a unified diff are included. The candidate uses the report-derived preset from the same baseline. Source-equivalent fixtures cover weekdays, holidays, 143/144 available observations and empty history; they are not native MQL unit execution.

The corrected full-period run takes more trades because the original day-dependent sample failure disappears. Total profit alone is not an acceptance gate: compare PF, absolute and relative drawdown, and later-year results below. The candidate is a semantic repair, not a validated economic improvement.

Native entry journals show all 2,934 parent entries in the candidate at the same session/time/direction, plus 755 additional entries. All shared entries have a changed sizing average; the median candidate/parent lot ratio is 0.8986. The repaired candidate has lower PF and higher maximum dollar equity drawdown despite greater Full-period profit. Its combined 2025–2026 profit is lower than the parent. See sizing_comparison.json and the reproducible comparison tool.

## Native test results

Amounts are USD, initial deposit 100,000 and leverage 1:100. M30, Model 4, existing Pepperstone sessions. Dates match each saved report endpoint rather than silently extending to today. Stress labels indicate requested fixed execution delay in milliseconds. DD% is native relative equity drawdown; Max DD is native maximum dollar equity drawdown. These two maxima need not occur at the same time.

| Run | Start → end | Delay | Trades | Net USD | PF | DD % | Max DD USD | Native quality label |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| nas100_baseline | 2022-01-01 → 2026-10-05 | 5 | 3665.0 | 79753.72 | 1.15 | 6.7 | 9493.55 | 100% real ticks |
| nas100_delay100 | 2022-01-01 → 2026-10-05 | 100 | 3665.0 | 79757.68 | 1.15 | 6.7 | 9493.55 | 100% real ticks |
| nas100_delay250 | 2022-01-01 → 2026-10-05 | 250 | 3665.0 | 79712.39 | 1.15 | 6.7 | 9498.76 | 100% real ticks |
| nas100_development | 2022-01-01 → 2024-01-01 | 5 | 1541.0 | 29891.12 | 1.14 | 6.38 | 7210.66 | 100% real ticks |
| nas100_retrospective | 2025-01-01 → 2026-10-05 | 5 | 1353.0 | 43617.0 | 1.23 | 6.66 | 7560.63 | 100% real ticks |
| nas100_validation | 2024-01-01 → 2025-01-01 | 5 | 771.0 | 6245.6 | 1.05 | 8.49 | 9493.55 | 100% real ticks |
| us500_baseline | 2022-01-01 → 2026-10-06 | 5 | 3605.0 | 79313.29 | 1.15 | 8.07 | 11437.1 | 36% real ticks |
| us500_delay100 | 2022-01-01 → 2026-10-06 | 100 | 3605.0 | 79313.29 | 1.15 | 8.07 | 11437.1 | 36% real ticks |
| us500_delay250 | 2022-01-01 → 2026-10-06 | 250 | 3605.0 | 79345.18 | 1.15 | 8.07 | 11437.61 | 36% real ticks |
| us500_development | 2022-01-01 → 2024-01-01 | 5 | 1522.0 | 33922.53 | 1.16 | 8.07 | 8104.43 | 0% real ticks |
| us500_retrospective | 2025-01-01 → 2026-10-06 | 5 | 1344.0 | 29661.73 | 1.15 | 9.66 | 10924.07 | 99% real ticks |
| us500_validation | 2024-01-01 → 2025-01-01 | 5 | 739.0 | 15913.53 | 1.14 | 9.26 | 11437.1 | 0% real ticks |
| usdjpy_baseline | 2022-01-01 → 2026-10-05 | 5 | 2934.0 | 69668.9 | 1.15 | 10.47 | 12814.49 | 100% real ticks |
| usdjpy_EXP001 | 2022-01-01 → 2026-10-05 | 5 | 3689.0 | 74210.75 | 1.14 | 9.82 | 13906.53 | 100% real ticks |


## Phase 2 — baseline reproduction discrepancies

A reproduction is not called exact merely because rounded PF or drawdown matches. Matched trade fields and financing differences are retained in assessment.json. Current broker swap application is not a frozen historical swap schedule.

### nas100_baseline

Old net 79752.94; new net 79753.72; difference +0.78 USD. Old/new closed-deal counts: 3665/3665.

| Field | Changed paired records |
| --- | --- |
| open_time | 0 |
| close_time | 0 |
| side | 0 |
| volume | 0 |
| entry_price | 0 |
| exit_price | 0 |
| profit | 0 |
| commission | 0 |
| swap | 46 |
| fee | 0 |
| net | 46 |

Pairing is by native closed-deal sequence. Identical timestamps/sides/volumes/prices support the comparison; nonzero differences require inspection, not a presumption of equivalence. Swap differences are saved individually.

### us500_baseline

Old net 79316.28; new net 79313.29; difference -2.99 USD. Old/new closed-deal counts: 3605/3605.

| Field | Changed paired records |
| --- | --- |
| open_time | 0 |
| close_time | 0 |
| side | 0 |
| volume | 0 |
| entry_price | 0 |
| exit_price | 0 |
| profit | 0 |
| commission | 0 |
| swap | 41 |
| fee | 0 |
| net | 41 |

Pairing is by native closed-deal sequence. Identical timestamps/sides/volumes/prices support the comparison; nonzero differences require inspection, not a presumption of equivalence. Swap differences are saved individually.

### usdjpy_baseline

Old net 69517.48; new net 69668.90; difference +151.42 USD. Old/new closed-deal counts: 2934/2934.

| Field | Changed paired records |
| --- | --- |
| open_time | 0 |
| close_time | 0 |
| side | 0 |
| volume | 0 |
| entry_price | 0 |
| exit_price | 0 |
| profit | 0 |
| commission | 0 |
| swap | 4 |
| fee | 0 |
| net | 4 |

Pairing is by native closed-deal sequence. Identical timestamps/sides/volumes/prices support the comparison; nonzero differences require inspection, not a presumption of equivalence. Swap differences are saved individually.

## Reported native charges

Totals below use every native buy/sell deal, including opening charges, independently of incomplete entry-link coverage. Spreads are embedded in fill prices and are not a separate cash debit in this table. Broker historical spreads are only as reliable as the tick/bar source; generated-tick fallback and current financing defaults limit realism.

| Run | Commission | Swap | Fee | Unlinked closed deals |
| --- | --- | --- | --- | --- |
| nas100_baseline | 0.0 | -151.33 | 0.0 | 396 |
| nas100_delay100 | 0.0 | -151.33 | 0.0 | 396 |
| nas100_delay250 | 0.0 | -151.33 | 0.0 | 396 |
| nas100_development | 0.0 | -43.38 | 0.0 | 128 |
| nas100_retrospective | 0.0 | -67.08 | 0.0 | 109 |
| nas100_validation | 0.0 | -40.87 | 0.0 | 26 |
| us500_baseline | 0.0 | -504.77 | 0.0 | 317 |
| us500_delay100 | 0.0 | -504.77 | 0.0 | 317 |
| us500_delay250 | 0.0 | -504.77 | 0.0 | 317 |
| us500_development | 0.0 | -129.81 | 0.0 | 45 |
| us500_retrospective | 0.0 | -255.79 | 0.0 | 124 |
| us500_validation | 0.0 | -123.95 | 0.0 | 58 |
| usdjpy_baseline | -33519.5 | 0.0 | 0.0 | 400 |
| usdjpy_EXP001 | -34560.98 | 0.0 | 0.0 | 403 |


## Phase 3 — chronological stability

2022–2023 is development, 2024 validation, and 2025–each original endpoint retrospective evaluation. These dates have already been exposed through reports/research. No untouched historical holdout is claimed. Separate native fold tests reset the EA at each boundary; they may differ from attribution of continuous Full-run trades because of boundary closure and state. Yearly cash-flow results below come from the continuous baseline/candidate runs.

| Run | 2022 | 2023 | 2024 | 2025 | 2026 partial |
| --- | --- | --- | --- | --- | --- |
| nas100_baseline | 17431.53 | 12459.59 | 6245.6 | 17270.64 | 26346.36 |
| us500_baseline | 22347.16 | 11575.37 | 15442.01 | 10778.56 | 19170.19 |
| usdjpy_baseline | 27019.6 | 5971.82 | 3561.56 | 16394.1 | 16721.82 |
| usdjpy_EXP001 | 29938.29 | 6226.5 | 12729.22 | 11602.53 | 13714.21 |


The 100/250 ms tests are native execution-delay stresses, not calibrated forecasts of live slippage. No independent spread-widening or historical swap reconstruction has been completed. Full-report balance curves and native maximum equity drawdown are available; continuous tick-level equity was not exported, so portfolio equity drawdown has not been validated.

## History-quality finding

The original 29 reports literally say **36% real ticks**. The old native journal records real-tick history beginning in January 2025 for all 29 affected symbols, with additional missing/discarded-minute fallback. XAUUSD has earlier real-price history. This explains the common low real-tick share; it does not mean 64% of all bars were proven invalid. See CHRONOLOGY_AND_DATA.md and history_quality_evidence.json.

New reports can print 100% real ticks while their own journals still identify a 2025 real-tick start and generated-tick fallback. Both are preserved. Until the discrepancy is explained with independently verified tick provenance, do not advertise the Full run as entirely real-tick history.

## Phase 4 — controlled strategy research

Six controlled hypotheses are preregistered in PHASE4_RESEARCH_DESIGNS.md: aggregate risk caps, session ablation, lagged regime filters, robust volatility sizing, confirmed-fill retry behavior, and holiday/rollover exit control. Economic candidate searches remain gated by the unresolved cost/data baseline. This avoids attributing broker-history changes to a strategy improvement. The USDJPY correctness candidate was implemented and tested separately.

## Failures, limitations and next experiment

Initial tooling failures: the bundled analysis Python lacked pywin32, so the installed dashboard Python was used; the restricted compile could not create a hidden desktop, then succeeded through the authorized tool permission path. A whole-file read of the 5.8 GB historical journal was stopped and replaced by a bounded-memory scan. These are operational failures, not rejected trading hypotheses.

An assessment-helper naming collision was corrected before final verification; it did not alter native reports or trading inputs.


The recommended next experiment is a **cost-and-history reconciliation run**, not another profit search: freeze symbol financing specifications, replay the identified holiday exits, and reconcile the January-2025 real-tick boundary against the report quality label. Then compare the corrected USDJPY and original on the same verified 2025+ data/cost basis, keeping that sample explicitly retrospective. Freeze a prospective candidate and acceptance criteria before collecting any genuinely new holdout. No forward trading or promotion is activated.

## Evidence and integrity

Each runs/ folder contains the requested settings, environment assumptions, unmodified native report, native journal, initial analytics and journal-enriched analytics. Some stop exits cannot be uniquely linked by the existing parser; their entry-based metrics remain unavailable. Headline and yearly cash-flow metrics reconcile independently. The dashboard parser, production EAs and presets were not modified. Source/binary/preset integrity checks and manually open terminal checks are recorded separately.
