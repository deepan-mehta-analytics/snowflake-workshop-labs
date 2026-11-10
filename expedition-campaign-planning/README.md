# Expedition 2026 Day 2 — Campaign Planning, Simplified: Build It with CoCo, Ask It with CoWork

Credential: [*Campaign Planning, Simplified: Build It with CoCo, Ask It with CoWork*](https://developerbadges.snowflake.com/7c5056dc-f523-4c3f-ba3f-0c8549aa3734) — issued 2026-11-08 by Snowflake Marketing (verifiable on Accredible).

Guide: https://www.snowflake.com/en/developers/guides/campaign-planning-with-coco-and-cowork/

Sources (verified real):
- Guide source: `Snowflake-Labs/sfquickstarts`, `site/sfguides/src/campaign-planning-with-coco-and-cowork/` at `ce00a69`
- Notebook and app: `Snowflake-Labs/expedition-2026-day-2-hol` at `16cf01b`

The lab is set at **Meridian Stay**, a fictional hotel brand whose marketing campaigns live in three systems
(ad platforms, email & SMS, CRM). It runs in a Git-backed Snowflake Workspace:

1. **Land** three messy campaign exports, unchanged, in Snowflake-managed Apache Iceberg tables
2. **Clean** them with Cortex Code (CoCo) into one deduplicated campaign list, also Iceberg
3. **Find collisions**: pairs of campaigns aimed at the same region and audience on overlapping dates
4. **Ask** about the plan in plain language through a semantic view and a Cortex Agent

## Files in this folder

- `assets/campaign-planning-with-coco-and-cowork.md`, `assets/lab.ipynb`, `assets/streamlit_app.py`:
  the guide source, the notebook and the heatmap app, kept verbatim.
- `00_preflight_checks.sql`: read-only checks to run before the lab. It checks for name collisions,
  shows the account setting the notebook's setup cell changes, and records which container services
  already exist.
- `01_run_steps.md`: the click-by-click checklist (sections A–G), with every CoCo prompt ready to paste
  and the expected numbers.
- `99_teardown.sql`: suspends the notebook service and drops everything the lab created.

Two grader-related files stay local and are gitignored:

- The personalised grader script (`*.local.sql`), because it contains the registration email.
- A dry-run copy of the grader's checks (`*verify_grader*.sql`) that submits nothing. It reproduces the
  answer key, so it isn't published.

## Steps (summary; full detail in `01_run_steps.md`)

1. **Pre-flight:** run `00_preflight_checks.sql` one statement at a time.
2. **Git workspace:** create it from the companion repo with **Public repository** authentication.
3. **Notebook:** connect, then run the `setup` cell **with its last line commented out** (see below).
4. **CoCo steps 1–4:** load the exports (16 / 10 / 7 rows), map the labels, build `CURATED.CAMPAIGNS`
   (27 rows) and `CURATED.CAMPAIGN_COLLISIONS` (9 pairs, $557,500).
5. **Semantic view and agent:** `CAMPAIGN_PLANNING_SV` created with CoCo, then
   `CAMPAIGN_PLANNING_AGENT` in Agent Studio.
6. **Grader:** a local dry run of the grader's checks first, then the grader script once, in full,
   with Run All.
7. **Teardown:** suspend the notebook service, drop the database.

### Account setting left unchanged

The notebook's `setup` cell ends with `ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'`.
This account already allows `AWS_US`, which CoCo and the agent worked with, and the grader doesn't check
the setting. The line was commented out before the cell ran, and the setting was confirmed as `AWS_US`
afterwards.

## Status

**Complete.** All auto-grader checks (BWEM01–05) passed on 2026-11-08 (UTC), in a single Run All, and the credential was issued the same day. Query
history confirms the greeting and all six `grader()` calls (`AUTO_GRADER_IS_WORKING` plus BWEM01–05)
succeeded. A local dry run of the same checks matched 5/5 beforehand.

| Check | What it verifies | Result |
|---|---|---|
| BWEM01 | `MERIDIAN_STAY` with `RAW`, `CURATED`, `ANALYTICS` schemas | ✅ |
| BWEM02 | 3 raw Iceberg tables with 16 / 10 / 7 rows | ✅ |
| BWEM03 | `CURATED.CAMPAIGNS`: Iceberg, 27 rows, no empty values, 5 channels / 5 regions / 7 audiences, no cancelled campaign, no duplicates | ✅ |
| BWEM04 | `CURATED.CAMPAIGN_COLLISIONS`: Iceberg, 10 named columns, 9 rows, $557,500, 5 starting in November 2026 | ✅ |
| BWEM05 | semantic view `CAMPAIGN_PLANNING_SV` and agent `CAMPAIGN_PLANNING_AGENT` | ✅ |

## Results

### From 33 raw rows to 27 campaigns

| Step | Rows |
|---|---|
| Loaded (ad platforms 16 + email & SMS 10 + CRM 7) | 33 |
| Cancelled campaign dropped (CRM-7006, Veterans Day Weekend Blitz) | −1 |
| Exact duplicates in the ad export (PM-1001, PM-1009) | −2 |
| CRM copies of ad campaigns, matched by name (ignoring case and spaces) and dates | −3 |
| **Curated campaigns** | **27** |

The CRM export is the only one with a status column, and it holds one **Draft** campaign (CRM-7007).
CoCo's label analysis listed it as "not approved yet" and proposed leaving it off the plan. The guide drops
only cancelled campaigns, and dropping the draft as well gives 26 rows, so the build prompt carried one
extra line: drop only status Cancelled, keep Draft campaigns.

### Collisions

| Region / audience | Pairs | Combined budget |
|---|---|---|
| North America / Business Travelers | 3 (Nov 9–30, three campaigns overlapping) | $178,000 |
| North America / Leisure Travelers | 1 | $77,000 |
| North America / Loyalty Members | 1 (Loyalty Double Points × Black Friday, 11 days) | $97,000 |
| North America / Families | 1 | $47,500 |
| EMEA / Leisure Travelers | 1 | $63,000 |
| APAC / Families | 1 | $40,000 |
| APAC / Leisure Travelers | 1 (Tokyo × Sydney) | $55,000 |
| **Total** | **9** | **$557,500** |

CoCo pointed out that the APAC leisure pair (Tokyo Cherry Blossom Preview × Sydney Summer Kickoff) only
collides because both are tagged APAC; they target different cities. The lab's rule (same region and
audience, overlapping dates) counts it, and so does the grader.

## Cost

Measured from `ACCOUNT_USAGE.METERING_HISTORY` by hour (04:00–06:59 UTC on 2026-11-08):

| Item | What ran | Credits |
|---|---|---|
| CoCo (`SNOWFLAKE_COCO_SNOWSIGHT`) | about 8 prompts, plus the semantic view build and its validation runs | 1.57 |
| Warehouses | X-Small `COMPUTE_WH` (notebook cells, check cells, grader) 0.57, plus the account's default `DASH_WH_SI` 0.38 | 0.95 |
| Notebook service | about 2 hours 15 minutes on the X-Small CPU pool (connected 20:30 PST, suspended 22:44 PST) | 0.26 |
| **Total** | | **≈ 2.79 credits ≈ $8.90** |

The dollar figure applies that day's billed rate: both Expedition labs ran on 2026-11-08 (UTC), which billed
4.62 credits for $14.70 (≈ $3.18 per credit). CoCo was the largest single cost.

## Known limitations and run notes

- **Not run here:** the heatmap app (section D) and the CoWork questions (section E3). Neither is graded.
  CoWork wasn't enabled in this account, and turning it on is an account-wide change, so the agent was
  built but not queried.
- **The Git workspace needs Public repository authentication.** The dialog auto-fills an existing API
  integration and defaults to **Personal access token**. With that default it reported "The Repository
  URL is not supported by this API integration". Choosing **Public repository** fixed it, and the
  existing Snowflake-Labs integration was used instead of creating a new one.
- **Snowsight names differ from the guide.** Analyst's "Create with CoCo" is now **AI → Cortex Analyst →
  Create with Autopilot in Workspaces → Create with CoCo**, and the semantic view editor's "Publish" is
  **Deploy**. Agent Studio's Publish creates a numbered version.
- **CoCo validates before it writes.** It asks to run `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)`,
  which checks the YAML without creating anything. After deploy, the editor's Suggestions panel offered an
  extra relationship and three verified queries; they weren't accepted, to keep the view as the guide
  defines it.
- **Notebook compute:** the lab reused the account's existing personal notebook service rather than
  creating a new one. After **Shut down kernel** it showed `SUSPENDED` in `SHOW SERVICES`. On Day 3 the
  same step left it `RUNNING`, so always check (see `../expedition-close-faster/`).
- **Run All, not Run.** The first dry run used **Run**, which executes only the statement under the
  cursor, so the grader's temporary lookup tables didn't exist. Select all + **Run All** worked.
