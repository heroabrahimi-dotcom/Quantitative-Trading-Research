# Source audit — 2026-10-09

This is static review plus one synthetic helper test, not a successful compile or fresh MT5 trading simulation. All 32 installed sources had inputs/rules extracted; equivalent Q30 engines were grouped by normalized source hash and distinct engines reviewed. This is not formal proof of every execution path. Historical snapshots and binary-only tools are separately classified in EA_CATALOG.md.

## Confirmed defect: USDJPY 3EA historical sizing sample

`PrevTradingDay` (source lines 222–240, loop at 231) searches at most 20 calendar days and returns a date even when it did not find the requested number of trading days. `ComputePreviousAverage` (310–343, loop call 321–329) requests up to 1,199 prior sessions to accumulate 144 observations without enforcing unique dates. The same boundary date can therefore be counted repeatedly. If that boundary has no session data, the requested sample may never fill.

AUDIT-001 reproduces the exact calendar-loop behavior with a weekday-only data fixture: on 2026-10-05, 144 observations contain just 14 distinct dates, with 2026-09-15 counted 131 times. On 2026-10-09, only 14 observations are found. This is a deterministic source-logic finding, not a measured P/L impact or a test of the compiled binary. The source hash and design/result are saved under 05_VALIDATION.

Priority candidate: iterate unique completed sessions once, require 144 distinct observations, reject insufficient history with a diagnostic. Preserve rules, session/DST conversion, risk target and order behavior. Create a versioned candidate only after baseline freeze; retain the original unchanged.

## Shared Q30 execution risks requiring controlled tests

- Fixed-lot variants have no attached SL/TP. Session-end exit depends on a subsequent tick and successful broker execution. 0.10 lots differs greatly in risk between FX, crypto, indices and metals.
- Entry-attempt state is set before the trade request; a failed first request is not retried within that session. Restart state is not persistent in the simple variants, so duplicate entry after restart is possible.
- M30 session direction requires only two bars, not a complete session. History gaps can change both the trading calendar and signal interpretation.
- CTrade request booleans alone do not prove a completed fill; future tests should reconcile return codes, deals and requested positions.
- London and NY overlap. Simple Q30 variants do not enforce hedging mode, so netting behavior could merge or offset exposures. Compare under a documented account mode.
- The rule engine could evaluate current London before its close if configured with NY P1/MAJ_P. None of the present rule tables does this; enforce that invariant for future candidates.
- BTCUSD/US30/US500 sizing uses historical high–low range and OrderCalcProfit. Nearest-step rounding and minimum-volume clamping can exceed the intended monetary size. Costs, gaps and SL slippage are additional risks. These variants extend historical searching to 1,200 calendar days; they are distinct from the confirmed USDJPY 20-day defect.

## GOLD 3ea

Asia copies the last closed London direction. London and NY inspect the last closed NY session: an EMA50 H1 intersection with a candle body is EQUAL and follows NY; ABOVE/BELOW reverses NY. The mandatory A/B phase uses 13 B rows and 26 A rows; B reverses the base direction, with NY using a shifted row position. The phase anchor and calendar dependency are part of the strategy. How that phase was selected is unknown and must be counted as a potential tuned choice.

Sizing uses 144 completed same-session ranges and a default 600 monetary target. The current preset disables main SL, enables a same-direction pending STOP addon, and disables addon SL. This is not a 600 maximum-loss strategy. Additional fills increase total exposure. GOLD deliberately uses one selected SL-distance from the actual main fill for the pending trigger; StopOrderDistanceMultiplier is not applied in that placement path. The code has bounded retries and duplicate-exposure checks; do not infer perfect fills from these safeguards.

The default requires a hedging account and permits entry within 120 seconds. Own-position tags and overdue closure logic are more developed than the simple Q30 engine. They still require execution and restart tests in isolation.

## NAS100 3ea

Distinct signal logic: NY checks NY(D−3); if BUY and its EMA zone is ABOVE, reverse NY(D−2), otherwise reverse London(D−2); when NY(D−3) is not BUY, reverse NY(D−1). Asia uses NY(D−2) when previous Asia equals previous London, otherwise the majority of the previous three London directions. London waits for today's Asia to close: if Asia0 equals London−1, reverse London−2; else if Asia0 equals NY−2, use London−2; otherwise recompute the NY signal for D−2. Missing-data branches can skip signals.

There is no GOLD mandatory A/B cycle in NAS100's base-signal function. It shares range sizing and optional pending orders; source defaults enable main SL and disable addon orders. Use the catalog's preset values and the actual report inputs when comparing runs.

## Regime labels and spreadsheet harnesses

GOLD/NAS100 regime panels are informative; they do not gate trade entries. Historical direction-match backfill is not realized, cost-adjusted trade performance and does not reproduce stop/addon fills. Current-bar indicator readings are evolving observations; a later finished-bar reconstruction must not be substituted as if known earlier.

The two Downloads/Session2_ExactRules_Backtest_EA sources embed 1,200 dated spreadsheet rows (2022-01-03 through 2026-08-26), seed values and expected outputs. OnTick processes due comparison rows; OnTester returns an aggregate spreadsheet score. These are spreadsheet reconciliation harnesses, not independent tradable-strategy performance evidence. A PASS means agreement with embedded expectations, not out-of-sample profitability.

## Legacy scheduled-trade sources

The historical ScheduledTradeEA family has manual-direction defaults and varying fixed-clock/DST modes. Some risk labels are informational or balance-proportional lot scaling rather than stop-based monetary risk. CloseAllTrades implementations iterate open positions without symbol/magic filtering. Never run these archival tools on a terminal with unrelated positions. Late catch-up entries and restart behavior also need examination before any candidate reuse. They are not approved baselines.

## Provenance limits

Source and EX5 pairs have no verified compiler manifest. Dashboard metadata records an EA hash when analysis is saved; this alone does not prove that exact binary was frozen at tester launch. Existing reports remain useful evidence, but future runs must record hashes before and after launch and preserve the exact staged binary/preset/config used. No originals were edited in this audit.
