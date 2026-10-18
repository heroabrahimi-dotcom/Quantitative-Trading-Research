# StrategyLab Predictions — implementation and handoff

Implemented 2026-10-12. This is a market-direction analytics layer. It never executes orders, changes EA inputs, reproduces an EA's signal logic, or promotes an EA into production.

## Using it

Open **Predictions** in the existing sidebar. Strategy, Symbol and Timeframe remain the shared dashboard selectors. The page includes Next Session, Next Day, Experimental Next Week, Research, recent issued forecasts, and configurable sample/probability/complexity thresholds.

Defaults in `config.json` (also editable in Predictions):

- `MIN_PREDICTION_SAMPLES = 30` directional matches. Flat outcomes are counted separately.
- `MIN_DIRECTION_PROBABILITY = 55` percent.
- `PREDICTION_MAX_CONDITIONS = 3`.

An empirical majority is not a calibrated probability or a guarantee. A direction is withheld when samples, current completed inputs, freshness, probability threshold, or chronological validation are inadequate. Historical sample statistics remain visible and are explicitly distinguished from issued forecasts.

## Real market history and process safety

`predictions/ExportPredictionBars.mq5` is a new, **read-only script**, compiled only in `runtime/prediction_reader`. It calls CopyRates from 2022-01-01 for M30 and D1 and exports native SymbolInfoSessionTrade weekly hours. It contains no trade/order calls and refuses to run with automated trading enabled. No original EA source, binary, preset, tester report, or analytics JSON is rewritten.

The script runs in a separate empty-profile terminal on the existing hidden desktop / owned Windows Job Object mechanism. The existing Strategy Tester still uses dynamic ports and its original Stop Test behavior. Data collection does not run a backtest, use a tester agent, or attach to the manually opened terminal.

The first Python-IPC prototype was discarded after an MT5 updater relaunch escaped its launcher job. Only its positively identified dedicated reader process was cleaned up. The final reader uses native script startup and no Python MT5 initialize/auto-launch fallback. Subsequent native exports completed, and no reader process remained. Manual terminal PID 372, creation time 1791780689.1049535, remained unchanged during validation.

Raw market cache: `data/prediction_market/<symbol>.json`. These installation timestamps encode broker wall-clock epoch numbers; conversion uses the existing configured Pepperstone daily EU-DST rule. Session London/NY clocks use the existing independent EU/US DST conventions. M30 provides session OHLC; native D1 provides daily OHLC. The selected dashboard timeframe is retained in the prediction identity, while these predictor input resolutions remain M30 and D1.

The source timestamp is conservatively captured **before** collection. A cached forming bar cannot become final just because the clock advances: its close must precede both the request time and the source observation cutoff. Native weekly hours restrict upcoming targets. Holiday exceptions are not certified; incomplete sessions are excluded, and stale inputs suppress directions.

## Causality and target definitions

- BUY means target close > target open; SELL means close < open. Flat targets do not count as directional matches.
- Sessions require every expected M30 slot. Missing bars never get filled or interpolated.
- Every feature records the latest completion timestamp of its inputs, bounded by both issue time and target start.
- London waits for same-day Asia completion.
- **London closes after NY opens in the current clock.** Consequently, the requested London-completed NY forecast cannot be issued before NY starts. It returns NO PREDICTION with the reason, rather than using the future London close. The modular London→NY rule remains available for clocks where the prerequisite genuinely closes before NY begins; it currently has no valid same-day samples.
- Asia requires a completed prior NY session.
- Next Day waits for the preceding trading day's completed candle. Native weekly opening hours provide a valid pre-open forecasting interval where one exists. On weekdays before the required daily close, the page clearly says pending. Daily settlement uses the corresponding native D1 candle, not a fabricated 24-hour price series.
- Week remains Experimental and issues no forecasts.

## Predictors and research

Modular definitions in `predictions/engine.py` cover weekday; previous 1/2/3 completed sessions; previous 1/2/3 daily candles; Asia→London, London→NY, prior NY→Asia; last completed named sessions; weekday/sequence combinations; volatility; trend/range; candle body/range/wicks; and EMA distance. There are 25 fixed candidate feature sets, limited to at most three conditions. New definitions belong in the feature registry and rule list, with causal tests and a model-version change.

Fixed definitions use prior completed daily data: mean true range over 14 days, a trailing up-to-60-day baseline, EMA20, ATR-normalized distances, body/range ratios, and upper/lower wick ratios. Thresholds are specified in the engine and are not optimized against future rows.

