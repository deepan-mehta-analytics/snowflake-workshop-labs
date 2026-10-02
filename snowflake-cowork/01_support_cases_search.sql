-- ══════════════════════════════════════════════════════════════════
-- CoWork lab — Step 3: Cortex Search service "Support_Cases"
-- ══════════════════════════════════════════════════════════════════
-- SQL equivalent of the guide's Snowsight wizard (AI & ML → Search):
-- search column TRANSCRIPT, attributes TITLE + PRODUCT, warehouse DASH_WH_SI.
-- ID is selected too, because the agent's Search tool (guide step 7) uses
-- ID as its ID column and TITLE as its title column.
--
-- Vendor setup.sql is NOT re-run: every object it creates already exists
-- from the From Zero to Agents lab (same vendor repo), and re-running it
-- would CREATE OR REPLACE dash_db_si and rebuild dash_wh_si as LARGE.
-- Run in Snowsight with Ctrl+A → Run All.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE snowflake_intelligence_admin;                                -- owner of dash_db_si, as in the guide
USE WAREHOUSE dash_wh_si;                                             -- X-Small (verified 2026-10-02)
USE SCHEMA dash_db_si.retail;                                         -- lab schema

-- ── Create the search service ────────────────────────────────────
CREATE OR REPLACE CORTEX SEARCH SERVICE support_cases                 -- unquoted name → SUPPORT_CASES (grader BWSI05)
  ON transcript                                                       -- free-text column that gets embedded and searched
  ATTRIBUTES title, product                                           -- filterable columns, as in the guide
  WAREHOUSE = dash_wh_si                                              -- builds and refreshes the index
  TARGET_LAG = '1 day'                                                -- source data is static; slow refresh keeps cost near zero
  AS (
    SELECT id,                                                        -- ID column for the agent's Search tool
           title,                                                     -- title column for the agent's Search tool
           product,                                                   -- attribute: product the case is about
           transcript                                                 -- searched text
    FROM dash_db_si.retail.support_cases                              -- vendor-loaded support tickets table
  );

-- ── Verify ───────────────────────────────────────────────────────
SHOW CORTEX SEARCH SERVICES IN SCHEMA dash_db_si.retail;              -- expect CAMPAIGN_SEARCH + SUPPORT_CASES
SELECT COUNT(*) AS stage_count                                        -- grader BWSI02 needs exactly 7
FROM dash_db_si.information_schema.stages;                            -- must still be 7 (search services add none)
LIST @dash_db_si.retail.semantic_models;                              -- grader BWSI06: expect marketing_campaigns.yaml
SELECT PARSE_JSON(                                                    -- smoke-test the new service
         SNOWFLAKE.CORTEX.SEARCH_PREVIEW(                             -- one-off query against the service
           'dash_db_si.retail.support_cases',                         -- fully-qualified service name
           '{"query": "jacket zipper problems", "columns": ["title", "product"], "limit": 3}'  -- sample search
         )
       )['results'] AS sample_results;                                -- expect 3 jacket-related tickets
