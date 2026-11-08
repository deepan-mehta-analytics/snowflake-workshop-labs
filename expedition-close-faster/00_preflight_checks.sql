-- ══════════════════════════════════════════════════════════════════
-- Expedition 2026 Day 3 — Close Faster (CoCo + CoWork) — pre-flight checks
-- ══════════════════════════════════════════════════════════════════
-- Read-only. Run BEFORE the lab, one statement at a time (Ctrl+Enter),
-- because Snowsight "Run All" only shows the last result.
-- Answers four questions before anything is created:
--   1. Are the lab's object names free? (the notebook uses CREATE OR REPLACE,
--      so an existing MERIDIAN_STAY_FINANCE database would be silently replaced)
--   2. Which account setting does the notebook's setup cell change?
--   3. Is the grader helper (UTIL_DB.PUBLIC.GRADER) from earlier labs still there?
--   4. Which container services are running BEFORE the lab (baseline for teardown)?
-- Sources: guide sfquickstarts 9c3f3e7, notebook expedition-2026-day-3-hol a668480,
--          public grader builder-workshops expedition/close-faster-coco.sql b36d3c9.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- lab runs as ACCOUNTADMIN; sees every object

-- ── 1. Name collisions ───────────────────────────────────────────
SHOW DATABASES LIKE 'MERIDIAN_STAY_FINANCE';                          -- expect 0 rows (setup cell creates it)
SHOW API INTEGRATIONS LIKE 'GITHUB_MERIDIAN_FINANCE_LAB';             -- expect 0 rows (Git workspace dialog creates it)

-- ── 2. Setting the setup cell changes ────────────────────────────
SHOW PARAMETERS LIKE 'CORTEX_ENABLED_CROSS_REGION' IN ACCOUNT;        -- expect AWS_US; setup cell would set ANY_REGION

-- ── 3. Grader helper from earlier Northstar labs ─────────────────
SHOW USER FUNCTIONS LIKE 'GRADER' IN SCHEMA UTIL_DB.PUBLIC;           -- expect 1 row; if 0, the generated grader script sets it up

-- ── 4. Container services baseline ───────────────────────────────
SHOW SERVICES IN ACCOUNT;                                             -- note what exists now; teardown compares against this
