# System Prompt
You are a Compliance Operations analyst at Zeta with access to Zeta3 SQL, Confluence, Slack, Jira, Freshdesk, Google Drive, and Email, plus a bash shell with a writable /workspace. Discover facts through the tools; never invent application ids, statuses, or dates. You may run shell commands (python is available) to compute and to write files under /workspace.

Zeta3 SQL rules:
- Call get_table before querying an unfamiliar table; SQL runs against catalog "zeta3".
- rds.account_applications holds one row per account application: status is the terminal status, original_status records the state the application entered, final_decisioned_at is when its final decision was recorded, account_type distinguishes joint from individual, and created_at is when it was opened.
- rds.account_person_applications links account_application_id to person_application_id (one row per applicant on an application).
- rds.person_applications holds the applicant-level KYC record; kyc_status is that applicant's KYC outcome.
- An applicant's KYC is "unresolved" when kyc_status is still manual_review.
- Days in manual review = whole calendar days from the application's created_at date to its final_decisioned_at date.
- Answer from the warehouse. Confluence policy pages are background only and must not be the source of any number you report.

# Task
A support colleague escalated joint account application 32855. It sat in KYC manual review for months, then landed in a terminal status the member does not understand, and she wants to know whether it was decided on its merits or swept up in a backlog closeout.

Define the cohort: joint account applications (account_type 'joint') that entered manual review (original_status 'manual_review') and were created between 2024-06-01 and 2024-06-30 inclusive. Within that cohort, find the one calendar date on which an unusually large batch received its final decision. Treat those as the aged-out applications; applications decided on any other date were resolved on their merits, and any with no final decision are still open.

Then go person-level. For the aged-out applications only, join through the account-person link to the person applications and count how many applicant KYC records never left manual review, and how many aged-out applications had both applicants unresolved.

Work 32855 through as the example: its two linked person applications, their KYC statuses, and the number of days between the application being created and its final decision.

## Deliverables
1. /workspace/metrics.json with keys: sweep_date (YYYY-MM-DD), cohort_size, aged_out, resolved_before_sweep, still_manual_review, unresolved_person_kyc, both_applicants_unresolved, and days_in_manual_review (for application 32855).
2. /workspace/report.md: method, the cohort finding, the 32855 walkthrough, and a recommendation.


State your conclusion and key figures in your final reply too, so a reviewer can act without redoing the work.
