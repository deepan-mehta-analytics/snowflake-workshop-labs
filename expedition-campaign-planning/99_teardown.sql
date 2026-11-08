-- ══════════════════════════════════════════════════════════════════
-- Expedition 2026 Day 2 — Campaign Planning — teardown
-- ══════════════════════════════════════════════════════════════════
-- Run ONLY after the auto-grader has run in full and submission is proven
-- from query history (the grader checks these objects, so dropping them first fails it).
-- Run section A one statement at a time; it decides what section B needs.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- owner of every lab object

-- ── A. Find the lab's container services ─────────────────────────
SHOW SERVICES IN ACCOUNT;                                             -- the notebook + Streamlit runtimes appear here (USER$... schema)

-- ── B. Stop each lab service found in A ──────────────────────────
-- Replace <database>.<schema>.<service> with each new row from A (compare with the pre-flight baseline).
-- "Shut down kernel" in the notebook leaves the service RUNNING, so this step is required.
-- ALTER SERVICE <database>.<schema>.<service> SUSPEND;               -- stops billing for that container

-- ── C. Drop the lab objects (vendor teardown) ────────────────────
DROP DATABASE IF EXISTS MERIDIAN_STAY;                                -- schemas, Iceberg tables, stage, semantic view, agent, deployed app
DROP API INTEGRATION IF EXISTS GITHUB_MERIDIAN_LAB;                   -- Git integration made by the workspace dialog

-- ── D. Restore the cross-region setting (only if the setup cell changed it) ──
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';          -- back to the pre-lab value

-- ── E. Verify ─────────────────────────────────────────────────────
SHOW DATABASES LIKE 'MERIDIAN_STAY';                                  -- expect 0 rows
SHOW API INTEGRATIONS LIKE 'GITHUB_MERIDIAN_LAB';                     -- expect 0 rows
SHOW PARAMETERS LIKE 'CORTEX_ENABLED_CROSS_REGION' IN ACCOUNT;        -- expect AWS_US
SHOW SERVICES IN ACCOUNT;                                             -- expect every lab service SUSPENDED (or gone)
