# Aged-Out KYC Manual-Review Audit — Joint Applications (Task 32855)

## What this task does

A Compliance Operations analyst at Zeta is asked to investigate why joint account
application **32855** — both of whose applicants were stuck in KYC manual review —
ended up `rejected`. The real question is whether it was decided on its merits or
swept up in a bulk backlog closeout. The agent must:

1. **Define the cohort**: joint account applications (`account_type='joint'`) that
   entered manual review (`original_status='manual_review'`) and were created in
   June 2024 (2024-06-01 to 2024-06-30 inclusive).
2. **Find the sweep date**: within the cohort, identify the single calendar date on
   which an unusually large batch received its final decision (an outlier in the
   decision-date distribution). Those are the aged-out applications; applications
   decided on any other date were resolved on their merits; any with no final
   decision are still open.
3. **Go person-level**: for the aged-out applications only, join through the
   account-person link to the person applications and count how many applicant KYC
   records never left manual review, and how many aged-out applications had both
   applicants unresolved.
4. **Work 32855 as the example**: its two linked person applications, their KYC
   statuses, and the number of days between creation and final decision.

## Why it is non-trivial

This task tests several distinct reasoning skills a real compliance analyst needs:

- **Cohort scoping** — the agent must filter on `original_status` (the state the
  application *entered*), not `status` (the terminal state), and must restrict to
  `account_type='joint'`. Filtering on the wrong column or ignoring account type
  changes the cohort size.
- **Empirical sweep-date discovery** — the sweep date is not given. The agent must
  group the cohort by final-decision date and recognise the gross outlier
  (2025-04-09, 50 rejections) rather than assuming a date. Every other decision date
  carries ≤ 16 applications and falls within weeks of creation.
- **Three-way partition** — aged-out (sweep date) vs. resolved-on-merits (any other
  decision date) vs. still-open (no final decision). The `resolved_before_sweep`
  count must exclude both the sweep and the never-decisioned application.
- **Person-level join** — counting *applicant KYC records* (not applications) requires
  joining `account_person_applications` → `person_applications` and reading the
  current `kyc_status`. Counting applications instead of applicant records gets the
  wrong number.
- **Per-application HAVING clause** — separating "both applicants unresolved" (18)
  from "one applicant stuck" (32) requires a `GROUP BY application HAVING count = 2`.
- **Whole-day elapsed time** — days in manual review is whole calendar days from
  `created_at` to `final_decisioned_at` (309 for application 32855).

## Deliverables

The agent writes two files to `/workspace`:

- **`metrics.json`** — machine-readable summary with keys: `sweep_date`,
  `cohort_size`, `aged_out`, `resolved_before_sweep`, `still_manual_review`,
  `unresolved_person_kyc`, `both_applicants_unresolved`, `days_in_manual_review`.
- **`report.md`** — written brief: method, the cohort finding, the 32855 walkthrough,
  and a recommendation.

## Verification

The task is graded by `tests/manifest.json`:

- **11 deterministic file-checks** (`deliverable_files_graded`) — assert each
  metrics.json key equals the gold value and that report.md exists and mentions the
  example application and the sweep date.
- **2 rubric checks** (LLM-judged) — `method_cohort_and_person_join` verifies the
  trace shows the real method (pinned cohort, empirical sweep-date discovery,
  person-level join); `aged_out_conclusion_stated` verifies the report states the
  aging-out conclusion with the 32855 walkthrough.

## Solvability

The golden trajectory (`solution/golden_trajectory.json`, 11 steps) replays through
Oracle at reward **1.0** — every deterministic assertion and both rubric checks
pass — confirming the task is solvable with the data and connectors provided.

## Gold values

| Metric | Value |
|---|---:|
| sweep_date | 2025-04-09 |
| cohort_size | 116 |
| aged_out | 50 |
| resolved_before_sweep | 65 |
| still_manual_review | 1 |
| unresolved_person_kyc | 68 |
| both_applicants_unresolved | 18 |
| days_in_manual_review (32855) | 309 |

Application 32855: person applications 80596 (user 106471) and 80597 (user 106472),
both `kyc_status='manual_review'`, never approved or denied, rejected 309 days
after creation on the 2025-04-09 sweep date.
