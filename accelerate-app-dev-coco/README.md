# Accelerate App Dev with Cortex Code — Skill Badge lab

Guide: https://www.snowflake.com/en/developers/guides/accelerate-app-dev-coco/

Workshop title on the grader: *Building AI Applications with Snowflake Cortex: RAG,
Text-to-SQL & CoCo*.

Source (verified real): `Snowflake-Labs/sfquickstarts`,
`site/sfguides/src/accelerate-app-dev-cortex-code/`. The notebook on the workshop's
resources page is byte-identical to the one in that repo.

The lab has three modules, run in a Snowflake Workspaces notebook:

1. **AI foundations:** `COMPLETE` calls, a hallucination, then a grounded answer
2. **Production RAG:** chunking, a Cortex Search service, a RAG app, and an
   LLM-as-judge evaluation
3. **Text-to-SQL:** an LLM writes SQL with no semantic model and gets the numbers
   wrong. A semantic view plus Cortex Analyst then gets them right.

Cortex Code (CoCo) is only used briefly, in the SQL worksheet before the notebook.

## Files in this folder

- `assets/accelerate-app-dev-cortex-code.md` and `assets/accelerate-app-dev-cortex-code.ipynb`:
  the guide source and the notebook, kept verbatim.
- `00_preflight_checks.sql`: read-only checks to run before the lab. It checks for name
  collisions, shows the account settings the guide changes, and confirms the region and
  that the 3 hard-coded models can be called.
- `01_run_steps.md`: the click-by-click checklist (sections A–F), including the one added
  compatibility cell.
Two grader-related files stay local and are gitignored:

- The personalised grader script (`*.local.sql`), because it contains the registration
  email.
- A dry-run copy of the grader's 6 lookups (`*verify_grader*.sql`) that submits nothing.
  It reproduces the answer key, so it isn't published.

## Steps (summary; full detail in `01_run_steps.md`)

1. **Pre-flight:** run `00_preflight_checks.sql` one statement at a time.
2. **Setup worksheet:** create `AI_WORKSHOP_DB` (schemas `RAG_DATA` and `ANALYTICS`) and an
   X-Small `WORKSHOP_WH`. The guide's `ALTER USER CURRENT_USER` needs your real user name
   in place of `CURRENT_USER`.
3. **CoCo demos:** create `DOCS_STAGE` through a CoCo prompt and ask the chunking question.
4. **Notebook:** upload it in **Projects → Workspaces**, then **Connect → Create new
   service**.
   - **Set Service settings → Idle timeout to 1 hour.** The default is 24 hours.
   - Run Setup, then add the **compatibility cell** (see below).
   - Run the remaining cells one by one.
5. **Stop the notebook service:**
   `ALTER SERVICE "USER$<you>".PUBLIC.<service_name> SUSPEND;`, then confirm with
   `SHOW SERVICES IN ACCOUNT;`. Shutting down the kernel alone leaves the service running.
6. **Cost cleanup:** set `FEATURE_SEARCH_SERVICE`'s `TARGET_LAG` to `'1 day'`. The vendor
   cell sets 1 minute.
7. **Grader:** run a local dry run of the grader's checks first (the grader's own lookups
   without the `grader()` calls), then the grader script once, in full, with Run All.

### The one non-vendor change: a compatibility cell

The notebook hard-codes `mistral-large2` and `llama3-70b`, and Snowflake has retired both
(`400 'The model … has been in legacy state'`). Without a fix, Module 2 Steps 4–5 and
Module 3 Step 3 error.

The fix is one cell, added after Setup. It wraps the notebook's own `complete()` helper
and redirects both names to `llama3.3-70b`. The vendor cells themselves are untouched.
`llama3.3-70b` was chosen as the closest like-for-like model. A stronger model such as
Claude would probably write correct SQL in Module 3 and hide the failure the lab is
built to show. The graded objects never call an LLM, so the grade is unaffected.

## Status

**Complete.** All auto-grader checks (BWRA01–06) passed on the workshop day,
2026-10-03 (UTC), in a single Run All. Query history confirms the greeting, all seven
`grader()` calls (`AUTO_GRADER_IS_WORKING` plus BWRA01–06) and the summary block succeeded.
A local dry run of the same lookups matched 6/6 beforehand.

| Check | Object | Result |
|---|---|---|
| BWRA01 | database `AI_WORKSHOP_DB` | ✅ |
| BWRA02 | schemas `RAG_DATA` and `ANALYTICS` | ✅ |
| BWRA03 | `FEATURE_DOCS` with 15 rows | ✅ |
| BWRA04 | table `CHUNKED_DOCS` | ✅ |
| BWRA05 | Cortex Search service `FEATURE_SEARCH_SERVICE` | ✅ |
| BWRA06 | semantic view `ANALYTICS.TPCH_ORDER_ANALYTICS` | ✅ |

