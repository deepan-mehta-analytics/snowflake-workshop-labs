-- ══════════════════════════════════════════════════════════════════
-- Getting Started with Snowpipe — pre-flight checks (run BEFORE the lab)
-- ══════════════════════════════════════════════════════════════════
-- Read-only. Answers three questions before anything is created:
--   1. Do the lab's object names already exist? (The guide uses CREATE OR
--      REPLACE, which would silently wipe an existing object of the same name.)
--   2. What is the user's current default role? The guide changes it to
--      S3_role, so note the current value to restore it during teardown.
--   3. Which AWS region is the account in? The S3 bucket must be created in
--      the same region for S3 event notifications to reach Snowpipe's queue.
-- Run each statement with Ctrl+Enter, one at a time, and note each result.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- integrations and roles need ACCOUNTADMIN

-- ── 1. Name collisions ───────────────────────────────────────────
SHOW DATABASES LIKE 'S3_DB';                                          -- expect 0 rows (lab creates it)
SHOW ROLES LIKE 'S3_ROLE';                                            -- expect 0 rows (lab creates it)
SHOW INTEGRATIONS LIKE 'S3_ROLE_INTEGRATION';                         -- expect 0 rows; re-creating one changes its external ID
SHOW PIPES IN ACCOUNT;                                                -- note any existing pipes; the lab adds S3_PIPE

-- ── 2. Current default role (to restore in teardown) ─────────────
SELECT CURRENT_USER() AS user_name;                                   -- the name the guide calls <username>
SET my_user = CURRENT_USER();                                         -- IDENTIFIER() takes a variable, not a function call
DESCRIBE USER IDENTIFIER($my_user);                                   -- find the DEFAULT_ROLE row and write its value down

-- ── 3. Region (decides the S3 bucket's region) ───────────────────
SELECT CURRENT_REGION() AS account_region;                            -- AWS_AP_NORTHEAST_1 → create the bucket in ap-northeast-1 (Tokyo)
