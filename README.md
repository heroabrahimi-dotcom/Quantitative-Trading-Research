# Your Quant Trading Research — three-EA research package

Prepared: **18 October 2026 (Australia/Perth)**.
Research results summarized here were recorded on **9–10 October 2026**. Dashboard findings were recorded on **12 October**. This package does not contain new October 18 backtests.

## Start here

This folder contains the three EAs in your current **provisional research shortlist**:

1. **NAS100 3ea** — NAS100.a
2. **US500_a_2COND** — US500.a
3. **USDJPY 3EA — original baseline** — USDJPY.a

These are the **frozen baseline copies used in the Phase 2 reproduction work**, not silently substituted current production files. Each EA folder contains:

- `.mq5`: the original frozen MQL5 source.
- `.ex5`: the original frozen compiled EA.
- `report_inputs.set`: the report-derived inputs used for its research baseline. This is a research preset; it is not a claim that every installed production preset is identical.
- `Baseline_evidence/report.htm`: the native reproduced MT5 report.
- `Baseline_evidence/result.json`, `summary.json`, `yearly_stats.json`: recorded results.

`FILE_MANIFEST.json` records the source location and SHA-256 of every copied evidence file. No EA was edited, compiled, installed, launched or deployed when making this package. The USDJPY correction is described in the research documents but its candidate executable is deliberately not substituted for the original you requested.

## What your overall research is trying to establish

Your project began with approximately 30 EAs built from session-direction strategy ideas. The initial audit found **32 installed EAs**: 26 related fixed-lot Q30 engines, three Q30 risk variants, USDJPY 3EA, GOLD 3ea and NAS100 3ea. These are related implementations and versions, not 32 proven independent trading edges.

The goal is to learn which rules remain useful across changing conditions, realistic costs and later data. Profit alone is not the selection rule. Your stated priorities include profit factor, drawdown, consistency across years, execution feasibility, sample size and performance on data not used to design the rules.

Your operating rules are: preserve originals; version every candidate; record failed experiments as well as successes; do not trade live or promote candidates automatically; keep a persistent research handoff.

## How the strategy family works

The common Q30 family reads M30 price history and classifies past Asia, London and New York sessions as upward or downward. Conditional rule tables compare prior session directions and choose BUY, SELL, a reversed direction or a majority direction. Session timing uses the existing Pepperstone broker clock and European/US daylight-saving rules. London and New York overlap, so a future London close must never be used as if known at New York's open.

Some original versions use fixed lots. Other variants estimate sizing from historical same-session ranges and a monetary sizing target. A sizing target is not a guaranteed maximum loss: rounding, minimum lots, spread, gaps, stop slippage, missing stops and overlapping positions can change actual exposure.

### NAS100 3ea

NAS100 has its own session rules, including earlier New York directions, an EMA-zone condition, prior London directions, and a London decision that waits for today's Asia close. It uses historical session-range sizing and optional pending-order functionality. The source defaults enable the main stop and disable addon orders; the supplied baseline preset/report are the authority for the tested input values.

It is first in the current research order because the saved yearly results were positive in each year and reported relative drawdown was lower than the other shortlisted baselines. This is a historical research priority, not a guarantee of future performance.

### US500_a_2COND

US500 is a Q30 conditional session-direction variant with range-based sizing, `OrderCalcProfit` and stop-related inputs. It searches a much longer history than the defective USDJPY sizing helper. Its saved yearly results were also positive in each year. Because NAS100 and US500 both have US equity-index exposure, they must not be assumed to diversify each other; combined portfolio risk needs synchronized equity/exposure analysis.

### USDJPY 3EA — original

USDJPY uses related session rules, but the original sizing-history traversal contains a confirmed defect. Its helper searches only 20 calendar days, while the sizing calculation attempts to gather 144 observations. This can repeatedly count a boundary date or fail to collect enough observations. In an isolated audit fixture, 144 observations came from only 14 distinct dates, one date repeated 131 times.

**This packaged original retains that defect.** It is preserved for reproducible comparison, not represented as repaired or ready for deployment.

## The reproduced baseline numbers

All three rows below use USD 100,000 initial capital, 1:100 leverage, M30, model 4 and a requested 5 ms execution delay. The start date is 2022-01-01. Amounts are USD. DD% is native relative equity drawdown; maximum dollar DD is a separate native statistic and may peak at a different time.

| EA | End date | Trades | Net profit | Profit factor | Relative equity DD | Max equity DD |
|---|---|---:|---:|---:|---:|---:|
| NAS100 3ea | 2026-10-05 | 3,665 | 79,753.72 | 1.15 | 6.70% | 9,493.55 |
| US500_a_2COND | 2026-10-06 | 3,605 | 79,313.29 | 1.15 | 8.07% | 11,437.10 |
| USDJPY 3EA original | 2026-10-05 | 2,934 | 69,668.90 | 1.15 | 10.47% | 12,814.49 |

The list is a **research shortlist**, not an exhaustive, validated top-three ranking of all 32 EAs under identical risk and costs. USDJPY's defect and data-quality limitations remain material.

GOLD was audited too. Its saved Full result had PF 1.10, relative equity DD 25.59%, losing 2023 and 2024 years, and a large contribution from partial 2026. The audited preset disabled main/addon stops and enabled additional exposure. It was not selected in this three-EA package.

## Research chronology and completed work

### Phase 1: inventory and source audit — October 9

- Inventoried installed sources, binaries, matching presets, old reports and available price files.
- Mapped the original 30-EA batch to installed variants rather than treating different versions as interchangeable.
- Checked saved report hashes and profit reconciliation.
- Identified the USDJPY sizing defect and shared risks such as incomplete history, failed entry handling, tick-dependent exits and netting/hedging differences.
- Identified NAS100 and US500 as priorities for baseline reproduction.

