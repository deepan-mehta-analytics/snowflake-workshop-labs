-- ══════════════════════════════════════════════════════════════════
-- Expedition 2026 Day 2 — Campaign Planning (CoCo + CoWork) — pre-flight checks
-- ══════════════════════════════════════════════════════════════════
-- Read-only. Run BEFORE the lab, one statement at a time (Ctrl+Enter),
-- because Snowsight "Run All" only shows the last result.
-- Answers four questions before anything is created:
--   1. Are the lab's object names free? (the notebook uses CREATE OR REPLACE,
--      so an existing MERIDIAN_STAY database would be silently replaced)
--   2. Which account setting does the notebook's setup cell change?
--   3. Is the grader helper (UTIL_DB.PUBLIC.GRADER) from earlier labs still there?
--   4. Which container services are running BEFORE the lab (baseline for teardown)?
-- Already checked by Claude on 2026-11-05 (SYSADMIN token, read-only):
--   COMPUTE_WH exists (X-Small, auto-suspend 300 s); region AWS_AP_NORTHEAST_1;
--   Snowflake-managed Iceberg tables work here (throwaway probe created + dropped).

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- lab runs as ACCOUNTADMIN; sees every object

-- ── 1. Name collisions ───────────────────────────────────────────
SHOW DATABASES LIKE 'MERIDIAN_STAY';                                  -- expect 0 rows (setup cell creates it)
SHOW API INTEGRATIONS LIKE 'GITHUB_MERIDIAN_LAB';                     -- expect 0 rows (Git workspace dialog creates it)
SHOW API INTEGRATIONS;                                                -- note any existing Git integration (reuse is fine)

-- ── 2. Setting the setup cell changes ────────────────────────────
SHOW PARAMETERS LIKE 'CORTEX_ENABLED_CROSS_REGION' IN ACCOUNT;        -- expect AWS_US; setup cell would set ANY_REGION

-- ── 3. Grader helper from earlier Northstar labs ─────────────────
SHOW USER FUNCTIONS LIKE 'GRADER' IN SCHEMA UTIL_DB.PUBLIC;           -- expect 1 row; if 0, the generated grader script sets it up

-- ── 4. Container services baseline ───────────────────────────────
SHOW SERVICES IN ACCOUNT;                                             -- note what exists now; teardown compares against this
