# Expedition 2026 Day 2 — Campaign Planning: run steps

Run in the existing trial account (AWS Tokyo), signed in to Snowsight. Tick each box as you go.
Expected numbers come from the guide (`assets/campaign-planning-with-coco-and-cowork.md`).

**Before you start**
- Budget: about 2–4 credits (≈ $7–14) for the whole lab, mostly CoCo, CoWork and the two container runtimes.
- Two things keep billing after you stop clicking: the notebook service and the Streamlit runtime. Section G stops both.
- Grade once only: section F runs the grader **in full** (Run All) a single time.

---

## A. Pre-flight (5 min)

1. Projects → Worksheets → **+** → SQL Worksheet.
2. Paste `00_preflight_checks.sql`.
3. Run each statement with **Ctrl+Enter**, one at a time, and note the results:
   - [ ] `MERIDIAN_STAY` database: 0 rows
   - [ ] `GITHUB_MERIDIAN_LAB` integration: 0 rows
   - [ ] `CORTEX_ENABLED_CROSS_REGION` = `AWS_US`
   - [ ] `GRADER` function: 1 row
   - [ ] Services: write down the names currently listed (baseline)

## B. Git workspace + notebook (10 min)

1. Left menu → **Projects** → **Workspaces**.
2. Click the **+** next to the workspace name (top left) → **Create new Git workspace** (wording may be "From Git repository").
3. In the dialog:
   1. **Repository URL:** `https://github.com/Snowflake-Labs/expedition-2026-day-2-hol`
   2. Pasting the URL auto-fills the **Workspace name** (`expedition-2026-day-2-hol`) and picks an existing **API integration** if one allows `https://github.com/Snowflake-Labs` (here `SNOWFLAKE_LABS_SI_GIT_API_INTEGRATION`). Keep both.
      - Only if none is picked: **+ API Integration** → Name `GITHUB_MERIDIAN_LAB`, Allowed prefixes `https://github.com/Snowflake-Labs` → Create.
   3. Click the **Public repository** box. The default, **Personal access token**, fails with "The Repository URL is not supported by this API integration". The note that you can't commit or push is expected.
   4. Click **Create**.
4. In the file tree on the left, click **lab.ipynb**.
5. Next to **Run**, click **Connect** → **Create and connect**.
   - If a **Service settings** panel appears, set the **idle timeout to 1 hour** (the default is 24 h and keeps billing).
   - Wait until the status bar at the bottom says **Connected**.
6. At the top of the notebook, set **Role = ACCOUNTADMIN**, **Warehouse = COMPUTE_WH**.

## C. Notebook cells (25 min)

**C1 — `setup` cell. Change one line before running it.**
The last line, `ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';`, widens an account-wide setting.
This account already uses `AWS_US`, which CoCo and CoWork worked with in earlier labs, and the grader does not check it.
1. Put `-- ` at the start of that last line so it reads `-- ALTER ACCOUNT SET ...`.
2. Run the cell. Expect **Statement executed successfully**.
   - [ ] Done
   - Fallback: if CoCo or the agent later errors with "model not available in your region", remove the `-- `, run that line, and remember teardown step D.

**C2 — `raw_tables` cell.** Run. Expect success.
- [ ] Done

**C3 — `upload_files` (Python) cell.** Run. Expect three lines ending in **UPLOADED**.
- [ ] Done

**C4 — STEP 1 (CoCo): load the exports.**
1. Open the CoCo panel from the Workspace toolbar.
2. Paste:
   ```
   Load the three CSV files in the stage @MERIDIAN_STAY.RAW.CAMPAIGN_EXPORTS into their matching Iceberg tables in MERIDIAN_STAY.RAW: paid_media_export.csv into PAID_MEDIA_EXPORT, email_sms_export.csv into EMAIL_SMS_EXPORT, and crm_campaigns_export.csv into CRM_CAMPAIGNS_EXPORT. Use the file format MERIDIAN_STAY.RAW.CSV_FF and load the columns in file order.
   ```
3. Compare with the notebook's expected output → **Allow**.
4. Expect **16, 10, 7** rows loaded.
   - [ ] 16 / 10 / 7

**C5 — `peek_raw` cell.** Run. Expect 33 rows. Optional: look through the duplicates.

**C6 — STEP 2 (CoCo): find the mess.** In the same CoCo chat, paste:
```
Compare how the three tables in MERIDIAN_STAY.RAW label channel, region, and audience. Map every label to one of these standard values:

Channel: Paid Social, Paid Search, Display, Email, SMS
Region: North America, EMEA, APAC, LATAM, Global
Audience: Leisure Travelers, Business Travelers, Families, Loyalty Members, Meeting Planners, Wellness Seekers, All Guests

Also point out how dates and budgets are formatted differently, and any campaigns whose status means they shouldn't be on the plan.
```

