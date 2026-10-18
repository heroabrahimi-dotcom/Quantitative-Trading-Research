# Symbol discovery and live-history validation — 2026-10-12

## Delivered

- Broker catalogue exported by a read-only native MT5 script using `SymbolsTotal(false)` / `SymbolName`. The connected Pepperstone environment returned **1,742 symbols**; **1,668** passed the dashboard's full-trading-mode, tick-size, volume-step, non-custom and safe-path checks.
- Both the main Symbol selector and Run / Import selector use this catalogue. `XAUUSD.a`, `NAS100.a`, `US500.a`, `USDJPY.a`, `US30.a`, and `AUDUSD.a` were present in the live browser dropdown.
- Explicit `supported_symbols` in an EA's configuration takes precedence. Inspectable `_Symbol` and configurable `InpSymbol` sources permit compatible broker symbols; unknown binaries without documented support are restricted. An explicit `symbol_generic` declaration is also supported. These checks establish symbol routing, not profitable suitability on every market.
- Where the EA exposes `InpSymbol`, only a **run-owned copy** of the preset receives the selected symbol. Original presets, EA source, binary, risk rules and signal formulas are untouched. New successful reports also retain `effective_parameters.set` and `run_environment.json` for that routing change.
- Discovery is cached for five minutes and refreshed in an owned hidden terminal. The browser polls the catalogue without reload. Diagnostics include discovered symbols, selected-strategy support, and final displayed symbols.
- Every 7d attempt synchronizes M30 bars and recent real ticks **inside `runtime/tester`**, checks the broker clock and actual weekly trading sessions, and verifies all M30 bars for the latest completed session. No EA is attached to the live chart and automated trading is disabled for the script.
- Failed synchronization retries twice at 15-second intervals. A delayed run retries after `HISTORY_RETRY_SECONDS` (default 120, minimum 60) while its selection remains active. Existing reports/results remain available. Stop Test cancels the owned synchronization process, removes run-owned temporary files, and defers automatic retry.
- Dynamic local-agent port selection, private desktop/job ownership, history floor, existing analytics and the other five date windows remain unchanged.

## Important unresolved native MT5 limitation

**Today's Asia trades cannot be truthfully added by a cache refresh alone.**

This installation is MT5 build 6230. After the Asia close, real tests were performed with:

1. A tomorrow `ToDate` (`2026.10.13`).
2. Explicit intraday FromDate/ToDate timestamps (USDJPY diagnostic).

The native execution journal still stated:

```
testing of Experts\Quant30Auto\USDJPY 3EA.ex5 from 2026.10.05 00:00 to 2026.10.12 00:00
USDJPY.a: history synchronized from 2021.01.04 to 2026.10.09
testing of Experts\ACTIVE\GOLD 3ea.ex5 from 2026.10.05 00:00 to 2026.10.12 00:00
XAUUSD.a: history synchronized from 2021.01.04 to 2026.10.09
```

The raw report header echoed the configured tomorrow date, while actual execution was capped at today's midnight. Therefore changing only the header/range would falsely imply coverage. The unchanged validator correctly rejected those diagnostic reports as outside today's boundary. They were retained as diagnostic artifacts, never published as fresh analytics.

The final runner checks the native cutoff **before starting the EA tester** whenever live history extends into the current test-end day. It returns:

> 7d update delayed — waiting for current MT5 history — MT5 excludes the current trading day. Live bars are synchronized; no stale report was published.

This is a real platform boundary, not a stale-browser/backend problem. The final patch does **not** change the system clock, shift market timestamps, alter EA logic, invent trades, relabel a stale report, or bypass the validator. A separate intraday replay/custom-symbol design would require additional work outside this patch; no such alternative has been deployed.

