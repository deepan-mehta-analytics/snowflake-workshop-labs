-- ══════════════════════════════════════════════════════════════════
-- Getting Started with Snowpipe — teardown (run AFTER grading)
-- ══════════════════════════════════════════════════════════════════
-- Removes every Snowflake object the lab created and restores the user's
-- default role. The AWS side (event notification, bucket, IAM role and
-- policy) is removed separately in the AWS console — see 01_run_steps.md.
-- Replace <username> and <previous_default_role> (from 00_preflight_checks.sql),
-- then run each statement with Ctrl+Enter, one at a time.

-- ── Context ──────────────────────────────────────────────────────
USE ROLE ACCOUNTADMIN;                                                -- needed to drop the integration and role

-- ── Restore the default role the guide changed ───────────────────
ALTER USER <username> SET DEFAULT_ROLE = <previous_default_role>;     -- undo the guide's DEFAULT_ROLE = S3_role

-- ── Stop and remove the pipe first ───────────────────────────────
USE ROLE S3_ROLE;                                                     -- S3_role owns the pipe after the guide's grants
ALTER PIPE S3_DB.PUBLIC.S3_PIPE SET PIPE_EXECUTION_PAUSED = TRUE;     -- stop loading before dropping
DROP PIPE IF EXISTS S3_DB.PUBLIC.S3_PIPE;                             -- removes the pipe and its notification queue binding
USE ROLE ACCOUNTADMIN;                                                -- back to the admin role for the rest

-- ── Remove the remaining lab objects ─────────────────────────────
DROP DATABASE IF EXISTS S3_DB;                                        -- removes the table and the stage with it
DROP STORAGE INTEGRATION IF EXISTS S3_ROLE_INTEGRATION;               -- removes Snowflake's link to the AWS role
DROP ROLE IF EXISTS S3_ROLE;                                          -- removes the lab role

-- ── Confirm nothing is left ──────────────────────────────────────
SHOW PIPES LIKE 'S3_PIPE' IN ACCOUNT;                                 -- expect 0 rows
SHOW DATABASES LIKE 'S3_DB';                                          -- expect 0 rows
SHOW INTEGRATIONS LIKE 'S3_ROLE_INTEGRATION';                         -- expect 0 rows
SHOW ROLES LIKE 'S3_ROLE';                                            -- expect 0 rows
