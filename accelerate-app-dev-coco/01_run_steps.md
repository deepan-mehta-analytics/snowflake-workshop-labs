# Accelerate App Dev with CoCo — run checklist

Guide: https://www.snowflake.com/en/developers/guides/accelerate-app-dev-coco/
Vendor files (kept verbatim): `assets/accelerate-app-dev-cortex-code.md` (guide source) and
`assets/accelerate-app-dev-cortex-code.ipynb` (notebook), from
`Snowflake-Labs/sfquickstarts/site/sfguides/src/accelerate-app-dev-cortex-code/`. The notebook on
the workshop's resources page (Northstar, SWT Virtual APAC CoCo) is byte-identical (SHA-1 `c46a368…`).

**Rules for the whole run**
- Run the vendor code as published. Don't edit notebook cells.
- Object names must match exactly: the grader looks for `AI_WORKSHOP_DB`, `RAG_DATA`,
  `ANALYTICS`, `FEATURE_DOCS` (15 rows), `CHUNKED_DOCS`, `FEATURE_SEARCH_SERVICE` and
  `TPCH_ORDER_ANALYTICS`.
- **Don't run the grader until section F.** One of its statements reads
  `FEATURE_DOCS` directly, so if anything is missing, Run All stops at that error and the
  later checks are never submitted.

## A. Pre-flight (read-only)

1. Open `00_preflight_checks.sql` in a new SQL worksheet
2. Run each statement on its own (Ctrl+Enter) and note the results:
   - `AI_WORKSHOP_DB` / `WORKSHOP_WH`: expect 0 rows each
   - `ENABLE_PERSONAL_DATABASE` current value
   - `DEFAULT_SECONDARY_ROLES` row from `DESCRIBE USER`
   - region and `CORTEX_ENABLED_CROSS_REGION`
   - the 3 `COMPLETE` calls: each should return text, not an error
3. If any model call errors, stop and report it before going further. The notebook
   hard-codes those models.

## B. Setup worksheet (guide section "Set Up Your Environment")

1. Left pane → **+ (Create)** → **SQL File**
2. Top of the worksheet: role **ACCOUNTADMIN**
3. Paste and run, one statement at a time:

```sql
SELECT CURRENT_USER();                                       -- copy the value it returns
ALTER USER <paste_user_here> SET DEFAULT_SECONDARY_ROLES = ('ALL');  -- guide's literal CURRENT_USER must be replaced
USE SECONDARY ROLES ALL;                                     -- activate secondary roles in this session
ALTER ACCOUNT SET ENABLE_PERSONAL_DATABASE = TRUE;           -- personal database for private notebooks
CREATE DATABASE IF NOT EXISTS AI_WORKSHOP_DB;                -- workshop database (grader BWRA01)
CREATE SCHEMA IF NOT EXISTS AI_WORKSHOP_DB.RAG_DATA;         -- RAG schema (grader BWRA02)
CREATE SCHEMA IF NOT EXISTS AI_WORKSHOP_DB.ANALYTICS;        -- text-to-SQL schema (grader BWRA02)
USE DATABASE AI_WORKSHOP_DB;                                 -- set context
USE SCHEMA RAG_DATA;                                         -- set context
CREATE WAREHOUSE IF NOT EXISTS WORKSHOP_WH
  WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;  -- X-Small, suspends after 60s idle
USE WAREHOUSE WORKSHOP_WH;                                   -- set context
```

## C. CoCo demos (guide section "Snowflake CoCo")

1. Same worksheet → click the **✦ sparkle** icon on the right → CoCo panel opens
2. Paste prompt 1, send:
   > Create an internal stage in the AI_WORKSHOP_DB database and RAG_DATA schema called DOCS_STAGE with directory tables enabled and Snowflake SSE encryption.
3. Read the SQL it returns. It should be `CREATE OR REPLACE STAGE AI_WORKSHOP_DB.RAG_DATA.DOCS_STAGE`
   with `DIRECTORY = (ENABLE = TRUE)` and `ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')`. Run it.
4. Paste prompt 2, send (read the answer, nothing to run):
   > How do I use SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER to chunk text into pieces of 1500 characters with 200-character overlap?

## D. Notebook (guide sections "Upload the Workshop Notebook" → Module 3)

1. Left pane → **Projects → Workspaces**
2. **+ Add new → Upload files** → pick
   `snowflake-workshop-labs/accelerate-app-dev-coco/assets/accelerate-app-dev-cortex-code.ipynb`
3. Open the notebook → click **▾ next to Connect** → **Create new service**. In the dialog,
   expand **Service settings** → set **Idle timeout** to **1 hour** (default 24 hours). Leave
   Artifact repositories empty and distributed compute off → **Create and connect** → wait
