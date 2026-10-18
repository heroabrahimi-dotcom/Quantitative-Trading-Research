# Controlled economic variations — preregistered queue

Date: 2026-10-10. Status: designed, not run. These are hypotheses, not validated improvements. No production source or preset changes are authorized by this document.

## Gate before running variations

Require reproducible broker-cost assumptions and an explicit decision about generated-tick portions of the baseline. Current evidence already shows changed swap application and disagreement between some report quality headlines and native tick-availability journals. Until that is resolved, an apparent strategy improvement could instead be a data/cost change. Complete the already-preregistered baseline, chronological and delay tests; retain all failures.

## Research queue

| ID | Hypothesis | Single controlled change | Comparator and primary outcome |
| --- | --- | --- | --- |
| ECON-001 | Smaller aggregate session exposure reduces the worst overlapping-session drawdowns | Cap combined simulated monetary risk across concurrent positions; retain original entry directions and individual stops | Original US500; paired chronological equity drawdown and net expectancy at matched account capital |
| ECON-002 | Some session-direction branches are unstable across years | Preregister one session ablation, selected only in development, then freeze it | Original same EA; paired after-cost expectancy in validation and later data, with fewer trades explicitly counted |
| ECON-003 | A lagged volatility filter can avoid unusually expensive or unstable entries | Gate entries using prior completed-session range divided by its past median; freeze threshold before validation | Original NAS100; downside and turnover after identical costs; reject if improvement is one-year-only |
| ECON-004 | Volatility estimates should be less sensitive to isolated range spikes | Replace mean range with a preregistered robust estimate in a copied candidate; hold monetary risk target constant | Corrected USDJPY, not its defective parent; volume stability, gaps, actual loss distribution and net expectancy |
| ECON-005 | Late/failed-entry handling loses valid signals | Bounded retry only after explicitly failed trade requests, with confirmed-fill duplicate protection | Original copied Q30 engine; correctness first, then fill counts and execution-adjusted results |
| ECON-006 | Earlier exit can reduce holiday rollover exposure | Exit at a preregistered offset before session end, only where a tick is available | Original same EA; financing, fill slippage, expectancy and tail loss, including missed-close scenarios |

## Anti-overfitting constraints

- One change per candidate and a unique source/preset hash; preserve every failed build, failed run and losing outcome.
- Do not choose a regime threshold after looking at the retrospective 2025–2026 results. That period is already exposed for the existing family.
- Use only completed observations at the decision timestamp. A current-bar value must be recorded at that instant; a final bar value cannot replace it later.
- Treat shared-index strategies as correlated; portfolio drawdown requires synchronized equity and exposure, not summed standalone drawdowns.
- Specify trial budget, costs and monetary risk limits before any economic selection. No promotion is automatic.
- The first proposed economic experiment is ECON-001 after the baseline-cost gate. The immediate next experiment remains financing/data reproduction because it currently limits attribution.

No GREEN/YELLOW/RED panel labels are assumed to be validated filters. No parameter search has been run against these six ideas.
