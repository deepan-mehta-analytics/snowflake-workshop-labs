# Getting Started with Snowflake CoWork — Skill Badge lab

Source page: https://www.snowflake.com/en/developers/guides/getting-started-with-cowork/

Underlying repo (verified real, same as From Zero to Agents): https://github.com/Snowflake-Labs/sfguide-getting-started-with-snowflake-intelligence

This lab builds a `Sales//AI` agent that answers sales, marketing and support
questions over Snowflake's fictional retail dataset. You use the agent through
**Snowflake CoWork** (`ai.snowflake.com`), Snowflake's chat interface for
agents. The agent has three tools: Cortex Analyst over a YAML semantic model,
Cortex Search over support-ticket transcripts, and a stored procedure that sends
email.

It reuses the objects created by [`from-zero-to-agents/`](../from-zero-to-agents/):
the `DASH_DB_SI` database, the `DASH_WH_SI` warehouse and the
`SNOWFLAKE_INTELLIGENCE_ADMIN` role. Run that lab first.

## Files in this folder

- `01_support_cases_search.sql` — the SQL equivalent of the guide's
  Snowsight wizard for the Cortex Search service `SUPPORT_CASES`, with
  verification queries.
- `02_sales_ai_agent_steps.md` — a click-by-click checklist for building the
  `Sales_AI` agent in Agent Studio and testing it in CoWork. It matches the
  Agent Studio layout as of 2026-10-02.

No `assets/` folder: the guide's `setup.sql` is byte-for-byte the From Zero to
Agents script (apart from its final verification block). It's already kept
verbatim in [`from-zero-to-agents/assets/setup.sql`](../from-zero-to-agents/assets/setup.sql).

## Steps

1. **Don't re-run the vendor `setup.sql`** if From Zero to Agents has already
   been run. It runs `CREATE OR REPLACE` on `dash_db_si`, which wipes the
   graded Lab 2 Dynamic Table, semantic view and agent. It also rebuilds
   `dash_wh_si` as a **LARGE** warehouse. Every object this lab needs already
   exists.
2. **Cortex Search service** — run `01_support_cases_search.sql` (Run All).
   It creates `SUPPORT_CASES` over `support_cases.transcript`, with `title` and
   `product` as attributes and `TARGET_LAG = '1 day'` (the data is static).
   The final smoke test should return ThermoJacket tickets.
3. **Agent** — follow `02_sales_ai_agent_steps.md`, sections A–G:
   - Create it as `SNOWFLAKE_INTELLIGENCE.AGENTS.SALES_AI` (display name
     `Sales//AI`) using the role `SNOWFLAKE_INTELLIGENCE_ADMIN`.
   - It has three tools:
     - Cortex Analyst on `@semantic_models/marketing_campaigns.yaml`
     - Cortex Search on `SUPPORT_CASES` (ID column `ID`, title column `TITLE`)
     - The custom procedure tool `SEND_EMAIL`
   - Add the orchestration instruction "always choose to generate a chart".
   - **Publish** the agent, then **Connect to Snowflake CoWork**.
   - Verify it with `DESCRIBE AGENT snowflake_intelligence.agents.sales_ai;`
4. **Test in CoWork** (section H): ask the three sample questions, then ask the
   agent to email a summary of the jacket issues to your verified Snowflake email.

## Status

**Complete.** All auto-grader checks (BWSI01–06) passed against the live
account on 2026-10-02 and were re-submitted on the workshop day, 2026-10-03
(UTC), from that day's landing-page script (identical to the earlier one).
Query history confirms the greeting and every `grader()` call succeeded, so
the result doesn't rest on the result screen alone.

The script's final `WITH check_results` summary block fails intermittently
with `Error parsing JSON: invalid UTF-8 sequence` (or `unknown keyword`). That
block runs only in your own account and never contacts the grader, so the
error doesn't affect the grade. To confirm a submission, check
`INFORMATION_SCHEMA.QUERY_HISTORY` for `SUCCESS` on the `greeting()` call and
all seven `grader()` calls.

The `Sales_AI` agent isn't graded, but it was built and tested end to end in CoWork:

| Test | Tool(s) the agent used | Result |
|---|---|---|
| Sales trend by product category, June–August | Cortex Analyst | ✅ Chart plus data table |
| Jacket issues in support tickets | Cortex Search | ✅ Found four ThermoJacket Pro seam-tear tickets, all resolved by replacement |
| Why Fitness Wear sales grew in July | Cortex Analyst over `sales`, `social_media` and `marketing_campaign_metrics` | ✅ Explained the spike, with two flaws (see below) |
| Email a summary of the jacket issues | Cortex Search, then `Send_Email` | ✅ HTML summary received in inbox |

The best answer was the July Fitness Wear one. July sales were $6.78M against
$2.18M in June (about 3.1×). The agent linked the spike to an Instagram surge:
3,927 mentions in July against 287 in June, nearly all from a single
influencer, `NovaFitStar`. Facebook and Twitter mentions stayed flat. It also
added its own caveat that the tables aren't linked at transaction level, so the
link is a correlation in timing, not a measured cause.

## Known limitations

- **August is a partial month.** `dash_db_si.retail.sales` ends on
  **2025-08-14**, so every category appears to fall 50–85% in August. Scaled to
  a full 31 days, every category's August is within about 5% of its June total
  (Fitness Wear's $0.98M works out to about $2.2M, the same as June). The agent
  never pointed this out. The trend chart shows August without a caveat, and
  the July answer calls August a "collapse back to baseline" without noting
  that the month is incomplete.
- **The agent claimed something the data can't show.** In the July answer it
  said the Summer Fitness Campaign "spent less" and that "ad spend declined".
  `marketing_campaign_metrics` only has `date`, `category`, `campaign_name`,
  `impressions` and `clicks`. There's **no spend column**, so the agent
  inferred spend from lower impressions and clicks. Check claims like this
  against the schema before quoting them.
- **The Agent Studio save bug is still present.** The `Send_Email` tool's
  warehouse saved as `""` until a query timeout (60s) was set as well. This is
  the same family of bug as the one documented in From Zero to Agents. Always
  confirm the saved tools with `DESCRIBE AGENT`, not the UI.
- **CoWork offers to set up recurring automations** (a weekly ticket scan, a
  monthly spike report) after it answers. Each run is a paid agent call, about
  0.15 credits. None were set up here because the account is on a trial
  credit grant.
- **No files were uploaded to stages.** A new stage would change the account's
  stage count, which one of the grader checks depends on.
