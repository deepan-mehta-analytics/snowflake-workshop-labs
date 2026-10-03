# Getting Started with Snowpipe — Skill Badge lab

Guide: https://www.snowflake.com/en/developers/guides/getting-started-with-snowpipe/

Workshop title on the grader: *Build an Automated Data Pipeline with Snowpipe Streaming*.
Despite the "Streaming" title, the grader checks this guide's classic, file-based Snowpipe
objects.

Source (verified real): `Snowflake-Labs/sfquickstarts`,
`site/sfguides/src/getting-started-with-snowpipe/` at commit `e8b5509` (2025-12-20). The
published page was read in a browser on 2026-10-03 and matches the source exactly, including
the defects listed below.

The lab sets up **event-driven loading from AWS S3**:

1. A file lands in an S3 folder.
2. S3 sends an event notification to an SQS queue that Snowflake owns.
3. A pipe with `AUTO_INGEST = TRUE` runs `COPY INTO` for that file.

On the Snowflake side this needs a storage integration, an external stage, a table, the pipe
and a dedicated role. On the AWS side it needs a bucket, an IAM policy and role, and the event
notification.

## Files in this folder

- `assets/getting-started-with-snowpipe.md`: the guide source, kept verbatim. The guide's
  `assets/` folder holds only screenshots, so those aren't copied.
- `00_preflight_checks.sql`: read-only checks for name collisions, the current default role
  (the guide changes it) and the account region (it decides the bucket region).
- `01_run_steps.md`: the click-by-click checklist (A–I) with every guide defect fixed.
- `99_teardown.sql`: drops every Snowflake object the lab created and restores the default
  role. The AWS clean-up steps are in `01_run_steps.md` section I.

The personalised grader script and a dry run of its checks stay local and gitignored
(`*.local.sql`, `*verify_grader*.sql`).

## Status

**Complete.** All auto-grader checks (BWSS01–04) passed in a single Run All on 2026-10-03
(05:08 UTC). That was one day after the live workshop (2026-10-02), so whether a late
submission counts is up to Snowflake.

Query history confirms the greeting and all five `grader()` calls succeeded: the
`AUTO_GRADER_IS_WORKING` test and BWSS01–02 ran as `ACCOUNTADMIN`, and BWSS03–04 ran as
`S3_ROLE`. A local dry run of the same checks, under the same roles, matched 4/4 beforehand.

| Check | Object | Result |
|---|---|---|
| BWSS01 | storage integration `S3_ROLE_INTEGRATION` | ✅ |
| BWSS02 | external stage `S3_DB.PUBLIC.S3_STAGE` | ✅ |
| BWSS03 | pipe `S3_PIPE`, visible to `S3_ROLE` | ✅ |
| BWSS04 | pipe "ownership" (the check counts the pipe row; it doesn't read the owner) | ✅ |

The grader doesn't check that anything actually loads. That was tested separately (below),
and then everything was torn down: all Snowflake objects, the default role, the S3 bucket and
the IAM role and policy.

## Results: auto-ingest, proven end to end

| File | How it loaded | Status | Rows | Latency |
|---|---|---|---|---|
| `snowpipe_test_2.csv` | **auto-ingest** (S3 event → SQS → pipe) | Loaded | 2 | ~20 s from event to load |
| `snowpipe_test_1.csv` | `ALTER PIPE … REFRESH` (uploaded before the notification existed) | Loaded | 3 | — |

Evidence came from `SYSTEM$PIPE_STATUS`, `COPY_HISTORY` and the table's contents.

### What went wrong first, and how it was traced

After the first upload the table stayed empty. Each point along the path was checked before
changing anything:

| Point | Evidence | Verdict |
|---|---|---|
| S3 upload | `LIST @S3_stage` showed `snowpipe/snowpipe_test_1.csv` | ✅ file in the right folder |
| SQS → pipe | pipe `RUNNING` and polling, but no `lastReceivedMessageTimestamp` | ❌ no event ever arrived |
| Pipe → COPY | `COPY_HISTORY` empty: no attempt, no error | never triggered |

The break was between S3 and the queue. The bucket's **Event notifications** card was empty:
the notification had never been saved, and nothing reported an error. After it was re-created,
a new file loaded automatically in about 20 seconds.

The first file still didn't load, because S3 never re-sends events for files that already
exist. `ALTER PIPE … REFRESH` queued both staged files. Only the one not yet loaded was
ingested, because Snowpipe's load history prevented a duplicate of file 2. The table ended
with 5 rows, not 7.

## Known limitations and guide defects

- **The storage integration doesn't run as written.** The guide puts the role ARN and bucket
  path in double quotes and ends with a curly `”`, which is a syntax error. Use single quotes.
  Create the integration **once**: `CREATE OR REPLACE` issues a new external ID and silently
  breaks the AWS trust policy.
- **The guide leaves the pipe paused.** Transferring pipe ownership requires pausing it, and
  the guide never resumes it, so auto-ingest would load nothing. Snowflake's documented resume
  after an ownership transfer is `SYSTEM$PIPE_FORCE_RESUME`, run as the new owner.
- **The guide changes your default role.** `ALTER USER … SET DEFAULT_ROLE = S3_role` makes
  Snowsight open in a role that can see almost nothing. Note the old value first
  (`00_preflight_checks.sql`) and restore it in teardown.
- **The guide never tests a load.** It ends at "micro-batching is now active". The table has
  one `STRING` column and the COPY uses the default CSV format, so a file with commas (more
  than one column) is skipped. Test with plain one-column lines.
- **Region matters, and the guide says any region will do.** Its trial instructions say US
  West (Oregon), and the bucket step says "choose your desired region". This account is in
  AWS Tokyo, and S3 only sends event notifications to a queue in the bucket's own region, so
  the bucket must be in `ap-northeast-1`.
- **Placeholders are inconsistent** (`<prefix>` vs `<path>` for the same folder), and the
  IAM policy's `ListBucket` condition allows every prefix (`"*"`). Here it's limited to
  `snowpipe/*`.
- **Admin roles can't see the pipe** unless `S3_ROLE` is granted to `SYSADMIN`. The guide
  doesn't do this. Here it was added, which let a `SYSADMIN` connection run the diagnosis and
  the refresh.
- **Whitespace is kept.** Lines with a leading space loaded with the space, because the COPY
  default is `TRIM_SPACE = FALSE`.
- **The live workshop used its own bucket.** Attendees reportedly got a Snowflake-provided
  bucket URL in a `setup.sql` that isn't in the public guide or the `builder-workshops` repo
  (that repo holds only the graders). This run followed the published guide with its own
  bucket. The grader passes either way, because it checks object names, not the bucket.

## Cost

- **AWS:** effectively $0. A few bytes of S3 storage and a handful of requests; the SQS queue
  belongs to Snowflake; event notifications are free.
- **Snowflake:** two tiny files through Snowpipe's serverless compute, well under 0.01
  credit. An idle pipe costs nothing, and everything was dropped after grading.
