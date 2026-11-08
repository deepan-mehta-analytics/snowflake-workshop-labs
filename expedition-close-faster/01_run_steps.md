# Expedition 2026 Day 3 — Close Faster, Audit Smarter: run steps

Run in the existing trial account (AWS Tokyo), signed in to Snowsight. Tick each box as you go.
Expected numbers come from the guide (`assets/close-faster-with-coco-and-cowork.md`, sfquickstarts `9c3f3e7`).
Notebook + app: `Snowflake-Labs/expedition-2026-day-3-hol` `a668480`. Public grader: builder-workshops `expedition/close-faster-coco.sql` `b36d3c9` (BWEF01–05, objects only).

**Before you start**
- Budget: about 2–4 credits (≈ $7–14), mostly CoCo, CoWork and the two container runtimes.
- Two things keep billing after you stop clicking: the notebook service and the Streamlit runtime. Section G stops both.
- Grade once only: section F runs the grader **in full** (Run All) a single time.
- The grader checks objects only (database, 5 Iceberg tables, semantic view, agent). The dashboard and CoWork questions are for learning, not graded.

---

## A. Pre-flight (5 min)

1. Projects → Worksheets → **+** → SQL Worksheet.
2. Paste `00_preflight_checks.sql`.
3. Run each statement with **Ctrl+Enter**, one at a time, and note the results:
   - [ ] `MERIDIAN_STAY_FINANCE` database: 0 rows
   - [ ] `GITHUB_MERIDIAN_FINANCE_LAB` integration: 0 rows
   - [ ] `CORTEX_ENABLED_CROSS_REGION` = `AWS_US`
   - [ ] `GRADER` function: 1 row
   - [ ] Services: write down the names currently listed (baseline)

## B. Git workspace + notebook (10 min)

1. Left menu → **Projects** → **Workspaces**.
2. Click the **+** next to the workspace name (top left) → **Create new Git workspace**.
3. In the dialog:
   1. **Repository URL:** `https://github.com/Snowflake-Labs/expedition-2026-day-3-hol`
   2. Pasting the URL auto-fills the **Workspace name** (`expedition-2026-day-3-hol`) and picks an existing **API integration** if one allows `https://github.com/Snowflake-Labs`. Keep both; the grader doesn't check the integration.
      - Only if none is picked: **+ API Integration** → Name `GITHUB_MERIDIAN_FINANCE_LAB`, Allowed prefixes `https://github.com/Snowflake-Labs` → Create.
   3. Click the **Public repository** box (the default, Personal access token, fails for this public repo).
   4. Click **Create**.
4. In the file tree on the left, click **lab.ipynb**.
5. Next to **Run**, click **Connect** → **Create and connect**.
   - If a **Service settings** panel appears, set the **idle timeout to 1 hour** (the default is 24 h and keeps billing).
   - Wait until the status bar at the bottom says **Connected**.
6. At the top of the notebook, set **Role = ACCOUNTADMIN**, **Warehouse = COMPUTE_WH**.

## C. Notebook cells (25 min)

**C1 — `setup` cell. Change one line before running it.**
The last line, `ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';`, widens an account-wide setting. This account already uses `AWS_US` and the grader does not check it.
1. Put `-- ` at the start of that last line so it reads `-- ALTER ACCOUNT SET ...`.
2. Run the cell. Expect **Statement executed successfully**.
   - [ ] Done
   - Fallback: if CoCo or the agent later errors with "model not available in your region", remove the `-- `, run that line, and remember teardown step D.

**C2 — `raw_tables` cell.** Run. Expect success (3 Iceberg tables, file format, stage).
- [ ] Done

**C3 — `upload_files` (Python) cell.** Run. Expect three lines ending in **UPLOADED**.
- [ ] Done

**C4 — STEP 1 (CoCo): load the exports.**
1. Open the CoCo panel from the Workspace toolbar.
2. Paste:
   ```
   Load the three CSV files in the stage @MERIDIAN_STAY_FINANCE.RAW.FINANCIAL_EXPORTS into their matching Iceberg tables in MERIDIAN_STAY_FINANCE.RAW: payroll_register.csv into PAYROLL_REGISTER, gl_journal_entries.csv into GL_JOURNAL_ENTRIES, and bank_statement.csv into BANK_STATEMENT. Use the file format MERIDIAN_STAY_FINANCE.RAW.CSV_FF and load the columns in file order.
   ```