## Results

### Module 2: RAG evaluation (LLM-as-judge)

Both the answers and the judge ran on `llama3.3-70b` rather than the guide's
`mistral-large2`, so the scores aren't directly comparable to the guide's.

| Question | Groundedness | Context relevance | Answer relevance |
|---|---|---|---|
| Difference between Cortex Search and Cortex Analyst? | 1.0 | 1.0 | 1.0 |
| How does Snowpipe know when new files arrive? | 1.0 | 0.8 | 1.0 |
| Can I run Streamlit apps on a trial account? | **0.0** | 1.0 | 0.5 |
| Does my data leave Snowflake when I call an LLM? | 1.0 | 1.0 | 1.0 |
| What is the Snowflake AI Trust Layer? | 1.0 | 1.0 | 1.0 |
| **Mean** | **0.80** | **0.96** | **0.90** |

The Streamlit question shows what the groundedness metric is for. Retrieval returned
relevant chunks (context relevance 1.0), but the 15-document corpus has no Streamlit
document, so the model answered partly from its own knowledge. The judge scored that
answer 0.0 for groundedness.

### Module 3: naive text-to-SQL vs. semantic view (BUILDING segment)

| Metric | Gold standard | Naive LLM SQL | Cortex Analyst + semantic view |
|---|---|---|---|
| Revenue | $44.14 B | $45.91 B (**+4.0%**) | **$44.14 B** ✅ |
| Cost of goods sold | $15.49 B | $44.14 B (**2.85×**) | **$15.49 B** ✅ |

The same pattern held in all five market segments: revenue was +4.0% everywhere and COGS
was 2.8–2.9× too high. Cortex Analyst matched all 10 gold figures to the cent.

- **Revenue:** the model used `SUM(O_TOTALPRICE)`. In TPC-H that's the order total
  *including tax*, so every segment comes out about 4% high, the average line-item tax.
  The SQL runs cleanly and the numbers look plausible.
- **COGS:** the model wrote the *exact* gold-standard revenue formula,
  `SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))`, and labelled it COGS. It never joined
  `PARTSUPP` for `PS_SUPPLYCOST`. So it knew the right formula but attached it to the
  wrong business term. A semantic view prevents exactly this, because each metric is
  defined once.
- The vendor cell prints "Both match the gold standard. Every time. Deterministically."
  That's the notebook's claim. This run asked each question once.

### Bonus: "Which region has the highest profit margin?"

Cortex Analyst answered **ASIA** ($28.46 B profit on $43.86 B revenue, 64.90%). An
independent query over the same joins confirmed the figures and showed that it ranked by
**margin**, not by total profit. By total profit EUROPE would win ($28.57 B, 64.89%).
All five regions fall between 64.86% and 64.90%, so the "winner" differs from the
others by under 0.05 percentage points. That's a feature of the synthetic data, not a
finding about the regions.

## Cost

- **Notebook service:** about 51 minutes on `CPU_X64_S`, roughly 0.1 credit.
- **LLM calls:** about 35 `COMPLETE` calls on small and mid-size models, a few cents.
- **Cortex Analyst and Cortex Search:** a handful of Cortex Analyst messages. The
  15-row Cortex Search service now refreshes once a day.
- **Total:** well under 1 credit.

## Known limitations

- **Two of the notebook's models are retired** (see the compatibility cell above). Every
  LLM-generated number in this README comes from `llama3.3-70b`, not the models the guide
  names. In Module 1, the output labelled `llama3-70b` was actually served by
  `llama3.3-70b`.
- **The guide and the notebook disagree in places:**
  - The guide says chunking uses `SPLIT_TEXT_RECURSIVE_CHARACTER`, but the notebook slices
    text in Python. CoCo's answer about the function was still correct.
  - The guide mentions Snowsight Evaluations, but Step 5 is a hand-written
    LLM-as-judge.
  - The guide names the notebook file `building-ai-apps-snowflake-cortex.ipynb`.
  - Module 1 Step 3's "grounded" prompt labels `SUM(O_TOTALPRICE)` as revenue, which is
    the same tax-inclusive mistake Module 3 later warns about.
- **The notebook compute bills until it's suspended.** The service defaults to a 24-hour
  idle timeout, and **Shut down kernel** doesn't stop it. In this run it still showed
  `RUNNING` until `ALTER SERVICE … SUSPEND`.
- **Cell numbers shift by one** after the compatibility cell. Follow the cell titles.
  The grader only checks objects, so it isn't affected.
- **Where the notebook is uploaded matters.** Uploading into a git-linked Workspace puts
  it in that repo's pending changes (plus a modified `.gitignore`). Use a workspace that
  isn't linked to git, or don't commit from it.
