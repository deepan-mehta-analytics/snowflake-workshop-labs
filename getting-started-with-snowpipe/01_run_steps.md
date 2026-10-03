# Getting Started with Snowpipe — run checklist

Guide: https://www.snowflake.com/en/developers/guides/getting-started-with-snowpipe/
Vendor source (kept verbatim): `assets/getting-started-with-snowpipe.md`, from
`Snowflake-Labs/sfquickstarts/site/sfguides/src/getting-started-with-snowpipe/` at commit
`e8b5509` (2025-12-20). The published page was checked against it on 2026-10-03 and matches.
The guide's `assets/` folder only holds screenshots, so it isn't copied here.

**Rules for the whole run**
- Object names must match the guide exactly (`S3_DB`, `S3_TABLE`, `S3_STAGE`, `S3_PIPE`,
  `S3_ROLE`, `S3_ROLE_INTEGRATION`). A grader may check them.
- Fill in placeholders once and reuse them everywhere:

| Placeholder | Value | Where it comes from |
|---|---|---|
| `<bucket>` | your bucket name (globally unique, lowercase) | you choose it in step B1 |
| `<prefix>` | `snowpipe` | fixed here; the guide uses both `<prefix>` and `<path>` for this |
| `<aws_account_id>` | 12-digit AWS account ID | AWS console, top-right account menu |
| `<username>` | your Snowflake login name | `00_preflight_checks.sql` |

- Every AWS step is done by you in the AWS console. Every ACCOUNTADMIN step is run by you in
  Snowsight.
- **Run `CREATE STORAGE INTEGRATION` once only.** Re-running `CREATE OR REPLACE` issues a new
  external ID, and the AWS trust policy from step C3 stops working.

## A. Pre-flight (read-only)

1. Snowsight → new SQL worksheet → paste `00_preflight_checks.sql`.
2. Run each statement on its own (Ctrl+Enter) and note:
   - the four `SHOW` results: expect 0 rows for `S3_DB`, `S3_ROLE` and `S3_ROLE_INTEGRATION`
   - **the `DEFAULT_ROLE` value from `DESCRIBE USER`**, needed to restore it in teardown
   - `CURRENT_REGION()`: for this account it's `AWS_AP_NORTHEAST_1`

## B. AWS: bucket and folder (guide "Setting up AWS Bucket and Prefix")

1. AWS console → top-right **region selector** → **Asia Pacific (Tokyo) ap-northeast-1**.
   - The bucket must be in the same region as the Snowflake account. S3 can only send event
     notifications to a queue in the bucket's own region, and Snowpipe's queue is in Tokyo.
     The guide says "choose your desired region", which would break auto-ingest here.
2. Search **S3** → **Create bucket**:
   - **Bucket type:** General purpose
   - **Bucket name:** `<bucket>`
   - **Object Ownership:** ACLs disabled (default)
   - **Block all public access:** leave ticked (default). Snowflake reads through the IAM
     role, not public access.
   - Everything else default → **Create bucket**
3. Open the bucket → **Create folder** → name `snowpipe` → **Create folder**.

## C. Permissions (guide "Configure Cloud Storage Permissions")

### C1. IAM policy `snowflake_access`
1. AWS console → search **IAM** → **Account settings** → under **Security Token Service
   (STS)**, confirm **Asia Pacific (Tokyo)** shows **Active**.
2. **Policies** → **Create policy** → **JSON** → replace everything with the policy below.
   This is the guide's policy with one change: `ListBucket` is limited to the `snowpipe/`
   folder instead of `"*"`.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:GetObject", "s3:GetObjectVersion"],
            "Resource": "arn:aws:s3:::<bucket>/snowpipe/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<bucket>",
            "Condition": {"StringLike": {"s3:prefix": ["snowpipe/*"]}}
        }
    ]
}
```

3. **Next** → Policy name `snowflake_access` → **Create policy**.

### C2. IAM role `snowflake_role`
1. **Roles** → **Create role**:
   - **Trusted entity type:** AWS account
   - **An AWS account:** This account
   - **Options:** tick **Require external ID** → External ID `0000` (a placeholder; replaced in C4)
2. **Next** → search `snowflake_access` → tick it → **Next**.
3. Role name `snowflake_role`, description `Snowflake role for access to S3 bucket` →
   **Create role**.
4. Open the role → copy its **ARN** (`arn:aws:iam::<aws_account_id>:role/snowflake_role`).

### C3. Storage integration (Snowsight, ACCOUNTADMIN)

The guide's version uses double quotes and a curly `”`, which is a syntax error. Fixed:

```sql
USE ROLE ACCOUNTADMIN;                                        -- integrations need ACCOUNTADMIN
CREATE STORAGE INTEGRATION S3_role_integration               -- no OR REPLACE: a re-run would change the external ID
  TYPE = EXTERNAL_STAGE                                       -- used by an external stage
  STORAGE_PROVIDER = 'S3'                                     -- AWS S3
  ENABLED = TRUE                                              -- active immediately
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<aws_account_id>:role/snowflake_role'  -- role from C2 (single quotes)
  STORAGE_ALLOWED_LOCATIONS = ('s3://<bucket>/snowpipe/');    -- only this folder (single quotes)

