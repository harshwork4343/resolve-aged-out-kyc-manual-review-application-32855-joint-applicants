# Aged-Out KYC Manual Review: joint applications created 2024-06-01 to 2024-06-30

## Question
Joint account application 32855 sat in KYC manual review for months and then
turned up `rejected`. Was it decided on its merits, or closed out with a
backlog? How large is that backlog, and how much of it is unresolved
applicant-level KYC?

## Method
1. Pinned the cohort: `rds.account_applications` with `account_type='joint'`
   and `original_status='manual_review'`, `created_at` in June 2024 --
   116 applications.
2. Grouped the cohort by `cast(final_decisioned_at as date)`. One date is a
   clear outlier: **2025-04-09**, with 50 rejections recorded that day. Every
   other decision date in the cohort carries at most 16 applications and falls
   within weeks of application creation. 2025-04-09 is the backlog closeout.
3. Split the cohort three ways: aged out on the sweep date, decided on any
   other date (resolved on their merits), and never decisioned (still open).
4. Went person-level on the 50 aged-out applications by joining
   `rds.account_person_applications` to `rds.person_applications`, counting
   applicant records still at `kyc_status='manual_review'` and the applications
   where both applicants were unresolved.

## Findings
- Cohort size: 116 joint manual-review applications created in June 2024.
- Aged out in the 2025-04-09 sweep: 50 (all `rejected`).
- Resolved before the sweep on their own decision date: 65 (43 approved,
  22 rejected).
- Still sitting in `manual_review` with no final decision: 1.
- The 50 aged-out applications carry 100 applicant records; 68 of them never
  left `manual_review`. None were ever `denied` -- these applications were not
  refused, they were abandoned.
- 18 of the 50 aged-out applications had BOTH applicants unresolved. The other
  32 had one applicant cleared and one stuck, so a single stalled applicant was
  enough to sink the whole joint application.

## Worked example (the escalation)
Application 32855: `personal_checking`, `account_type='joint'`,
`original_status='manual_review'`, created 2024-06-04 03:39:00.983193.
Manual-review mailers went out 2024-06-04 03:41:20.778327 and reminders were
scheduled for 2024-06-07. Its two linked person applications are 80596
(user 106471, KYC'd 2024-06-04 03:39:04) and 80597 (user 106472, KYC'd
2024-06-04 03:39:07); both are still `kyc_status='manual_review'`,
`kyc_journey_status='waiting_review'`, `awaiting_documentation=true`. Neither
applicant was ever approved or denied. The application then received
`final_decisioned_at = 2025-04-09 16:56:11.279649` with `status='rejected'`
-- **309 days** after it was created, on the sweep date, alongside 49 others.
So 32855 was not decided on its merits: it aged out, and it is one of the 18
applications where both applicants were still unresolved.

## Recommendation
Treat the 2025-04-09 rejections as an aging-out action, not an adverse KYC
decision, and say so to the member: both applicants must submit a fresh
application, because nothing in the record denies them. Operationally, 68
applicant KYC records sat in `manual_review` for roughly ten months with
documentation outstanding and only a single reminder date on file. Add an
age-based alert on manual-review applications well before the ten-month mark,
and escalate the 32-application "one applicant stuck" pattern first, since
those are the cheapest to rescue.
