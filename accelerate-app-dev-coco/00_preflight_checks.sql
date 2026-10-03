-- ══════════════════════════════════════════════════════════════════
-- Accelerate App Dev with CoCo — pre-flight checks (run BEFORE the lab)
-- ══════════════════════════════════════════════════════════════════
-- Read-only, apart from 3 tiny COMPLETE calls (well under a cent in total).
-- Answers four questions before anything is created:
--   1. Do the lab's object names already exist? (CREATE ... IF NOT EXISTS would
--      silently keep an old object, e.g. a warehouse at the wrong size.)
--   2. What are the account settings the guide changes, before it changes them?
--   3. Which region is the account in, and is cross-region inference allowed?
--   4. Can this account call the 3 LLMs the notebook hard-codes?
-- Run each statement with Ctrl+Enter, one at a time, and note each result.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- account parameters need ACCOUNTADMIN

-- ── 1. Name collisions ───────────────────────────────────────────
SHOW DATABASES LIKE 'AI_WORKSHOP_DB';                                 -- expect 0 rows (lab creates it)
SHOW WAREHOUSES LIKE 'WORKSHOP_WH';                                   -- expect 0 rows; if 1 row, check "size" is X-Small

-- ── 2. Settings the guide's setup step changes ───────────────────
SHOW PARAMETERS LIKE 'ENABLE_PERSONAL_DATABASE' IN ACCOUNT;           -- guide sets TRUE; note the current value
SELECT CURRENT_USER() AS user_name;                                   -- the name to put in place of CURRENT_USER in the guide
SET my_user = CURRENT_USER();                                         -- IDENTIFIER() takes a variable, not a function call
DESCRIBE USER IDENTIFIER($my_user);                                   -- find DEFAULT_SECONDARY_ROLES row; guide sets ('ALL')

-- ── 3. Region and cross-region inference ─────────────────────────
SELECT CURRENT_REGION() AS account_region;                            -- cloud + region the account runs in
SHOW PARAMETERS LIKE 'CORTEX_ENABLED_CROSS_REGION' IN ACCOUNT;        -- DISABLED limits models to this region

-- ── 4. Model availability (the notebook hard-codes these 3) ──────
SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-7b', 'Reply with OK');      -- used in Module 1
SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3-70b', 'Reply with OK');      -- used in the Module 1 comparison cell
SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', 'Reply with OK');  -- used by the RAG app, the judge and text-to-SQL
-- 2026-10-02 result: mistral-7b OK; llama3-70b and mistral-large2 → "legacy state" 400 error.

-- ── 5. Replacement candidates (TRY_COMPLETE returns NULL instead of failing) ──
SELECT 'llama3.3-70b' AS model, SNOWFLAKE.CORTEX.TRY_COMPLETE('llama3.3-70b', 'Reply with OK') AS reply   -- Meta, successor to llama3-70b
UNION ALL
SELECT 'llama4-maverick', SNOWFLAKE.CORTEX.TRY_COMPLETE('llama4-maverick', 'Reply with OK')              -- newer Meta model
UNION ALL
SELECT 'mistral-large', SNOWFLAKE.CORTEX.TRY_COMPLETE('mistral-large', 'Reply with OK')                  -- Mistral's current large model name
UNION ALL
SELECT 'claude-sonnet-4-5', SNOWFLAKE.CORTEX.TRY_COMPLETE('claude-sonnet-4-5', 'Reply with OK');         -- strong, costs more per call
-- 2026-10-02 result: llama3.3-70b OK, claude-sonnet-4-5 OK, the other two NULL.