3. Compare with the notebook's expected output (markdown cell above the empty `copy_raw` cell) → **Allow**.
4. Expect **13, 18, 18** rows loaded.
   - [ ] 13 / 18 / 18

**C5 — `peek_raw` cell.** Run. Expect 49 rows. Optional: spot the duplicate payroll row (EMP-102 on 11/15) and JE-2013/JE-2014.

**C6 — STEP 2 (CoCo): find the mess.** In the same CoCo chat, paste:
```
Compare how the three tables in MERIDIAN_STAY_FINANCE.RAW record departments and expense categories. Map every label to one of these standard values:

- Department: Front Desk, Food & Beverage, Housekeeping, Management, Spa & Wellness, Operations, Facilities, Marketing, Admin, Finance
- Category: Payroll, Utilities, Maintenance, Marketing, Travel, Office Supplies, Insurance, Professional Services

Also point out how dates and amounts are formatted differently, and any rows that should be excluded (duplicates, reversed entries).
```

- [ ] CoCo maps `F&B` → Food & Beverage, `MGMT` → Management, `MISC` → Office Supplies, and names the EMP-102 duplicate and JE-2014 reversing JE-2013

**C7 — STEP 3 (CoCo): build CURATED.TRANSACTIONS.** Same chat, paste:
```
Using that mapping, create a Snowflake-managed Iceberg table MERIDIAN_STAY_FINANCE.CURATED.TRANSACTIONS (EXTERNAL_VOLUME = 'SNOWFLAKE_MANAGED') that combines the three raw tables into one transaction ledger:
- Columns: transaction_id, transaction_date, description, amount, department, category, source_system, reference_id
- Convert all dates to DATE type and all amounts to NUMBER(12,2) — make debits positive (absolute value)
- Map department names and category codes to the standard values
- Set source_system to 'Payroll Register', 'General Ledger', or 'Bank Statement'
- Exclude reversed GL entries (status = 'Reversed') and the original entries they cancel (a reversal's reference_id is the original's reference_id plus '-R')
- Remove the duplicate payroll row (same employee, same date, same reference_id — keep one)
- For the bank statement, set category to 'Uncategorized' and department to 'Unknown' since those fields aren't in the export
- Set category to 'Payroll' for every payroll register row, so no row has an empty category.
- Do not infer department or category for bank rows from their descriptions; every bank row must be 'Unknown' / 'Uncategorized'.
```
The last two lines are additions to the guide's prompt. The payroll export has no category column, and the grader fails on any empty category. In STEP 2, CoCo inferred a department and category for every bank row from its description; carried into STEP 3, that removes Unknown / Uncategorized and gives 10 departments / 8 categories instead of 11 / 9. Before **Allow**, check that the bank rows get literal `'Unknown'` / `'Uncategorized'`.

**Allow**, then run the **`check_transactions`** cell. Expect exactly:

| transactions | source_systems | source_system_names | categories | departments |
|---|---|---|---|---|
| 46 | 3 | Bank Statement, General Ledger, Payroll Register | 9 | 11 |

