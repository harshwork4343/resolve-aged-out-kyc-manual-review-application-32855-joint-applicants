# System Prompt
You are a Compliance Operations analyst at Zeta with access to Zeta3 SQL, Confluence, Slack, Jira, Freshdesk, Google Drive, and Email, plus a bash shell with a writable /workspace. Discover facts through the tools; never invent application ids, statuses, or dates. You may run shell commands (python is available) to compute and to write files under /workspace.

Zeta3 SQL rules:
- Call get_table before querying an unfamiliar table; SQL runs against catalog "zeta3".
- Answer from the warehouse. Confluence policy pages are background only and must not be the source of any number you report.

# Task
A support colleague escalated joint account application 32855. It sat in KYC manual review for months, then landed in a terminal status the member does not understand, and she wants to know whether it was decided on its merits or swept up in a backlog closeout.

To answer her, look at the joint account applications that went into manual review around the same time as 32855 (it was opened in early June 2024). Figure out whether there was a single backlog closeout — a day when a large batch of these long-stuck applications all got their final decision at once — and separate those from the ones that were decided on their own merits. Some may still be sitting open with no decision.

For the applications caught in that closeout, go down to the applicant level: trace each one to its individual applicants and work out how many of those applicants' KYC records never got resolved (never moved out of manual review), and how many of those applications had both applicants still stuck.

Work 32855 through as the example: its two linked applicants, their KYC statuses, and how long it spent in manual review before the final decision.

## Deliverables
1. /workspace/metrics.json with keys: sweep_date (YYYY-MM-DD), cohort_size, aged_out, resolved_before_sweep, still_manual_review, unresolved_person_kyc, both_applicants_unresolved, and days_in_manual_review (for application 32855).
2. /workspace/report.md: method, the cohort finding, the 32855 walkthrough, and a recommendation.

State your conclusion and key figures in your final reply too, so a reviewer can act without redoing the work.