Official reference: [MT5 testing date semantics](https://www.metatrader5.com/en/terminal/help/algotrading/testing) and [MetaQuotes programming book, current-day testing restriction](https://www.mql5.com/files/book/mql5book.pdf).

## Real observations (broker clock UTC+3 under existing settings)

| Check | USDJPY.a | XAUUSD.a |
|---|---|---|
| Source synchronization | Passed | Passed after retry; initial asynchronous history-load handling was corrected |
| Latest M30 open in diagnostic | 2026-10-12 09:30 | 2026-10-12 09:30 |
| Latest real tick in diagnostic | 2026-10-12 09:50:50.081 | 2026-10-12 09:55:12.517 |
| Today's Asia ended | 2026-10-12 09:00 broker / 06:00 UTC | Same |
| Missing bars in today's completed Asia | 0 | 0 |
| Actual tester execution cutoff | 2026-10-12 00:00 | Same |
| Agent history last date | 2026-10-09 | Same |
| Real native diagnostic run completed | Yes: 723,550 ticks / 239 bars | Yes: 2,423,248 ticks / 230 bars |
| Today's Asia included in tester report | **No — native cutoff blocks this** | **No — native cutoff blocks this** |
| Final normal API behavior | Delayed; stale publication prevented | Delayed; stale publication prevented |

Live UI checks showed both selectors include GOLD and the delayed message arrives automatically without browser refresh. There were no browser console errors. Historical reports remain selectable; all **143** existing raw-report hashes were unchanged after validation.

A real GOLD synchronization was stopped through the dashboard Stop endpoint. It returned **Stopped by user**, left no owned terminal/tester process or temporary market request/config, and left manual MT5 PID 372 (creation time 1791780689.1049535) unchanged. The normal API accepted another run after earlier delayed runs without a backend restart.

## Tests

**53 focused tests passed:** symbol compatibility/catalogue filtering, current bars plus completed Asia checks, stale ticks/bars rejection, missing-session-bar rejection, native-coverage guard, delayed retry without erasing success, automatic refresh, dynamic ports, agent discovery, hidden processes, Stop Test and Predictions regressions. JavaScript syntax and Python compilation passed. The native collector compiled with 0 errors and 0 warnings.

An additional legacy `tests.test_periods` invocation had **two fixture failures**:

- `test_existing_results_and_pepperstone_rules_unchanged` compares an October 4 snapshot against a GOLD manifest soft-deleted on **October 5 at 11:28**, before this work. The current raw reports were independently hash-checked and preserved.
- `test_six_defaults_and_deselection` takes the latest saved automatic request, including `_auto_7d=True`, then expects manual six-period defaults. The automatic request correctly stays 7d-only. This fixture was not altered to conceal the mismatch.

The other five tests in that legacy module passed. No claim is made that every legacy test passed or that current-day native Strategy Tester inclusion was achieved.

## Evidence and implementation

- `runtime/symbol_history_validation/catalog.json`
- `runtime/symbol_history_validation/USDJPY_native_probe.log`
- `runtime/symbol_history_validation/USDJPY_datetime_probe.log`
- `runtime/symbol_history_validation/GOLD_native_probe.log`
- `runtime/symbol_history_validation/*_native_probe.htm` (unpublished diagnostic reports)
- `runtime/symbol_history_validation/*_api_job.json`
- `runtime/symbol_history_validation/stop_check.json`
- `runtime/symbol_history_validation/reports_before.json`
- `runtime/history_checks/<run_id>.json` (separates terminal cache timestamps from prior tester-agent history)
- `logs/application.log`, `runtime/tester/logs`, `runtime/tester/Tester/logs`
- New modules: `backend/symbols.py`, `tools/market_history.py`, `runner/history.py`, `runner/SyncMarket.mq5`, `tests/test_symbol_history.py`.

## Next decision

The native current-day restriction needs a separately validated execution approach if same-day EA results are mandatory. Until then, the dashboard honestly delays rather than calling a previous-day result fresh. Session bars are available as soon as they complete; the remaining restriction is their use by this native tester build.
