# Existing results assessment — 2026-10-09

## Evidence boundaries

165 native HTML reports were inventoried: 114 dashboard reports, 45 in the original batch archive (including probes/variants), four older output reports and two USDJPY comparison reports. These are not 165 independent experiments. All parsed report test ranges are from 2022 onward. Header-range validation is not proof of complete tick coverage or of an untouched holdout.

114 saved period results span 35 manifests. All 114 stored report hashes match the current report files; 95 recorded EA hashes match a currently installed binary. All stored report-vs-deal net-profit reconciliations are within 0.02. This checks saved evidence consistency, not independent re-execution of MT5 or re-parsing every raw deal. Archived/deleted runs remain labeled. The rolling/full views overlap and must never be treated as independent samples (there are six supported period labels: 7d, 30d, 90d, 180d, 365d, Full).

## Latest visible Full results for current installed names

These are historical observations, not recommendations or a risk-normalized ranking. USD deposits, leverage, dates, sizing and options differ. DD below is the saved native relative equity drawdown; available deal-derived balance curves are not intratrade equity curves. Each row has a matching recorded current binary hash, without compile/launch attestation.

| EA | End date (start 2022-01-01) | Trades | Net P/L USD | PF | Equity DD % | Win % | Native Sharpe |
| --- | --- | --- | --- | --- | --- | --- | --- |
| GOLD 3ea | 2026-10-05 | 4240.0 | 67643.28 | 1.1 | 25.59 | 49.65 | 1.17 |
| NAS100 3ea | 2026-10-05 | 3665.0 | 79752.94 | 1.15 | 6.7 | 51.13 | 2.68 |
| AUDUSD_a_2COND | 2026-10-04 | 3683.0 | 4279.4 | 1.13 | 1.15 | 51.51 | 2.22 |
| US30_a_2COND | 2026-10-06 | 3661.0 | 83298.72 | 1.16 | 8.41 | 50.64 | 2.85 |
| US500_a_2COND | 2026-10-06 | 3605.0 | 79316.28 | 1.15 | 8.07 | 50.6 | 2.78 |
| USDJPY 3EA | 2026-10-05 | 2934.0 | 69517.48 | 1.15 | 10.47 | 50.1 | 2.52 |

### Yearly net P/L from saved analytics

| EA | 2022 | 2023 | 2024 | 2025 | 2026 partial |
| --- | --- | --- | --- | --- | --- |
| GOLD 3ea | 12843.33 | -15403.03 | -3189.27 | 14414.39 | 58977.86 |
| NAS100 3ea | 17431.33 | 12459.62 | 6245.55 | 17270.27 | 26346.17 |
| AUDUSD_a_2COND | 3092.25 | 473.15 | -40.15 | 66.9 | 687.25 |
| US30_a_2COND | 32689.15 | 9489.29 | -2893.46 | 9660.21 | 34353.53 |
| US500_a_2COND | 22347.4 | 11576.03 | 15442.77 | 10778.66 | 19171.42 |
| USDJPY 3EA | 27019.6 | 5971.82 | 3521.29 | 16336.58 | 16668.19 |

NAS100 3ea and US500 are priorities for baseline replication because each saved year is positive and their reported relative equity drawdowns are lower than GOLD's. This is a provisional research ordering, not proof of consistency on unseen data. Their shared index exposure also limits diversification claims. USDJPY's positive yearly history is not a reason to ignore its sizing defect. GOLD has losing 2023 and 2024 years, a PF close to one, and a large contribution from partial 2026; addon exposure and disabled stops need separate attribution. US30 has a losing 2024. AUDUSD's small drawdown reflects a different sizing scheme and cannot be compared directly to 600-risk variants.

## Original 30 Full reports

All 30 original-symbol reports were located for 2022-01-01 → 2026-10-01. 29 report history quality of 36%; XAUUSD reports 100%. Quality values are taken literally from the native report. A low value is a data-confidence problem; it does not specify exactly which days/ticks are missing. A 100% field also does not establish realistic costs or independent validation. Investigate tester logs and real/generated tick coverage before interpreting differences.

XPDUSD and XPTUSD original reports show approximately 99% equity drawdown; retain them as unsuccessful historical outcomes, not attractive candidates because of another metric. Several original crypto and index variants have PF below one. The original fixed-lot batch and current risk-sized US30/US500/BTCUSD must not be merged as one version. See original30_mapping.csv for per-symbol links and quality.

The old ranking script combines profit, PF, Sharpe and drawdown into a heuristic score. It does not establish a holdout or correct for the rule search. Spreadsheet 'in/out' column labels and DUKA comparisons have not been verified as independent OOS evidence. Preserve them without adopting their winner labels.

## Missing evidence before selecting a strongest strategy

- Frozen source-to-binary compile manifest and exact tester-launch provenance.
- Date-stamped rule search history and complete attempted-trial count, including rejects.
- Broker tick coverage and cost reconciliation: historical spreads, commissions, swaps, delays, slippage, trading hours and symbol contract changes.
- A genuinely untouched chronological sample. Prior inspection/optimization cannot be undone by renaming dates 'holdout'.
- Intratrade equity/exposure data, synchronized portfolio risk and realistic pending-order execution.
- Controlled reruns with matched settings, account mode and comparison risk budgets.

No strategy is certified as consistently profitable on unseen data in this audit. No fresh MT5 performance backtest was run this session.