- [ ] CoCo names the cancelled *Veterans Day Weekend Blitz*

**C7 — STEP 3 (CoCo): build CURATED.CAMPAIGNS.** Same chat, paste:
```
Using that mapping, create a Snowflake-managed Iceberg table MERIDIAN_STAY.CURATED.CAMPAIGNS (EXTERNAL_VOLUME = 'SNOWFLAKE_MANAGED') that combines the three raw tables into one campaign list:

Columns: campaign_id, campaign_name, channel, region, audience, start_date, end_date, budget_usd, owner_team, status, source_system
Convert dates and budgets to real dates and numbers
Drop cancelled campaigns
Remove duplicates with the same name (ignoring case and extra spaces) and dates, keeping the ad platform or email & SMS copy over the CRM copy
Drop only campaigns with status Cancelled. Keep Draft campaigns such as CRM-7007 on the list.
```
The last line is an addition to the guide's prompt. In STEP 2, CoCo proposed leaving the Draft campaign CRM-7007 off the plan too, which gives 26 rows and fails the grader's 27.

**Allow**, then run the **`check_campaigns`** cell. Expect exactly:

| campaigns | unmapped_values | channels | regions | audiences |
|---|---|---|---|---|
| 27 | 0 | 5 | 5 | 7 |

- [ ] Matches. If it doesn't, use the guide's fix-up prompts, or paste the notebook's expected output into the empty `campaigns` cell and run it.

**C8 — `before_after` cell.** Run. Optional review.

**C9 — STEP 4 (CoCo): collisions.** Paste:
```
Create a Snowflake-managed Iceberg table MERIDIAN_STAY.CURATED.CAMPAIGN_COLLISIONS (EXTERNAL_VOLUME = 'SNOWFLAKE_MANAGED') listing every pair of campaigns in CURATED.CAMPAIGNS that target the same region and audience on overlapping dates. List each pair once.

Columns: campaign_a_id, campaign_a_name, campaign_b_id, campaign_b_name, region, audience, overlap_start, overlap_end, overlap_days, combined_budget_usd
```

**Allow**, then run **`check_collisions`**.
- [ ] **9 rows**, `total_combined_budget` = **557,500** (18 rows means each pair is listed twice: ask CoCo to "list each pair only once")

## D. Heatmap app (10 min)

1. In the file tree, open **campaign_timeline/streamlit_app.py**.
2. If a banner says the app is missing configuration → **Convert to streamlit app**.
3. Click **Run**. Expect "7 of 15" pairs at the top.
   - [ ] Heatmap shows
4. STEP 5 (CoCo), with the app file open, paste:
   ```
   Update this app to also load MERIDIAN_STAY.CURATED.CAMPAIGN_COLLISIONS. Below the title, add a red banner showing the number of collisions and their combined budget for the selected region. Below the heatmap, add a table of the collisions sorted by overlap start, with campaign A, campaign B, region, audience, overlap start, overlap end, and combined budget.
   ```
5. Review the proposed changes → accept → **Run** again.
   - [ ] Banner: **9 collisions, $557,500** (EMEA filter: 1, $63,000)
6. **Do not click Deploy** (optional, not graded, adds another object).

## E. Semantic view, agent, CoWork (20 min)

**E1 — Semantic view**
1. Left menu → **AI** → **Cortex Analyst**.
2. Top right → **Create with Autopilot in Workspaces** (opens a new tab) → **Create with CoCo**. Start a fresh CoCo chat (**+**) if the panel still shows the notebook conversation.
3. Paste into CoCo:
   ```
   Create the semantic view with these details:

   Name: CAMPAIGN_PLANNING_SV
   Location: MERIDIAN_STAY.ANALYTICS
   Source tables: MERIDIAN_STAY.CURATED.CAMPAIGNS and MERIDIAN_STAY.CURATED.CAMPAIGN_COLLISIONS
   Use campaign_id as the unique key for CAMPAIGNS, and add clear descriptions and synonyms for region, audience, and channel
   Make BUDGET_USD a fact on CAMPAIGNS, and make COMBINED_BUDGET_USD and OVERLAP_DAYS facts on CAMPAIGN_COLLISIONS
   Make START_DATE and END_DATE time dimensions on CAMPAIGNS, and OVERLAP_START and OVERLAP_END time dimensions on CAMPAIGN_COLLISIONS
   Add this verified query for "Which campaigns collide, and how much combined budget is involved?": SELECT campaign_a_name, campaign_b_name, region, audience, overlap_start, overlap_end, combined_budget_usd FROM MERIDIAN_STAY.CURATED.CAMPAIGN_COLLISIONS ORDER BY overlap_start
   ```