- [ ] Matches. If not, use a fix-up prompt (ask CoCo, don't hand-edit):
  - More than 46: *"Which transactions appear more than once in MERIDIAN_STAY_FINANCE.CURATED.TRANSACTIONS? Fix the duplicate removal, and make sure both JE-2013 and its reversal JE-2014 are excluded."*
  - Fewer than 46: *"Are all 12 unique payroll rows, 16 GL entries, and 18 bank rows included?"*
  - Wrong names: *"Set source_system to exactly 'Payroll Register', 'General Ledger', or 'Bank Statement'."*
  - Last resort: paste the notebook's expected output into the empty `transactions` cell and run it.

**C8 — `before_after` cell.** Run. Optional review (PAY-1007 kept once, JE-2013/JE-2014 gone).

**C9 — STEP 4 (CoCo): reconciliation gaps.** Paste:
```
Create a Snowflake-managed Iceberg table MERIDIAN_STAY_FINANCE.CURATED.RECONCILIATION_GAPS (EXTERNAL_VOLUME = 'SNOWFLAKE_MANAGED') that identifies every bank transaction in CURATED.TRANSACTIONS with source_system = 'Bank Statement' that has no matching GL entry (source_system = 'General Ledger') with the same amount and a posting date within 3 days. Include:
- Columns: gap_id, transaction_id, transaction_date, description, amount, source_system, gap_type, notes
- Set gap_type to 'Bank Only - No GL Match'
- Set notes to 'No corresponding general ledger entry found within 3 days'
```

**Allow**, then run **`check_gaps`**.
- [ ] **2 gaps**, **$47,200**: BK-3006 $47,000 (2026-11-12, ballroom renovation wire) + BK-3018 $200 (2026-11-30, service fee)

## D. Reconciliation dashboard (10 min)

1. In the file tree, open **reconciliation_dashboard/streamlit_app.py**.
2. If a banner says the app is missing configuration → **Convert to streamlit app**.
3. Click **Run**. Expect 16 of 18 matched (89%), **Not Ready**, $47,200 unreconciled, waterfall with 2 red bars.
   - [ ] Dashboard shows
4. STEP 5 (CoCo), with the app file open, paste:
   ```
   Add a payroll tie-out below the gap cards. For each pay date, compare the payroll register total to the GL payroll batch (salaries only, not benefits), and show whether they match.
   ```
5. Review the proposed changes (it should **add** a section, not rewrite the app) → accept → **Run** again.
   - [ ] Tie-out: Nov 1 $23,900 · Nov 15 $25,150 · Nov 30 $5,000, all $0.00 difference
   - If the GL column is empty: *"The GL payroll batches have a reference ID starting with PAY-BATCH."*
6. **Do not click Deploy** (optional, not graded, adds another object).

## E. Semantic view, agent, CoWork (20 min)

**E1 — Semantic view**
1. Left menu → **AI** → **Cortex Analyst**.
2. Top right → **Create with Autopilot in Workspaces** (opens a new tab) → **Create with CoCo**. Start a fresh CoCo chat (**+**) if the panel still shows the notebook conversation. If CoCo asks for name, location and tables, answer with the prompt below.
3. Paste into CoCo:
   ```
   Create the semantic view with these details:
   - Name: CLOSE_RECONCILIATION_SV
   - Location: MERIDIAN_STAY_FINANCE.ANALYTICS
   - Source tables: MERIDIAN_STAY_FINANCE.CURATED.TRANSACTIONS and MERIDIAN_STAY_FINANCE.CURATED.RECONCILIATION_GAPS
   - Use transaction_id as the unique key for TRANSACTIONS and gap_id as the unique key for RECONCILIATION_GAPS, and add clear descriptions and synonyms for category, department, and source_system
   - Give SOURCE_SYSTEM its own description on each table. On TRANSACTIONS, use: 'System the transaction came from. The payroll register, general ledger, and bank statement record the same money, so spending totals should use only General Ledger rows.'
   - Make AMOUNT a fact on both TRANSACTIONS and RECONCILIATION_GAPS
   - Make TRANSACTION_DATE a time dimension on both TRANSACTIONS and RECONCILIATION_GAPS
   - Add this verified query for "Are there any reconciliation gaps for November 2026?": SELECT transaction_id, transaction_date, description, amount, gap_type, notes FROM MERIDIAN_STAY_FINANCE.CURATED.RECONCILIATION_GAPS ORDER BY amount DESC
   ```
4. **Allow** the draft. In the editor, check each table:
   - TRANSACTIONS: key `TRANSACTION_ID`, fact `AMOUNT`, time dimension `TRANSACTION_DATE`, synonyms on `CATEGORY` / `DEPARTMENT`, `SOURCE_SYSTEM` description with the General Ledger note
   - RECONCILIATION_GAPS: key `GAP_ID`, fact `AMOUNT`, time dimension `TRANSACTION_DATE`
   - 1 verified query
   - Fix before publishing (ask CoCo): e.g. `AMOUNT` under Dimensions → *"Make AMOUNT a fact on both tables."*
5. CoCo writes the YAML into the file and validates it with `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)` (validation only). It may offer to add a date filter to the verified query; decline, to keep the guide's SQL.
6. Deploy: either top right → **Deploy** (the guide's "Publish"), or confirm CoCo's `cortex agent-studio sv-deploy … --fqn MERIDIAN_STAY_FINANCE.ANALYTICS.CLOSE_RECONCILIATION_SV`.
   - [ ] Published

**E2 — Agent**
1. **AI & ML** → **Agent Studio** → top right **Create agent**.
2. **Database and schema:** `MERIDIAN_STAY_FINANCE.ANALYTICS` · **Agent object name:** `CLOSE_RECONCILIATION_AGENT` → **Create**.
3. Click **Configuration** → **General** tab:
   - **Description:**
     ```
     I am the Meridian Stay Close Reconciliation Agent. I answer questions about the November 2026 month-end close across payroll, the general ledger, and the bank statement, flag reconciliation gaps, and help the finance team close faster.
     ```
   - **Example questions** (one per line):
     ```
     Are there any reconciliation gaps for November 2026? If so, what's the total dollar amount?

     What's the largest discrepancy, and which systems does it involve?

     Show me total general ledger spending by category for November 2026.
     ```
4. **Instructions** tab:
   - **Orchestration instructions:**
     ```
     Whenever you can answer visually with a chart, always choose to generate a chart even if the user didn't ask for one. The payroll register, general ledger, and bank statement record the same money, so for spending totals use only General Ledger entries.
     ```
   - **Response instructions:**
     ```
     Give concise, accurate answers for finance operations. Name specific transactions and include dates, amounts, and source systems when relevant. Always express monetary amounts in USD.
     ```
5. **Tools** → **Add semantic view**:
   - **Service database & schema:** `MERIDIAN_STAY_FINANCE.ANALYTICS`
   - **Select semantic view:** `CLOSE_RECONCILIATION_SV`
   - **Name:** `CLOSE_RECONCILIATION_ANALYST`
   - **Description:** `Answers questions about Meridian Stay's November 2026 month-end close reconciliation, transactions, and discrepancies`
   - If a **warehouse** field shows, pick `COMPUTE_WH`; if there is a **Query timeout**, enter `60` (Agent Studio drops an empty warehouse otherwise).
   - **Add**.
6. Top right **Save** (and **Publish** if the button is shown).
   - [ ] Saved

**E3 — CoWork questions (not graded).** **AI** → **Snowflake CoWork** → pick **CLOSE_RECONCILIATION_AGENT**. If CoWork isn't enabled in the account (**Enable CoWork** page, **Open CoWork** greyed out), skip this step. Otherwise ask in one conversation:
1. Are there any reconciliation gaps for November 2026? If so, what's the total dollar amount? → **2 gaps, $47,200**
2. How much cash left the bank in November, and how much did the general ledger record? Does the difference match the reconciliation gaps? → **$211,960 vs $164,760, difference $47,200**

The guide's other three questions (wire details, will it recur, GL spending chart → Payroll $63,860 / Marketing $27,000 / Maintenance $25,200, controller email) are optional — each costs agent credits.

## F. Grade (once, Run All)

1. Northstar → **Auto-Grader** → pick the Day 3 lab → enter the **same email as your Northstar registration** → generate.
2. Save the generated script as `expedition-close-faster/autograder_bwef.local.sql` (gitignored). Tell Claude, who diffs it against the public copy and runs `90_verify_grader_checks.sql` with you first (expect 5 × TRUE).
3. New SQL worksheet → paste the whole script → **select all** → **Run All**, once.
4. Claude proves submission from query history.

## G. Stop billing + teardown (after F is proven)

1. Notebook: **Shut down kernel**, then close the Streamlit app tab. In this run the personal notebook service still showed `RUNNING` afterwards, so section B's `ALTER SERVICE … SUSPEND` was needed.
2. Run `99_teardown.sql` section A, then B for each new lab service, then C and E.
3. If you used the C1 fallback, run D as well.
   - [ ] Services suspended · database + integration gone · setting `AWS_US`
4. Workspace: you can delete the `finance-close` workspace (⋯ → Delete).