DESC INTEGRATION S3_role_integration;                        -- copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID
```

### C4. Trust policy (AWS)
1. IAM → **Roles** → `snowflake_role` → **Trust relationships** → **Edit trust policy**.
2. Replace everything with this, using the two values from `DESC INTEGRATION` →
   **Update policy**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "<STORAGE_AWS_IAM_USER_ARN>"},
      "Action": "sts:AssumeRole",
      "Condition": {"StringEquals": {"sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID>"}}
    }
  ]
}
```

## D. Snowflake objects (guide "Create a pipe in Snowflake")

Run as ACCOUNTADMIN, one statement at a time. These are the guide's statements with the
placeholders filled in.

```sql
USE ROLE ACCOUNTADMIN;                                        -- same role as the guide
CREATE OR REPLACE DATABASE S3_db;                             -- lab database
CREATE OR REPLACE TABLE S3_table(files STRING);               -- one text column: each line of a file becomes a row
USE SCHEMA S3_db.public;                                      -- context for the stage
CREATE OR REPLACE STAGE S3_stage
  URL = 's3://<bucket>/snowpipe/'                             -- the folder from B3
  STORAGE_INTEGRATION = S3_role_integration;                  -- reads through the IAM role
LIST @S3_stage;                                               -- proves the integration and trust policy work (empty list, no error)
CREATE OR REPLACE PIPE S3_db.public.S3_pipe AUTO_INGEST = TRUE AS
  COPY INTO S3_db.public.S3_table
  FROM @S3_db.public.S3_stage;                                -- loads each new file that lands in the folder
```

If `LIST @S3_stage` errors with an access message, the trust policy (C4) doesn't match
`DESC INTEGRATION`. Fix that before going on.

## E. Role and grants (guide "Configure Snowpipe User Permissions")

The guide's block, run as written, with `<username>` filled in. Then **two added
statements**:

```sql
USE ROLE ACCOUNTADMIN;
ALTER PIPE S3_PIPE SET PIPE_EXECUTION_PAUSED = TRUE;          -- guide: a pipe must be paused to change its owner
GRANT OWNERSHIP ON PIPE S3_db.public.S3_pipe TO ROLE ACCOUNTADMIN;
CREATE OR REPLACE ROLE S3_role;
GRANT USAGE ON DATABASE S3_db TO ROLE S3_role;
GRANT USAGE ON SCHEMA S3_db.public TO ROLE S3_role;
GRANT INSERT, SELECT ON S3_db.public.S3_table TO ROLE S3_role;
GRANT USAGE ON STAGE S3_db.public.S3_stage TO ROLE S3_role;
GRANT OWNERSHIP ON PIPE S3_db.public.S3_pipe TO ROLE S3_role;
GRANT ROLE S3_role TO USER <username>;
ALTER USER <username> SET DEFAULT_ROLE = S3_role;             -- guide's change; restored in teardown

-- ── Added 1: resume the pipe (the guide leaves it paused, so nothing would load) ──
-- Snowflake's documented steps after an ownership transfer are pause → GRANT OWNERSHIP →
-- SYSTEM$PIPE_FORCE_RESUME (docs: "Managing Snowpipe" → transferring pipe ownership).
USE ROLE S3_role;                                             -- the pipe's new owner
SELECT SYSTEM$PIPE_FORCE_RESUME('S3_db.public.S3_pipe');      -- resume after the ownership transfer
SELECT SYSTEM$PIPE_STATUS('S3_db.public.S3_pipe');            -- expect "executionState":"RUNNING"

-- ── Added 2: let ACCOUNTADMIN (and SYSADMIN) see the pipe ──
USE ROLE ACCOUNTADMIN;
GRANT ROLE S3_role TO ROLE SYSADMIN;                          -- custom roles should roll up to SYSADMIN; lets admins monitor and drop the pipe
```

