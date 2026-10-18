# Astra Phase 2 — checkpoint 2026-10-10

Phase 1: Frozen original inputs and report-derived presets; USDJPY EXP001_v1 compiled with zero errors/warnings. Five deterministic sizing fixtures passed. Signal/session/entry functions unchanged. Native original/candidate comparison underway; do not treat fixture results as P/L evidence.

Phase 2: Reproduction queue uses USDJPY, NAS100 and US500, followed by 100/250 ms execution-delay stresses. Every run has a separate result/status file and exact requested dates. Production sources/presets remain unchanged. Existing hidden tester launcher used with dashboard lock.

Phase 3: 2022–2023 development, 2024 validation, 2025–old-report endpoint retrospective test. All these years have already been inspected in old reports; no untouched holdout claimed. Separate chronological runs follow baselines.

Phase 4: Economic variations gated on reliable baseline reproduction. The isolated USDJPY correctness repair is not a deployment recommendation.

Read design.json, candidate.json, correctness_tests.json, runs/*/result.json and research.log. Native journal files may contain local broker identifiers; keep local. Report History Quality values include the literal 'real ticks' suffix; do not interpret 36% as a measured fraction of invalid OHLC bars.

## Phase 1 native completion

USDJPY baseline and EXP001 completed. Candidate metrics are saved in runs/usdjpy_EXP001/result.json; do not infer independent validation. Baseline differs from the old net result by +151.42 USD, entirely matching removal of four old swap charges; matched trade prices, volumes and gross profits are unchanged. Five correctness fixtures passed and original functions remain unchanged. Candidate source and binary are versioned in 06_CANDIDATE_EAS. NAS100/US500 reproduction is underway.

### Observed sizing comparison

Native entry journals show all 2,934 parent entries also occur in the corrected run at the same timestamp/session and direction, plus 755 additional candidate entries. Every common entry has a changed historical average. Median candidate/parent lot ratio is 0.8986; range 0.1834 to 8.8095. This verifies the change affects sizing and original skip behavior; it does not establish economic superiority. See sizing_comparison.json.

## Phase 2 checkpoint

Baseline and delay queue has finished; exact success/failure records are in batch_result.json. Phase 3 separate chronological native runs now begin. Quality/cost limitations in CHRONOLOGY_AND_DATA.md remain in force; no untouched holdout is claimed.

## Final phase checkpoint

All scheduled native run records are final. Read RESULTS.md and assessment.json for successes/failures and exact metrics. Phase 3 chronological tests remain retrospective: no untouched holdout exists in the already-inspected history. Phase 4 economic variations are preregistered but gated by financing and tick-provenance discrepancies. No production changes or deployment occurred. Next: freeze/reconcile costs and the 2025 real-tick boundary before selecting an economic improvement.