Research uses **broker calendar dates**:

- 2022: chronological development, scored progressively using only earlier completed development outcomes.
- 2023: validation using the development-fit frequency tables.
- 2024 onward: retrospective test using the same development-fit tables.
- Shorter history: chronological 50/25/25 split by whole date; no random shuffle.

Ranking uses development accuracy with a condition-count penalty and a small-sample penalty. Validation/test outcomes never choose the winning rule. The table reports accuracy, issued sample count, gross movement PF, expectancy, cumulative drawdown and yearly results. Strong development followed by weak validation/test is marked OVERFIT and cannot produce a direction.

The Phase 2 audit established that 2022–2026 had already been examined. Therefore **no untouched historical holdout is claimed**. The page explicitly labels retrospective test results. PROMISING requires adequate validation/test sample sizes and directional accuracy. STRONG additionally requires independently recorded prospective outcomes for the same model, rule and target: sufficient unique events, accuracy above the configured threshold, and a 95% Wilson lower bound above 50%. The earliest directional forecast per event is counted; repeated snapshots cannot inflate the sample. There are no completed prospective events yet at initial delivery.

### Meaning of PF, expectancy and drawdown

These prediction rules do not specify a tradable EA entry, stop, size or cost model. Metrics therefore use explicitly labelled **gross hypothetical target open-to-close movement in basis points**, with an equal unit per predicted event. They exclude spread, commission, slippage and financing. Main-card matching-sample metrics apply the in-sample majority direction; Research metrics use chronologically issued predictions. They are not the original EA's PF, an executable strategy backtest, account-equity drawdown, or R expectancy. No unsupported R value is invented.

## Storage, refresh and audit

Prediction/research folders are keyed by `[ea_id, symbol, timeframe, prediction_type]` under `data/predictions`. Raw market bars may be shared by symbol; forecasts and research are never shared across strategy/timeframe identities.

- `latest.json`: current evidence and forecast status.
- `history.json`: issued snapshots plus later actual/incorrect/correct settlement. No retrospective forecast backfill. Issued evidence is frozen; only settlement fields are filled after completion.
- `research_<target>.json` and `research.json`: source/model-fingerprinted cached research.

The visible page polls every 15 seconds and responds to selector changes. Real bars are collected once per new M30 boundary when needed; current snapshots are reused, and failures have a five-minute retry delay. One reader runs at a time; the most recent pending symbol wins. Historical research is recomputed only when completed source events or model settings change. Other dashboard pages do not trigger prediction work. The existing automatic 7d scheduler is unchanged.

## Validation

Real local MT5 caches and live API checked for:

1. USDJPY 3EA / USDJPY.a / M30.
2. GOLD 3ea / XAUUSD.a / M30.
3. US500_a_2COND / US500.a / M30.

At validation, the next scheduled target was London. Asia had not yet completed, so no direction was issued. Matching sample counts were 937 (USDJPY), 352 (GOLD), and 639 (US500); their underlying empirical majorities were also below the default 55% threshold. These are measured counts, not example numbers. Daily predictions remained pending the required daily close; Week remained Experimental.

Browser checks confirmed the sidebar, main cards, research/overfit table, day/week states, and strategy/symbol updates without browser reload. API checks verified identity, BUY+SELL sample reconciliation, timestamps preceding the target, and unfilled future actuals. Native exporter compilation completed with 0 errors and 0 warnings.

**45 focused tests passed**, including 16 prediction tests plus existing automatic-refresh, dynamic-port, log-discovery, hidden-process and Stop Test regression coverage. Prediction tests cover next-session/weekend/DST/native-calendar detection, weekday matching, exact sample counts, small/weak samples, future-candle mutation, cached-forming-bar cutoff, no London-close leakage into NY, chronological broker-year splits, no test-set model selection, combination isolation, prospective deduplication and delayed actual settlement. Synthetic fixtures are confined to tests and are never published as market data or UI results.

Evidence: `runtime/predictions_validation/api_combinations.json`, `logs/prediction_history.log`, native reader logs, and `runtime/predictions_validation/predictions.png`. Actual future-event settlement is verified with isolated fixtures; live records correctly remain pending until those events occur.

## Next research step

Keep the current recipe and thresholds frozen while collecting prospective outcomes. Reconcile executable spread/commission/slippage and a defined risk unit before interpreting any gross movement edge as an EA trading improvement. Resolve the desired NY prerequisite explicitly before proposing an alternative to the existing overlapping London session. No live trading or EA promotion is enabled.