`SHOW PIPES IN ACCOUNT;` → copy the `notification_channel` value (an `arn:aws:sqs:ap-northeast-1:…` ARN).

## F. S3 event notification (guide "New S3 Event")

1. AWS console → S3 → `<bucket>` → **Properties** → **Event notifications** →
   **Create event notification**:
   - **Event name:** `Auto-ingest Snowflake`
   - **Prefix:** `snowpipe/` (added: limits events to the watched folder)
   - **Event types:** tick **All object create events**
   - **Destination:** SQS queue → **Enter SQS queue ARN** → paste `notification_channel`
2. **Save changes** → back on **Properties**, confirm the **Event notifications** card now
   **lists** `Auto-ingest Snowflake`. In this run the first attempt never saved, and the card
   was empty. Nothing errors when that happens; files simply never load.
3. Only upload test files **after** the notification is listed. S3 never re-sends events for
   files that were already there.

## G. Prove it loads (not in the guide)

The guide stops at "micro-batching is now active" without loading anything. Test it:

1. On your PC, create `snowpipe_test_1.csv` holding three lines of plain text **without
   commas** (the table has one column, and a file with more columns is skipped):
   ```
   hello snowpipe
   first auto-ingested file
   loaded from S3 Tokyo
   ```
2. AWS S3 → `<bucket>` → `snowpipe/` → **Upload** → add the file → **Upload**.
3. Wait about a minute, then in Snowsight:

```sql
USE ROLE S3_role;                                             -- has SELECT on the table
SELECT * FROM S3_db.public.S3_table;                          -- expect 3 rows
SELECT SYSTEM$PIPE_STATUS('S3_db.public.S3_pipe');            -- lastIngestedFilePath = snowpipe_test_1.csv
USE ROLE ACCOUNTADMIN;
SELECT file_name, status, row_count, first_error_message      -- load result per file
FROM TABLE(S3_db.INFORMATION_SCHEMA.COPY_HISTORY(
       TABLE_NAME => 'S3_DB.PUBLIC.S3_TABLE',
       START_TIME => DATEADD('hour', -1, CURRENT_TIMESTAMP())));  -- expect Loaded, 3 rows
```

Snowpipe only reacts to files created **after** the event notification exists. To load
files uploaded earlier, run `ALTER PIPE S3_db.public.S3_pipe REFRESH;` as `S3_role`.

## H. Grader

The workshop ran on 2026-10-02. This lab is being completed on 2026-10-03, after it, so a
late submission may or may not count. Query history still records what was submitted and when.

What the grader needs (from reading the script before running it):
- It checks objects only (the integration, stage, pipe and pipe ownership). It doesn't check
  loaded rows or the default role, so step G is for our own proof, not the grade.
- **`S3_ROLE` must exist and be granted to your user before grading.** The script grants
  that role access to the grader functions and switches to it partway through. If the role
  is missing, Run All stops at that statement and the later checks are never submitted.
  So never run teardown before grading.
- While running as `S3_ROLE`, the grader's calls need a usable warehouse. This account has
  `DEFAULT_SECONDARY_ROLES = ('ALL')` (set in the CoCo lab), which supplies it. The dry run
  checks this before anything is submitted.

1. Run the local dry run (`*verify_grader*.sql`, gitignored) with Run All and read **every**
   result tab. Expected: all `actual = expected`, `PIPE_OWNER` = `S3_ROLE`, and the
   warehouse probe returning a value rather than an error.
2. Open the grader script (`*.local.sql`, gitignored, contains your email) in a new
   worksheet, **unedited** → Run All **once**.
3. The last result should read "Congratulations! …". Its first statement re-reads
   `SHOW STORAGE INTEGRATIONS` through `RESULT_SCAN`, so don't run anything else in that
   worksheet while it runs.
4. Prove the submission from query history: the greeting plus 5 `grader()` calls
   (`AUTO_GRADER_IS_WORKING` and BWSS01–04).

## I. Teardown (after grading)

1. Snowsight: `99_teardown.sql`, one statement at a time. It restores the default role
   noted in A.
2. AWS console:
   - S3 → `<bucket>` → **Properties** → delete the event notification
   - empty the bucket → delete the bucket
   - IAM → delete the role `snowflake_role` → delete the policy `snowflake_access`
