Aged-out KYC manual-review audit complete. Cohort: joint account applications
that entered manual review (original_status='manual_review',
account_type='joint') and were created 2024-06-01 through 2024-06-30.

Bottom line: application 32855 was not decided on its merits. It was closed out
in a single backlog sweep on 2025-04-09, 309 days after it was created, together
with 49 other applications from the same cohort.

- Cohort size: 116
- Aged out in the 2025-04-09 sweep (all rejected): 50
- Resolved on their own decision date before the sweep: 65 (43 approved,
  22 rejected)
- Still in manual_review with no final decision: 1
- Applicant KYC records among the aged-out set still at 'manual_review': 68
  (out of 100 applicants on those 50 applications; none were ever 'denied')
- Aged-out applications with BOTH applicants unresolved: 18

Worked example -- application 32855 (personal_checking, joint), created
2024-06-04 03:39:00.983193, manual-review mailers 2024-06-04 03:41:20, reminders
scheduled 2024-06-07. Its two linked person applications 80596 (user 106471) and
80597 (user 106472) both remain kyc_status='manual_review',
kyc_journey_status='waiting_review', awaiting_documentation=true -- neither was
approved or denied. final_decisioned_at = 2025-04-09 16:56:11.279649,
status='rejected', i.e. 309 days in manual review. It is one of the 18
both-applicants-unresolved cases.

Recommendation: message the member that this is an aging-out closure, not an
adverse KYC decision, and that both applicants need to reapply; add an age-based
alert on manual-review applications long before the ten-month mark.

Deliverables written to /workspace/metrics.json and /workspace/report.md.
