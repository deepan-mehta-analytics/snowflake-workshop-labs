# Expedition 2026 Day 3 — Close Faster, Audit Smarter: Build It with CoCo, Ask It with CoWork

Credential: [*Close Faster, Audit Smarter: Build It with CoCo, Ask It with CoWork*](https://developerbadges.snowflake.com/5c685561-252e-409a-8909-0396318e0327) — issued 2026-11-08 by Snowflake Marketing (verifiable on Accredible).

Guide: https://www.snowflake.com/en/developers/guides/close-faster-with-coco-and-cowork/

Sources (verified real):
- Guide source: `Snowflake-Labs/sfquickstarts`, `site/sfguides/src/close-faster-with-coco-and-cowork/` at `9c3f3e7`
- Notebook and dashboard: `Snowflake-Labs/expedition-2026-day-3-hol` at `a668480`

Same fictional hotel brand as Day 2, **Meridian Stay**, now closing its November 2026 books. Payroll, the
general ledger (GL) and the bank statement disagree, and last quarter a $47,000 wire was never journaled.
The lab runs in a Git-backed Snowflake Workspace:

1. **Land** three messy financial exports, unchanged, in Snowflake-managed Apache Iceberg tables
2. **Clean** them with Cortex Code (CoCo) into one transaction ledger, also Iceberg
3. **Match** every bank payment against the GL and record each one with no match as a reconciliation gap
4. **Ask** close-cycle questions in plain language through a semantic view and a Cortex Agent

## Files in this folder

- `assets/close-faster-with-coco-and-cowork.md`, `assets/lab.ipynb`, `assets/streamlit_app.py`:
  the guide source, the notebook and the reconciliation dashboard, kept verbatim.
- `00_preflight_checks.sql`: read-only checks to run before the lab (name collisions, the account setting
  the setup cell changes, the grader helper, existing container services).
- `01_run_steps.md`: the click-by-click checklist (sections A–G), with every CoCo prompt ready to paste
  and the expected numbers.
- `99_teardown.sql`: suspends the notebook service and drops everything the lab created.

Two grader-related files stay local and are gitignored: the personalised grader script (`*.local.sql`,
contains the registration email) and a dry-run copy of its checks (`*verify_grader*.sql`, reproduces the
answer key).

## Steps (summary; full detail in `01_run_steps.md`)

1. **Pre-flight:** run `00_preflight_checks.sql` one statement at a time.
2. **Git workspace:** create it from the companion repo with **Public repository** authentication.
3. **Notebook:** connect, then run the `setup` cell with its last line, `ALTER ACCOUNT SET
   CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'`, commented out. The account stays on `AWS_US`, as on Day 2.
4. **CoCo steps 1–4:** load the exports (13 / 18 / 18 rows), map departments and categories, build
   `CURATED.TRANSACTIONS` (46 rows) and `CURATED.RECONCILIATION_GAPS` (2 gaps, $47,200).
5. **Semantic view and agent:** `CLOSE_RECONCILIATION_SV` created with CoCo, then
   `CLOSE_RECONCILIATION_AGENT` in Agent Studio.
6. **Grader:** local dry run first, then the grader script once, in full, with Run All.
7. **Teardown:** suspend the notebook service, drop the database.

## Status

**Complete.** All auto-grader checks (BWEF01–05) passed on 2026-11-08 (UTC), in a single Run All, and the credential was issued the same day. Query
history confirms the greeting and all six `grader()` calls (`AUTO_GRADER_IS_WORKING` plus BWEF01–05)
succeeded. A local dry run of the same checks matched 5/5 beforehand.

| Check | What it verifies | Result |
|---|---|---|
| BWEF01 | `MERIDIAN_STAY_FINANCE` with `RAW`, `CURATED`, `ANALYTICS` schemas | ✅ |
| BWEF02 | 3 raw Iceberg tables with 13 / 18 / 18 rows | ✅ |
| BWEF03 | `CURATED.TRANSACTIONS`: Iceberg, 46 rows, no empty values, the 3 source system names, 9 categories, 11 departments, no reversed or cancelled entries | ✅ |
| BWEF04 | `CURATED.RECONCILIATION_GAPS`: Iceberg, 8 named columns, 2 gaps totalling $47,200 (BK-3006 + BK-3018) | ✅ |
| BWEF05 | semantic view `CLOSE_RECONCILIATION_SV` and agent `CLOSE_RECONCILIATION_AGENT` | ✅ |

## Results

### The ledger

| Source system | Raw rows | Kept | Total | Departments / categories |
|---|---|---|---|---|
| Payroll Register | 13 | 12 (duplicate PAY-1007 removed) | $54,050 | 5 departments / Payroll |
| General Ledger | 18 | 16 (JE-2014 reversal and the JE-2013 entry it cancels removed) | $164,760 | 6 departments / all 8 categories |
| Bank Statement | 18 | 18 | $211,960 | Unknown / Uncategorized |
| **Total** | 49 | **46** | | 11 departments / 9 categories |

The payroll export has no category column, and the bank export has neither department nor category. The
grader fails if any row is left empty, and it counts **Unknown** and **Uncategorized** as the 11th
department and 9th category. CoCo's label analysis went further than the guide and inferred a
department and category for every bank row from its description. So the build prompt carried two extra
lines: set category to Payroll on every payroll row, and keep every bank row as Unknown / Uncategorized.

### Reconciliation

| Gap | Transaction | Date | Amount | Description |
|---|---|---|---|---|
| 1 | BK-3006 | 2026-11-12 | $47,000.00 | WIRE TFR - GRAND BALLROOM RENOVATION DEPOSIT |
| 2 | BK-3018 | 2026-11-30 | $200.00 | MONTHLY ACCOUNT SERVICE FEE |

The bank paid out $211,960 and the GL recorded $164,760. The $47,200 difference is exactly the two gaps,
so they account for every dollar out of balance. The other 16 bank payments each matched a GL entry with
the same amount within 3 days.

## Cost

- **Notebook service:** about 50 minutes on the X-Small CPU pool (connected 22:57 PST, suspended 23:47 PST).
- **CoCo:** about 8 prompts, plus the semantic view build and its validation runs.
- **Warehouse:** X-Small `COMPUTE_WH` for the notebook cells, check cells and grader.
- **Total:** recorded from billing after the run; see the root README.

## Known limitations and run notes

- **Not run here:** the reconciliation dashboard and its CoCo payroll tie-out (STEP 5), and the CoWork
  questions. None of them is graded. CoWork wasn't enabled in this account, so the agent was built but not
  queried.
- **The guide's Git API integration wasn't created.** The workspace used the account's existing
  Snowflake-Labs integration with **Public repository** authentication (see Day 2's notes). The grader
  doesn't check the integration.
- **CoCo's matching SQL needed a rewrite.** For STEP 4 it first wrote a correlated subquery inside
  `CREATE ICEBERG TABLE … AS`, which Snowflake rejected. It rewrote it as a left join with the same rule
  (equal amount, dates no more than 3 days apart) and got the expected 2 gaps.
- **Semantic view built through CoCo's CLI.** CoCo wrote the YAML into the workspace file, validated it
  with `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)` and deployed it with `cortex agent-studio
  sv-deploy`. It suggested adding a November date filter to the verified query; the guide's SQL was kept
  as published.
- **Agent Studio:** the semantic view tool showed a **Query timeout** field, which was set to 60; Day 2's
  dialog showed none.
- **Notebook compute kept running after Shut down kernel.** `SHOW SERVICES` still showed the personal
  notebook service `RUNNING` afterwards, so it was stopped with `ALTER SERVICE … SUSPEND`. On Day 2 the
  same step had suspended it, so always check.