4. **Allow** the draft. In the editor, check each table:
   - CAMPAIGNS: key `CAMPAIGN_ID`, fact `BUDGET_USD`, time dimensions `START_DATE`, `END_DATE`
   - CAMPAIGN_COLLISIONS: facts `COMBINED_BUDGET_USD`, `OVERLAP_DAYS`, time dimensions `OVERLAP_START`, `OVERLAP_END`
   - 1 verified query
5. CoCo asks to run `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)`: a validation only (`TRUE`), safe to **Allow**. Then **Keep all**.
6. Top right → **Deploy** (the guide's "Publish") → confirm Name `CAMPAIGN_PLANNING_SV`, Database `MERIDIAN_STAY`, Schema `ANALYTICS`. Success: the right panel lists the view and the bottom bar says **Valid semantic view**. Leave the Suggestions panel's extra relationship and verified queries unaccepted.
   - [ ] Published

**E2 — Agent**
1. **AI & ML** → **Agent Studio** → top right **Create agent**.
2. **Database and schema:** `MERIDIAN_STAY.ANALYTICS` · **Agent object name:** `CAMPAIGN_PLANNING_AGENT` → **Create**.
3. Click **Configuration** → **General** tab:
   - **Description:**
     ```
     I am the Meridian Stay Campaign Planning Agent. I answer questions about planned marketing campaigns across every channel, region, and audience, and I flag campaigns that target the same audience at the same time.
     ```
   - **Example questions** (one per line):
     ```
     Which campaigns collide over the same audience between November 2026 and January 2027, and how much combined budget is involved?

     Which collisions are happening in November 2026?

     What's launching in APAC in January 2027?
     ```
4. **Instructions** tab:
   - **Orchestration instructions:**
     ```
     Whenever you can answer visually with a chart, always choose to generate a chart even if the user didn't ask for one.
     ```
   - **Response instructions:**
     ```
     Give concise, accurate answers for marketing planners. Name campaigns explicitly and include dates, budgets, and owner teams when relevant.
     ```
5. **Tools** → **Add semantic view**:
   - **Service database & schema:** `MERIDIAN_STAY.ANALYTICS`
   - **Select semantic view:** `CAMPAIGN_PLANNING_SV`
   - **Name:** `CAMPAIGN_PLANNING_ANALYST`
   - **Description:** `Answers questions about Meridian Stay's planned campaigns and audience collisions`
   - If a **warehouse** field shows, pick `COMPUTE_WH`; if there is a **Query timeout**, enter `60` (Agent Studio drops an empty warehouse otherwise).
   - **Add**.
6. Top right **Save** (and **Publish** if the button is shown).
   - [ ] Saved

**E3 — CoWork questions (not graded).** **AI** → **Snowflake CoWork** → pick **CAMPAIGN_PLANNING_AGENT**. If the page shows **CoWork admin → Enable CoWork** and **Open CoWork** is greyed out, CoWork isn't enabled in the account; skip this step rather than enabling an account-wide feature. Otherwise ask in one conversation:
1. Which campaigns collide over the same audience between November 2026 and January 2027, and how much combined budget is involved? → **9, $557,500**
2. Which of those collisions are in November 2026? Chart them by region and audience. → **5**
3. Do the Loyalty Double Points Month and Black Friday Mega Sale campaigns overlap? For how many days, and what's the combined budget? → **11 days, $97,000**

The guide's other two questions are optional (each question costs agent credits).

## F. Grade (once, Run All)

1. Northstar → **Auto-Grader** → pick the Day 2 lab → enter the **same email as your Northstar registration** → generate.
2. Save the generated script as `expedition-campaign-planning/autograder_bwem.local.sql` (gitignored). Tell Claude, who diffs it against the public copy and runs `90_verify_grader_checks.sql` with you first.
3. New SQL worksheet → paste the whole script → **select all** → **Run All**, once.
4. Claude proves submission from query history.

## G. Stop billing + teardown (after F is proven)

1. Notebook: **Shut down kernel**, then close the Streamlit app tab. The lab may reuse your existing personal notebook service (`USER$<you>.PUBLIC.<you>_SERVICE_1`) instead of creating a new one; check its status in section A of the teardown either way.
2. Run `99_teardown.sql` section A, then B for each new lab service, then C and E.
3. If you used the C1 fallback, run D as well.
   - [ ] Services suspended · database + integration gone · setting `AWS_US`
4. Workspace: you can delete the `campaign-planning` workspace (⋯ → Delete).
