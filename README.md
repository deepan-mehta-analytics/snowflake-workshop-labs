# ❄️ Snowflake Workshop Labs

## ⚡ Quick Summary

This repo records every Snowflake hands-on workshop and Skill Badge lab I have completed: the lab scripts as Snowflake published them, plus a README per lab documenting how it was actually run on a live trial account. That includes the setup that worked, the costs it ran up and the things the official guide got wrong. All four labs of the **Snowflake Northstar Badge** have been completed and passed Snowflake's own auto-graders, as have the **Getting Started with Snowflake CoWork** and **Accelerate App Dev with Cortex Code** Skill Badge labs.

The labs cover data engineering (COPY INTO, UDFs and Streamlit in Snowflake), declarative Dynamic Table pipelines, Cortex Code (Snowflake's AI coding agent), Snowflake Intelligence agents used through Snowflake CoWork, and a RAG + text-to-SQL notebook evaluated with LLM-as-judge scoring. My original project work lives separately in the flagship repo, [`snowflake-cortex-ai`](https://github.com/deepan-mehta-analytics/snowflake-cortex-ai). This repo is the badge evidence, kept apart from it.

### Verified Snowflake badge labs — run live, auto-graded, documented honestly

---

## 🏷️ Project Badges

[![Snowflake](https://img.shields.io/badge/Snowflake-Data_Cloud-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![SQL](https://img.shields.io/badge/SQL-Snowflake-4479A1?style=for-the-badge&logo=snowflake&logoColor=white)](https://docs.snowflake.com/)
[![Cortex AI](https://img.shields.io/badge/Cortex-Agents_%2B_CoCo-6E56CF?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Streamlit](https://img.shields.io/badge/Streamlit-in_Snowflake-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
[![Northstar](https://img.shields.io/badge/Northstar_Badge-4%2F4_Passed-success?style=for-the-badge)](https://github.com/deepan-mehta-analytics/snowflake-workshop-labs)
[![CoWork](https://img.shields.io/badge/CoWork_Lab-Passed-success?style=for-the-badge)](snowflake-cowork/)
[![App Dev with CoCo](https://img.shields.io/badge/App_Dev_with_CoCo-Passed-success?style=for-the-badge)](accelerate-app-dev-coco/)

---

## 📌 Project Overview

This repo is **a verified log of Snowflake workshop labs, each run end-to-end on a live account and checked by Snowflake's auto-grader**.

It includes:

- **Data Engineering with Snowflake** — Tasty Bytes ingestion with `COPY INTO`, a Marketplace weather share, UDFs and a Streamlit-in-Snowflake app (grader checks BWITD01–06 passed)
- **Declarative Data Pipelines with Dynamic Tables** — chained Dynamic Tables with `TARGET_LAG = DOWNSTREAM` over synthetic customer/order data (BWDT01–07 passed)
- **CoCo Foundations** — a 4-source AP invoice pipeline built through prompts to Cortex Code in Snowsight (BWCC01–05 passed)
- **From Zero to Agents** — Snowflake Intelligence: semantic view, Cortex Search service and a Cortex Agent over retail/marketing data (BWZA01–06 passed)
- **Getting Started with Snowflake CoWork** — a `Sales//AI` agent with Cortex Analyst, Cortex Search and an email tool, tested in Snowflake CoWork; its answers were checked against the data, which caught a partial-month blind spot and an unsupported "ad spend" claim (BWSI01–06 passed)
- **Accelerate App Dev with Cortex Code** — RAG over a Cortex Search service with LLM-as-judge evaluation, then naive LLM text-to-SQL vs. a semantic view with Cortex Analyst. The naive SQL was +4% off on revenue and 2.85× off on COGS; Cortex Analyst matched the gold standard on all 10 figures. Two retired models were handled with a single added compatibility cell (BWRA01–06 passed)
- **Per-lab run notes** — every guide step cross-checked against the real companion repo or raw files, including two cases where an AI web summary invented steps or repo paths
- **Cost and safety notes** — where a guide's script asks for an oversized warehouse, and how auto-grader output carrying personal data was kept off disk

---

## ⚙️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Platform | Snowflake (trial account) | Storage, compute and grading for every lab |
| Ingestion | `COPY INTO`, external stages, Marketplace shares | Loading lab data |
| Transformation | SQL, UDFs, Dynamic Tables | Batch and declarative incremental pipelines |
| AI | Cortex Code (CoCo), Cortex `COMPLETE`, Cortex Analyst, Cortex Search, Cortex Agents | AI-assisted development, RAG, text-to-SQL and agents over the data |
| App | Streamlit in Snowflake | Delivery layer in the data engineering lab |
| Interface | Snowsight worksheets, CoCo panel, Workspaces notebooks, Agent Studio, Snowflake CoWork | Where the labs are built and the agents tested |

---

## 🎯 Business Problem

Workshop guides show the steps that worked when the guide was written. Running them months later on a real account turns up dead links, oversized warehouses, UI changes and graders that check specific object names.

> **Can each Snowflake badge lab be reproduced on a live account, passed by its auto-grader, and documented accurately enough that someone else could rerun it without the same surprises?**

---

## 🏗️ Architecture

Each lab uses its own databases, so no lab can break the flagship project. The one exception to lab isolation is `snowflake-cowork/`, which deliberately builds on the `from-zero-to-agents/` objects. Its README explains why the shared setup script must not be re-run.

```
 Snowflake guide + companion repo
              │
              ▼
 assets/  (scripts kept exactly as published)
              │
              ▼
 Snowsight worksheet / CoCo panel / notebook  ──►  lab-owned database + warehouse
              │
              ▼
 Snowflake auto-grader (run in a scratch worksheet, never saved)
              │
              ▼
 README.md per lab  (what actually happened, costs, fixes)
```

| Lab folder | Snowflake objects it owns |
|---|---|
| `northstar-data-engineering/` | `TASTY_BYTES` database, `DEMO_BUILD_WH` (dropped at the end) |
| `declarative-dynamic-tables/` | `RAW_DB`, `ANALYTICS_DB`, `COMPUTE_WH` |
| `coco-foundations/` | `COCO_WORKSHOP` database, `COCO_WORKSHOP_WH` |
| `from-zero-to-agents/` | `DASH_DB_SI`, `DASH_WH_SI`, `SNOWFLAKE_INTELLIGENCE_ADMIN` role |
| `snowflake-cowork/` | Reuses the `from-zero-to-agents/` objects; adds the `SUPPORT_CASES` search service and the `SNOWFLAKE_INTELLIGENCE.AGENTS.SALES_AI` agent |
| `accelerate-app-dev-coco/` | `AI_WORKSHOP_DB` (`RAG_DATA`, `ANALYTICS`), `WORKSHOP_WH`, a notebook service in the personal database (suspended after the run) |

---

## 📁 Repository Structure

```
snowflake-workshop-labs/
│
├── northstar-data-engineering/        ← Northstar Day 1, Lab 1: Data Engineering with Snowflake
│   ├── README.md                      ← run notes, cost, grader result
│   └── assets/                        ← ingestion, transformation, Streamlit scripts as published
│
├── declarative-dynamic-tables/        ← Northstar Day 1, Lab 2: Declarative pipelines with Dynamic Tables
│   ├── README.md                      ← run notes incl. how the dead companion links were recovered
│   └── assets/                        ← setup, create, chaining and pipeline SQL
│
├── coco-foundations/                  ← Northstar Day 2, Lab 1: Cortex Code Foundations
│   ├── README.md                      ← CoCo panel prompts, step by step
│   └── assets/                        ← sample data, setup/reset SQL, business-requirement CSVs, skill zip
│
├── from-zero-to-agents/               ← Northstar Day 2, Lab 2: Snowflake Intelligence agents
│   ├── README.md                      ← semantic view, search service, agent steps + known issues
│   └── assets/                        ← setup SQL + marketing data CSV
│
├── snowflake-cowork/                  ← Skill Badge: Getting Started with Snowflake CoWork
│   ├── README.md                      ← run notes, agent test results, known limitations
│   ├── 01_support_cases_search.sql    ← Cortex Search service SUPPORT_CASES + verification
│   └── 02_sales_ai_agent_steps.md     ← click-by-click Agent Studio + CoWork checklist
│
├── accelerate-app-dev-coco/           ← Skill Badge: Accelerate App Dev with Cortex Code
│   ├── README.md                      ← RAG eval scores, text-to-SQL comparison, cost, limitations
│   ├── 00_preflight_checks.sql        ← read-only checks: name collisions, settings, region, models
│   ├── 01_run_steps.md                ← click-by-click checklist A–F incl. the compatibility cell
│   ├── 90_verify_grader_checks.sql    ← the grader's 6 lookups, submitting nothing
│   └── assets/                        ← guide source + notebook, as published
│
└── .gitignore                         ← keeps grader exports and worksheet dumps (personal data) out of git
```

---

## ▶️ How to Run

### 📌 Option 1 — Snowsight (how every lab was run)

#### 1. Clone the repository
```bash
git clone https://github.com/deepan-mehta-analytics/snowflake-workshop-labs.git
cd snowflake-workshop-labs
```

#### 2. Pick a lab and read its README first
Each lab's README lists its prerequisites, the order of steps and any cost warnings, such as warehouse sizes to check before running.

#### 3. Run the scripts in Snowsight
Open the lab's `assets/` scripts in a Snowsight worksheet (or paste the prompts into the CoCo panel for `coco-foundations/`) and follow the README's steps in order. `snowflake-cowork/` has no `assets/` folder: run its numbered files after `from-zero-to-agents/`. `accelerate-app-dev-coco/` runs its notebook in Workspaces; follow `01_run_steps.md`.

#### 4. Run the auto-grader
Get the personalised grader script from the workshop platform and run it once, in full (Run All), in a scratch worksheet. It contains your registration email, so keep any local copy out of git (`*.local.sql` is gitignored) and don't export its output. Confirm the submission in query history rather than the result screen.

---

## 🧪 Tests

There's no automated test suite. Each lab is checked by Snowflake's own auto-grader, which verifies the objects, structure and row counts in the account. Results are recorded in each lab's README.

---

## 📊 Results / Performance

**Northstar Badge — 4/4 labs passed.**

| Day | Lab | Grader checks | Result |
|---|---|---|---|
| 1 | Data Engineering with Snowflake | BWITD01–06 | ✅ Passed |
| 1 | Declarative Data Pipelines with Dynamic Tables | BWDT01–07 | ✅ Passed |
| 2 | CoCo Foundations | BWCC01–05 | ✅ Passed |
| 2 | From Zero to Agents | BWZA01–06 | ✅ Passed |

Day 2's labs were completed before Day 1's, which were only discovered afterwards. Each README documents its own setup, independent of that order.

**Skill Badge labs**

| Lab | Grader checks | Result |
|---|---|---|
| Getting Started with Snowflake CoWork | BWSI01–06 | ✅ Passed; the ungraded `Sales//AI` agent also passed 4/4 CoWork tests |
| Accelerate App Dev with Cortex Code | BWRA01–06 | ✅ Passed; RAG eval means 0.80 / 0.96 / 0.90 (groundedness / context / answer relevance) |

**Text-to-SQL, BUILDING segment** (from `accelerate-app-dev-coco/`):

| Metric | Gold standard | Naive LLM SQL | Cortex Analyst + semantic view |
|---|---|---|---|
| Revenue | $44.14 B | $45.91 B (+4.0%) | $44.14 B ✅ |
| Cost of goods sold | $15.49 B | $44.14 B (2.85×) | $15.49 B ✅ |

---

## ⚠️ Known Limitations

- **The lab scripts are Snowflake's, not mine.** They are kept as published so the auto-graders still match. My contribution is the verified run notes, fixes and cost guidance in each README.
- **Guide links can go dead.** The `Snowflake-Labs/sfquickstarts` repo didn't resolve when `declarative-dynamic-tables/` was run, so its assets were recovered from other sources (documented in that README). The repo was live again by 2026-10-02.
- **The CoWork grader's summary query can fail.** Its final `WITH check_results` block intermittently throws a JSON / UTF-8 parse error. It runs only in your own account, so the submission is unaffected; query history is the proof (see `snowflake-cowork/`).
- **Snowsight's UI changes between guide versions.** Menu paths in the READMEs reflect the UI at the time each lab was run.
- **The Agent Studio save bug.** In `from-zero-to-agents/`, an agent saved through Snowsight's Agent Studio lost a tool and pointed at the wrong warehouse. It happened again in `snowflake-cowork/`, where a tool's warehouse saved as blank. The fixes are in those READMEs.
- **Agent answers need checking.** In `snowflake-cowork/`, the agent treated a partial month as a full one and claimed a decline in ad spend from a table with no spend column. Both are documented in that README.
- **Retired models in published notebooks.** `accelerate-app-dev-coco/` hard-codes `mistral-large2` and `llama3-70b`, both retired. One added cell redirects them to `llama3.3-70b`, so its LLM scores aren't directly comparable to the guide's.
- **Notebook compute keeps billing after "Shut down kernel".** The Workspaces notebook service defaults to a 24-hour idle timeout and has to be suspended explicitly (`ALTER SERVICE … SUSPEND`).

---

## 🔜 Roadmap

- `Snowpipe` — event-driven ingestion from AWS S3. It may graduate to its own repo once extended with original work (Terraform, teardown, monitoring).

---

## 📂 Dataset

All data comes from Snowflake's own workshop material:
- Tasty Bytes sample data and the Pelmorex Frostbyte weather share ([companion repo](https://github.com/Snowflake-Labs/sfguide-snowflake-northstar-data-engineering))
- Synthetic AP invoice data ([cortex-code-foundations](https://github.com/hindcraig3/cortex-code-foundations))
- Fictional retail/marketing data ([sfguide-getting-started-with-snowflake-intelligence](https://github.com/Snowflake-Labs/sfguide-getting-started-with-snowflake-intelligence))
- Synthetic customer/order data generated by the Dynamic Tables guide's own setup script
- TPC-H sample data (`SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`) and a 15-document Snowflake feature corpus written by the notebook ([sfquickstarts guide source](https://github.com/Snowflake-Labs/sfquickstarts/tree/master/site/sfguides/src/accelerate-app-dev-cortex-code))

---

## 👤 Author

**Deepan Mehta**

- Data Analytics → Data Engineering → AI/ML Engineering
- Focused on building end-to-end data and ML systems combining analytics, automation, and deployment
- Experience in ETL pipelines, predictive modelling, and analytical databases

🔗 GitHub: [deepan-mehta-analytics](https://github.com/deepan-mehta-analytics)