4. Top bar: set **role** to `ACCOUNTADMIN` and **Warehouse** to `WORKSHOP_WH` (it may default
   to another lab's warehouse)
   - Upload into a workspace that **isn't git-linked**, or never commit from it: the notebook
     shows up as a pending change and connecting modifies `.gitignore`.
   - If any of these screens look different, send a screenshot before clicking further.
5. Run the **Setup** cell. Then hover just below it → **+ Python** to add **one new cell**, paste
   this and run it. It's the only non-vendor code in the run (see "Retired models" below):

```python
# ── Compatibility cell (added 2026-10-02, NOT vendor code) ───────────
# Snowflake retired mistral-large2 and llama3-70b ("legacy state" error).
RETIRED_MODELS = {'mistral-large2': 'llama3.3-70b',              # RAG answers, judge, naive text-to-SQL
                  'llama3-70b':     'llama3.3-70b'}              # Module 1 model comparison
_vendor_complete = complete                                      # keep the notebook's original helper
def complete(model, prompt):                                     # same signature the vendor cells call
    return _vendor_complete(RETIRED_MODELS.get(model, model), prompt)  # swap retired names, pass others through
Complete = complete                                              # vendor cells look up Complete at run time
print('Retired models redirected:', RETIRED_MODELS)              # visible proof the shim is active
```

6. Run the remaining cells **one by one, top to bottom** (the guide's tip). Expected output:

| Cell | Guide step | Expect |
|---|---|---|
| Setup | Setup | `Session ready.` with `AI_WORKSHOP_DB` / `RAG_DATA` / `WORKSHOP_WH` |
| Stage safety net | — | `Stage ready: ...DOCS_STAGE` |
| Module 1 Step 1 + comparison | First LLM call | short answers from `mistral-7b` and `llama3-70b` (served by `llama3.3-70b` via the compatibility cell) |
| Module 1 Step 2 | Hallucination | a guessed or hedged revenue figure |
| Module 1 Step 3 | Grounded answer | top 5 TPC-H customers + an answer drawn from them |
| Module 1 Step 4 | Corpus | `Corpus loaded: 15 documents` (grader BWRA03) |
| Module 2 Step 1 | Chunking | `Chunks created: 15` (grader BWRA04) |
| Module 2 Step 2 | Search service | `Service is ACTIVE` within ~3 min (grader BWRA05) |
| Module 2 Step 3 | RAG app | `RAG app ready.` |
| Module 2 Step 4 | Test questions | 5 Q&A pairs, takes a few minutes |
| Module 2 Step 5 | Evaluation | score table + means, takes 4–6 min |
| Module 3 Step 1–2 | Schema + gold standard | BUILDING revenue ≈ $44.14 B, COGS ≈ $15.49 B |
| Module 3 Step 3 (2 cells) + comparison | Naive LLM SQL | revenue ~+4% off, COGS ~2.8× off; the COGS cell takes 1–3 min |
| Module 3 Step 5 | Semantic view | `Semantic View created: ...TPCH_ORDER_ANALYTICS` (grader BWRA06) |
| Module 3 Step 6 | Cortex Analyst | revenue and COGS matching the gold standard |
| Bonus | Your own question | a profit-margin-by-region table |

7. Copy the printed output of the evaluation table, the Module 3 comparison and the Step 6
   results into chat. They're the evidence for the README.
8. When finished, **suspend the notebook service**. **Shut down kernel** alone leaves it
   `RUNNING` (verified 2026-10-03). Run in a SQL worksheet:

```sql
SHOW SERVICES IN ACCOUNT;                                    -- find the notebook service (status RUNNING)
ALTER SERVICE "USER$<your_user>".PUBLIC.<service_name> SUSPEND;  -- quotes needed for the $ in the personal DB name
SHOW SERVICES IN ACCOUNT;                                    -- status should now be SUSPENDING / SUSPENDED
```

   Run `SHOW SERVICES` as `ACCOUNTADMIN`. With a lower role the service can be invisible.

**Retired models (found in pre-flight on 2026-10-02, account in `AWS_AP_NORTHEAST_1`,
cross-region `AWS_US`):** `mistral-7b` works. `llama3-70b` and `mistral-large2` fail with
`400 'The model … has been in legacy state, please use other models.'`. `llama3.3-70b` and
`claude-sonnet-4-5` work. `llama4-maverick` and `mistral-large` are unavailable. Without the
compatibility cell, Module 2 Steps 4–5 and Module 3 Step 3 all error. The graded objects
never call an LLM, so the grade is unaffected either way. `llama3.3-70b` was chosen as the
closest like-for-like model. Claude would probably write correct SQL in Module 3 and hide
the failure the lab is meant to show.

## E. Cost cleanup (after the notebook, before the grader)

```sql
ALTER CORTEX SEARCH SERVICE AI_WORKSHOP_DB.RAG_DATA.FEATURE_SEARCH_SERVICE
  SET TARGET_LAG = '1 day';                                  -- vendor cell set 1 minute; static data needs no fast refresh
```

## F. Grader (once, in full, on the workshop day: 2026-10-03)

Submissions made before the workshop opens may not count, so build A–E early and
run F on the day.

1. Run `90_verify_grader_checks.sql` (Run All). This submits nothing. All 6 rows need
   `actual = expected`.
2. Open `autograder_bwra.local.sql` (gitignored, contains your email) in a new
   worksheet, **unedited**
3. Run it **in full**: Ctrl+A → Run All. Don't run it section by section.
4. Last result should read `Congratulations! You have successfully completed ...`
5. Proof of submission is query history, not the screen: share the query-history check and
   we'll confirm the greeting and all 7 grader calls (`AUTO_GRADER_IS_WORKING` + BWRA01–06) succeeded.