### Phase 2: reproducible native validation — October 10

The recorded run queue completed **14 native MT5 tests, with zero failed/incomplete records**. Five deterministic sizing fixtures also passed. The fixtures check helper behavior; they do not prove trading profitability.

- NAS100 and US500 baseline reproductions.
- NAS100 and US500 execution-delay stresses at 100 and 250 ms.
- Separate chronological development, validation and retrospective tests for NAS100 and US500.
- USDJPY original-versus-corrected Full-period comparison.

The delay stresses produced similar aggregate results, but fixed-delay stress is not a complete model of spreads, commissions, slippage, liquidity or historical financing.

### USDJPY corrected candidate: EXP001_v1

The separate candidate traverses unique prior completed session dates for sizing, retaining the original signal/session/entry functions. It compiled with zero errors/warnings.

| Version | Trades | Net profit | PF | Relative equity DD | Max equity DD |
|---|---:|---:|---:|---:|---:|
| Original baseline | 2,934 | 69,668.90 | 1.15 | 10.47% | 12,814.49 |
| EXP001_v1 correction | 3,689 | 74,210.75 | 1.14 | 9.82% | 13,906.53 |

All 2,934 original parent entries also appeared at the same timestamp/session/direction in the corrected run, with 755 additional candidate entries. Sizing changed on common entries. Although total profit increased, PF fell, maximum dollar drawdown increased, and combined 2025–2026 profit was lower. The correction establishes a different, repaired sampling behavior; it does not establish an economically superior strategy.

### Independent-validation limits

Phase 2 assigned chronological roles as:

- Development: 2022–2023.
- Validation: 2024.
- Retrospective evaluation: 2025 through each original report endpoint.

The existing Full reports, yearly results and earlier searches had already exposed 2022–2026. Therefore **none of these periods is certified as an untouched holdout**. Separate date runs test stability, but cannot undo earlier exposure. A genuine prospective test requires freezing the candidate, costs and acceptance criteria before observing new outcomes. No forward trading was activated.

## What the data-quality investigation found

Twenty-nine original Full reports displayed **36% real ticks**. Journals indicate recorded real ticks began around January 2025 for those instruments, so earlier portions used a different tick basis, including generated-tick fallback. This does not mean that 64% of OHLC bars are invalid.

Some reproduced NAS100/USDJPY reports display 100% real ticks despite journal/cache evidence that 2022–2024 lacks equivalent recorded-tick coverage. Preserve that contradiction: the report headline alone cannot certify the whole baseline. US500 reproduction retained 36%; its separate 2022–2023 and 2024 tests reported 0%, while its later test reported 99%.

Reproduced net profits differed from the old results by +0.78 USD for NAS100, -2.99 USD for US500 and +151.42 USD for USDJPY. Paired trade times, directions, volumes, prices and gross profits matched; swap differences explain the net differences. Historical financing assumptions have not been fully frozen. These are strong reproduction checks with explicit remaining cost/provenance limits.

## Your dashboard and Predictions research layer

The existing dashboard organizes Strategy + Symbol + Timeframe + Analysis Run, with 7d/30d/90d/180d/365d/Full analytics, native report parsing, trade exploration, session/calendar statistics, drawdowns and comparison views. The strategy-history floor is 2022-01-01; older market prices may serve indicator warm-up only.

The native tester uses owned hidden processes, dynamic local-agent ports and Stop Test controls. Market symbol discovery comes from the broker catalogue and is filtered by strategy compatibility.

The separate Predictions page researches empirical next-session and next-day direction from completed historical observations. It uses minimum samples and directional thresholds, chronological research, no future-close leakage, separate selection identities and issued-forecast history. Weekly prediction remains Experimental. Its gross price-movement metrics are not executable EA backtests or after-cost returns.

On October 12, current live bars/ticks and completed Asia bars were successfully synchronized for USDJPY and GOLD, but native MT5 build 6230 still capped actual broker-symbol testing at today's midnight. The dashboard now delays those 7d updates rather than publishing stale reports as fresh. Same-day EA-result inclusion remained unresolved at that checkpoint. The included dashboard validation document records exact probes and logs; no claim is made that this was resolved by October 18.

## Next planned research

First reconcile historical financing and tick provenance. Then run controlled variations in new versioned candidate folders:

1. Combined session exposure/risk caps.
2. Preregistered session ablation.
3. Lagged volatility/regime filters.
4. Robust volatility estimates for corrected USDJPY sizing.
5. Bounded failed-entry retries with duplicate-fill protection.
6. Earlier exits to study rollover exposure and execution effects.

These economic variations were designed but not run in the recorded Phase 2 work. Use one controlled change at a time, matched costs/capital, frozen evaluation rules and explicit sample counts. Preserve unsuccessful outcomes. Portfolio comparisons require combined exposure and equity, not adding standalone drawdown percentages.

## How to use this folder

Open this README first, then each `Baseline_evidence/report.htm` and `Research_documents/Phase_2/RESULTS.md`. The `.ex5` files are compiled MT5 programs; the `.mq5` files are readable/editable source. Keep this folder as an unchanged baseline archive. Any future candidate should go into a new folder with its own source, preset, hashes and experiment record. This package does not install or enable anything in MT5.

The original full research remains at:

`C:\Users\heroa\Downloads\MT5_Rolling_Tester_Dashboard\MT5_Rolling_Tester_Dashboard\research`

This package includes the relevant baseline evidence and research summaries, not all 30 original EAs, all raw tick data, every multi-gigabyte journal or the separate corrected USDJPY binary. The included candidate.json records the corrected candidate's original location if needed later.
