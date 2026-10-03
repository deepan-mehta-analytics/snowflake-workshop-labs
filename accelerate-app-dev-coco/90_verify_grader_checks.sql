-- ══════════════════════════════════════════════════════════════════
-- Accelerate App Dev with CoCo — local check of the 6 graded objects
-- ══════════════════════════════════════════════════════════════════
-- Runs the same lookups the auto-grader runs (BWRA01–06), but submits
-- NOTHING: no greeting(), no grader(). Every value must match "expected"
-- before the real grader is run in full. Use Run All (Ctrl+Shift+Enter).

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- same role the grader uses
USE WAREHOUSE WORKSHOP_WH;                                            -- same warehouse the grader uses
USE DATABASE AI_WORKSHOP_DB;                                          -- grader's unqualified INFORMATION_SCHEMA resolves here

-- ── The 6 checks ─────────────────────────────────────────────────
SELECT 'BWRA01' AS step,                                              -- database exists
       (SELECT COUNT(*) FROM INFORMATION_SCHEMA.DATABASES
         WHERE DATABASE_NAME = 'AI_WORKSHOP_DB') AS actual,           -- grader's exact lookup
       1 AS expected                                                  -- grader's expected value
UNION ALL
SELECT 'BWRA02',                                                      -- both schemas exist
       (SELECT COUNT(*) FROM AI_WORKSHOP_DB.INFORMATION_SCHEMA.SCHEMATA
         WHERE SCHEMA_NAME IN ('RAG_DATA', 'ANALYTICS')),             -- grader's exact lookup
       2                                                              -- grader's expected value
UNION ALL
SELECT 'BWRA03',                                                      -- corpus loaded
       (SELECT COUNT(*) FROM AI_WORKSHOP_DB.RAG_DATA.FEATURE_DOCS),   -- errors if the table is missing
       15                                                             -- grader's expected value
UNION ALL
SELECT 'BWRA04',                                                      -- chunk table exists
       (SELECT COUNT(*) FROM AI_WORKSHOP_DB.INFORMATION_SCHEMA.TABLES
         WHERE TABLE_NAME = 'CHUNKED_DOCS' AND TABLE_SCHEMA = 'RAG_DATA'),  -- grader's exact lookup
       1                                                              -- grader's expected value
UNION ALL
SELECT 'BWRA05',                                                      -- search service exists
       (SELECT COUNT(*) FROM AI_WORKSHOP_DB.INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES
         WHERE SERVICE_NAME = 'FEATURE_SEARCH_SERVICE'),              -- grader's exact lookup
       1                                                              -- grader's expected value
UNION ALL
SELECT 'BWRA06',                                                      -- semantic view exists
       (SELECT COUNT(*) FROM AI_WORKSHOP_DB.INFORMATION_SCHEMA.SEMANTIC_VIEWS
         WHERE NAME = 'TPCH_ORDER_ANALYTICS' AND SCHEMA = 'ANALYTICS'),  -- grader's exact lookup
       1;                                                             -- grader's expected value
