# ❄️ Snowflake Workshop Labs

## ⚡ Quick Summary

This repo records every Snowflake hands-on workshop badge lab I have completed: the lab scripts as Snowflake published them, plus a README per lab documenting how it was actually run on a live trial account, including the setup that worked and the costs it ran up. All nine labs passed Snowflake's own auto-graders and earned an official, verifiable **Snowflake credential**: six Northstar badges, the Accelerate AI Development badge, and two Expedition 2026 badges. The full list is in my 🏅 [credential wallet](https://developerbadges.snowflake.com/profile/supernovasurfersolutions/wallet).

The labs cover data engineering (COPY INTO, UDFs and Streamlit in Snowflake), declarative Dynamic Table pipelines, event-driven S3 ingestion with Snowpipe, open Apache Iceberg tables cleaned and reconciled with Cortex Code (Snowflake's AI coding agent), Snowflake Intelligence agents used through Snowflake CoWork, and a RAG + text-to-SQL notebook evaluated with LLM-as-judge scoring. My original project work lives separately in the flagship repo, [`snowflake-cortex-ai`](https://github.com/deepan-mehta-analytics/snowflake-cortex-ai). This repo is the badge evidence, kept apart from it.

### Verified Snowflake badge labs — run live, auto-graded, documented honestly

---

## 🏷️ Project Badges

[![Snowflake](https://img.shields.io/badge/Snowflake-Data_Cloud-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![SQL](https://img.shields.io/badge/SQL-Snowflake-4479A1?style=for-the-badge&logo=snowflake&logoColor=white)](https://docs.snowflake.com/)
[![Cortex AI](https://img.shields.io/badge/Cortex-Agents_%2B_CoCo-6E56CF?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Streamlit](https://img.shields.io/badge/Streamlit-in_Snowflake-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
[![Credentials](https://img.shields.io/badge/Snowflake_Credentials-9_Issued-success?style=for-the-badge&logo=snowflake&logoColor=white)](https://developerbadges.snowflake.com/profile/supernovasurfersolutions/wallet)
[![Northstar](https://img.shields.io/badge/Northstar_Badges-6-success?style=for-the-badge)](https://developerbadges.snowflake.com/profile/supernovasurfersolutions/wallet)
[![AWS](https://img.shields.io/badge/AWS-S3_%2B_IAM-FF9900?style=for-the-badge&logo=amazonwebservices&logoColor=white)](getting-started-with-snowpipe/)
[![Apache Iceberg](https://img.shields.io/badge/Apache_Iceberg-Snowflake--managed-2E6DB4?style=for-the-badge)](expedition-campaign-planning/)
[![Expedition 2026](https://img.shields.io/badge/Expedition_2026_Badges-2-success?style=for-the-badge&logo=snowflake&logoColor=white)](https://developerbadges.snowflake.com/profile/supernovasurfersolutions/wallet)

---

## 📌 Project Overview

This repo is **a verified log of Snowflake workshop labs, each run end-to-end on a live account, checked by Snowflake's auto-grader and backed by an official credential**.

### 🛠️ Data engineering labs

- 🚚 **Data Engineering with Snowflake** — Tasty Bytes ingestion with `COPY INTO`, a Marketplace weather share, UDFs and a Streamlit-in-Snowflake app *(BWITD01–06 passed)*
- 🔗 **Declarative Data Pipelines with Dynamic Tables** — chained Dynamic Tables with `TARGET_LAG = DOWNSTREAM` over synthetic customer/order data *(BWDT01–07 passed)*
- 📥 **Getting Started with Snowpipe** — event-driven loading from an S3 bucket in AWS Tokyo through a storage integration, an external stage and an auto-ingest pipe *(BWSS01–04 passed)*
  - Additions to the guide applied, including a quoting fix and a step to resume the pipe
  - A silent "nothing loads" failure traced to an S3 event notification that had never saved
  - Auto-ingest then proven end to end: about 20 s from event to load

### 🤖 AI and agent labs

- 🧑‍💻 **CoCo Foundations** — a 4-source AP invoice pipeline built through prompts to Cortex Code in Snowsight *(BWCC01–05 passed)*
- 🕵️ **From Zero to Agents** — Snowflake Intelligence: semantic view, Cortex Search service and a Cortex Agent over retail/marketing data *(BWZA01–06 passed)*
- 💬 **Getting Started with Snowflake CoWork** — a `Sales//AI` agent with Cortex Analyst, Cortex Search and an email tool, tested in Snowflake CoWork *(BWSI01–06 passed)*
  - Its answers were checked against the data, which caught a partial-month blind spot and an unsupported "ad spend" claim
- 🧠 **Accelerate App Dev with Cortex Code** — RAG over a Cortex Search service with LLM-as-judge evaluation, then naive LLM text-to-SQL vs. a semantic view with Cortex Analyst *(BWRA01–06 passed)*
  - Naive SQL was +4% off on revenue and 2.85× off on COGS; Cortex Analyst matched the gold standard on all 10 figures
  - Two retired models handled with a single added compatibility cell

### 🧭 Expedition 2026 labs (Iceberg + CoCo + agents)

- 📅 **Campaign Planning, Simplified (Day 2)** — three messy campaign exports landed in Snowflake-managed Iceberg tables, cleaned with CoCo into 27 campaigns, and 9 audience collisions worth $557,500 found; semantic view + Cortex Agent on top *(BWEM01–05 passed)*
  - A Draft campaign CoCo wanted to drop was kept, because the guide drops only cancelled ones and the grader expects 27
- 🧾 **Close Faster, Audit Smarter (Day 3)** — payroll, general ledger and bank exports reconciled into a 46-row Iceberg ledger; every bank payment matched to the GL, leaving 2 gaps that explain the full $47,200 difference *(BWEF01–05 passed)*
  - Prompt additions kept bank rows as Unknown / Uncategorized after CoCo inferred their categories from descriptions
- 🛡️ Both run with an account-wide setting change from the notebook's setup cell commented out (cross-region stayed `AWS_US`)

### 📝 Documentation in every lab

- 🔍 **Per-lab run notes** — every guide step cross-checked against the real companion repo or raw files, including two cases where an AI web summary invented steps or repo paths
- 💰 **Cost and safety notes** — where a guide's script uses a larger warehouse than the lab needs, and how auto-grader scripts and output carrying personal data were kept out of git

---

## ⚙️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| ❄️ Platform | Snowflake (trial account) | Storage, compute and grading for every lab |
| 📥 Ingestion | `COPY INTO`, external stages, Marketplace shares, Snowpipe (auto-ingest) | Batch and event-driven loading of lab data |
| ☁️ Cloud (AWS) | S3, IAM role + trust policy, S3 event notifications → SQS | Source bucket and secure access for Snowpipe |
| 🔄 Transformation | SQL, UDFs, Dynamic Tables | Batch and declarative incremental pipelines |
| 🧊 Open table format | Apache Iceberg (Snowflake-managed, `EXTERNAL_VOLUME = 'SNOWFLAKE_MANAGED'`) | Raw and curated tables other engines can read, with no cloud bucket to manage |
| 🤖 AI | Cortex Code (CoCo), Cortex `COMPLETE`, Cortex Analyst, Cortex Search, Cortex Agents | AI-assisted development, RAG, text-to-SQL and agents over the data |
| 📊 App | Streamlit in Snowflake | Delivery layer in the data engineering lab |
| 🖥️ Interface | Snowsight worksheets, CoCo panel, Workspaces notebooks (incl. Git-backed workspaces), Agent Studio, Snowflake CoWork | Where the labs are built and the agents tested |

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
 Snowflake auto-grader (one Run All in a scratch worksheet; local copy gitignored)
              │
              ▼
 README.md per lab  (what actually happened, costs, fixes)
              │
              ▼
 Official credential issued by Snowflake (after the workshop's grading closes)
```

| Lab folder | Snowflake objects it owns |
|---|---|
| 🚚 `northstar-data-engineering/` | `TASTY_BYTES` database, `DEMO_BUILD_WH` (dropped at the end) |
| 🔗 `declarative-dynamic-tables/` | `RAW_DB`, `ANALYTICS_DB`, `COMPUTE_WH` |
| 🧑‍💻 `coco-foundations/` | `COCO_WORKSHOP` database, `COCO_WORKSHOP_WH` |
| 🕵️ `from-zero-to-agents/` | `DASH_DB_SI`, `DASH_WH_SI`, `SNOWFLAKE_INTELLIGENCE_ADMIN` role |
| 💬 `snowflake-cowork/` | Reuses the `from-zero-to-agents/` objects; adds the `SUPPORT_CASES` search service and the `SNOWFLAKE_INTELLIGENCE.AGENTS.SALES_AI` agent |
| 🧠 `accelerate-app-dev-coco/` | `AI_WORKSHOP_DB` (`RAG_DATA`, `ANALYTICS`), `WORKSHOP_WH`, a notebook service in the personal database (suspended after the run) |
| 📥 `getting-started-with-snowpipe/` | `S3_DB`, `S3_ROLE`, `S3_ROLE_INTEGRATION`, plus an S3 bucket and IAM role in AWS. All dropped after grading |
| 📅 `expedition-campaign-planning/` | `MERIDIAN_STAY` (`RAW`, `CURATED`, `ANALYTICS`; Iceberg tables, semantic view, agent). Dropped after grading |
| 🧾 `expedition-close-faster/` | `MERIDIAN_STAY_FINANCE` (`RAW`, `CURATED`, `ANALYTICS`; Iceberg tables, semantic view, agent). Dropped after grading |

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
├── snowflake-cowork/                  ← Northstar: Getting Started with Snowflake CoWork
│   ├── README.md                      ← run notes, agent test results, known limitations
│   ├── 01_support_cases_search.sql    ← Cortex Search service SUPPORT_CASES + verification
│   └── 02_sales_ai_agent_steps.md     ← click-by-click Agent Studio + CoWork checklist
│
├── accelerate-app-dev-coco/           ← Accelerate App Dev with Cortex Code (Accelerate AI Development badge)
│   ├── README.md                      ← RAG eval scores, text-to-SQL comparison, cost, limitations
│   ├── 00_preflight_checks.sql        ← read-only checks: name collisions, settings, region, models
│   ├── 01_run_steps.md                ← click-by-click checklist A–F incl. the compatibility cell
│   └── assets/                        ← guide source + notebook, as published
│
├── getting-started-with-snowpipe/     ← Northstar: Getting Started with Snowpipe (S3 auto-ingest)
│   ├── README.md                      ← grader result, end-to-end load proof, debugging trace, run notes
│   ├── 00_preflight_checks.sql        ← read-only checks: name collisions, default role, region
│   ├── 01_run_steps.md                ← click-by-click AWS + Snowflake checklist A–I with fixes
│   ├── 99_teardown.sql                ← drops all lab objects, restores the default role
│   └── assets/                        ← guide source, as published
│
├── expedition-campaign-planning/      ← Expedition 2026 Day 2: Campaign Planning with CoCo + CoWork
│   ├── README.md                      ← grader result, 33 → 27 campaigns, 9 collisions, run notes
│   ├── 00_preflight_checks.sql        ← read-only checks: name collisions, cross-region setting, services
│   ├── 01_run_steps.md                ← click-by-click checklist A–G with paste-ready CoCo prompts
│   ├── 99_teardown.sql                ← suspends the notebook service, drops the lab database
│   └── assets/                        ← guide source, notebook and Streamlit app, as published
│
├── expedition-close-faster/           ← Expedition 2026 Day 3: Close Faster, Audit Smarter
│   ├── README.md                      ← grader result, 46-row ledger, 2 gaps = $47,200, run notes
│   ├── 00_preflight_checks.sql        ← read-only checks: name collisions, cross-region setting, services
│   ├── 01_run_steps.md                ← click-by-click checklist A–G with paste-ready CoCo prompts
│   ├── 99_teardown.sql                ← suspends the notebook service, drops the lab database
│   └── assets/                        ← guide source, notebook and Streamlit dashboard, as published
│
└── .gitignore                         ← keeps grader scripts, grader dry runs and worksheet dumps out of git
```

---

## ▶️ How to Run

### 📌 Option 1 — Snowsight (how every lab was run)

#### 1️⃣ Clone the repository
```bash
git clone https://github.com/deepan-mehta-analytics/snowflake-workshop-labs.git
cd snowflake-workshop-labs
```

#### 2️⃣ Pick a lab and read its README first
Each lab's README lists its prerequisites, the order of steps and any cost warnings, such as warehouse sizes to check before running.

#### 3️⃣ Run the scripts in Snowsight
Open the lab's `assets/` scripts in a Snowsight worksheet and follow the README's steps in order. Some labs differ:

- 🧑‍💻 **`coco-foundations/`** — paste the prompts into the CoCo panel instead of a worksheet
- 💬 **`snowflake-cowork/`** — has no `assets/` folder; run its numbered files after `from-zero-to-agents/`
- 🧠 **`accelerate-app-dev-coco/`** — runs its notebook in Workspaces; follow `01_run_steps.md`
- 📥 **`getting-started-with-snowpipe/`** — also needs an AWS account; its `01_run_steps.md` alternates between the AWS console and Snowsight, and `99_teardown.sql` plus section I remove everything afterwards
- 🧭 **`expedition-*/`** — create a Git-backed workspace from the companion repo (Public repository), then follow `01_run_steps.md`; most steps are CoCo prompts, pasted as given

#### 4️⃣ Run the auto-grader
Get the personalised grader script from the workshop platform, then:

- ▶️ Run it **once, in full (Run All)**, in a scratch worksheet
- 🔒 It contains your registration email, so keep any local copy out of git (`*.local.sql` is gitignored) and don't export its output
- 🧾 Confirm the submission in query history rather than the result screen

---

## 🧪 Tests

There's no automated test suite. Each lab is checked by Snowflake's own auto-grader, which verifies the objects, structure and row counts in the account. Results are recorded in each lab's README.

---

## 📊 Results / Performance

### 🏅 Credentials

**9 official credentials**: 7 issued by Snowflake Developers and 2 by Snowflake Marketing ([wallet](https://developerbadges.snowflake.com/profile/supernovasurfersolutions/wallet)). Each link below opens the verifiable credential.

| Lab folder | Credential (official title) | Issued | Grader checks | Result |
|---|---|---|---|---|
| 🚚 `northstar-data-engineering/` | [Northstar - Data Ingestion, Transformation, and Delivery with Snowflake](https://developerbadges.snowflake.com/fa443254-ddb7-4c0c-be05-c8b51643ca2e) | 2026-07-24 | BWITD01–06 | ✅ Passed |
| 🔗 `declarative-dynamic-tables/` | [Creating Declarative Data Pipelines with Dynamic Tables](https://developerbadges.snowflake.com/6bee48dc-af73-441d-8bf5-492b40ed9952) (Northstar) | 2026-07-24 | BWDT01–07 | ✅ Passed |
| 🧑‍💻 `coco-foundations/` | [Northstar - Getting Started with Cortex Code](https://developerbadges.snowflake.com/9354da7d-5564-4aae-a353-3669cdd0fb49) | 2026-07-24 | BWCC01–05 | ✅ Passed |
| 🕵️ `from-zero-to-agents/` | [From Zero to Agents: Building End-To-End Data Pipelines for an AI Agent](https://developerbadges.snowflake.com/61240fa4-7eb0-4942-a4ca-818d87759592) (Northstar) | 2026-07-24 | BWZA01–06 | ✅ Passed |
| 💬 `snowflake-cowork/` | [Building Intelligent Data Application with Snowflake](https://developerbadges.snowflake.com/a2e44f0f-e82b-41be-a48c-ad01ce5fd1ba) (Northstar) | 2026-10-15 | BWSI01–06 | ✅ Passed; the ungraded `Sales//AI` agent also passed 4/4 CoWork tests |
| 🧠 `accelerate-app-dev-coco/` | [Accelerate AI Development: Building AI Applications with Snowflake Cortex: RAG, Text-to-SQL & CoCo](https://developerbadges.snowflake.com/8a2d878d-a3ac-434a-bb96-276e7cd8caa6) | 2026-10-15 | BWRA01–06 | ✅ Passed; RAG eval means 0.80 / 0.96 / 0.90 (groundedness / context / answer relevance) |
| 📥 `getting-started-with-snowpipe/` | [Northstar - Build an Automated Data Pipeline with Snowpipe](https://developerbadges.snowflake.com/f5d91b83-916f-4a92-bacb-8193671f49be) | 2026-10-15 | BWSS01–04 | ✅ Passed (one day after the live workshop); auto-ingest proven: S3 upload → loaded in ~20 s, no duplicate on refresh |
| 📅 `expedition-campaign-planning/` | [Campaign Planning, Simplified: Build It with CoCo, Ask It with CoWork](https://developerbadges.snowflake.com/7c5056dc-f523-4c3f-ba3f-0c8549aa3734) (Expedition 2026 Day 2) | 2026-11-08 | BWEM01–05 | ✅ Passed; 27 campaigns, 9 collisions, $557,500 |
| 🧾 `expedition-close-faster/` | [Close Faster, Audit Smarter: Build It with CoCo, Ask It with CoWork](https://developerbadges.snowflake.com/5c685561-252e-409a-8909-0396318e0327) (Expedition 2026 Day 3) | 2026-11-08 | BWEF01–05 | ✅ Passed; 46 transactions, 2 gaps = $47,200 |

- 🏷️ "(Northstar)" marks credentials whose title doesn't say Northstar but whose description does.
- 📅 Credentials are issued after a workshop's grading closes, not when the grader runs: the October labs were graded on 2026-10-02/03 and issued on 2026-10-15. The Expedition labs were the exception: graded on 2026-11-08, two days after the event (4–6 Nov), and issued by Snowflake Marketing the same day.
- 🔀 The first four were run Day 2 before Day 1; each README documents its own setup, independent of that order.

### 🧮 Text-to-SQL, BUILDING segment

From `accelerate-app-dev-coco/`:

| Metric | Gold standard | Naive LLM SQL | Cortex Analyst + semantic view |
|---|---|---|---|
| Revenue | $44.14 B | $45.91 B (+4.0%) | $44.14 B ✅ |
| Cost of goods sold | $15.49 B | $44.14 B (2.85×) | $15.49 B ✅ |

---

## ⚠️ Known Limitations

### 📜 Scope

- **The lab scripts are Snowflake's, not mine.** They are kept as published so the auto-graders still match. My contribution is the verified run notes, fixes and cost guidance in each README.
- **The Snowpipe credential describes more than this lab covers.** Its description lists the live workshop's content (test data generation, key-pair auth, the Python connector, streaming). This repo ran the public guide's file-based S3 auto-ingest, which is what the grader checks. Key-pair auth, the Python connector and Snowpipe Streaming weren't done here.

### 📚 Guides and platform

- **Guide links may stop resolving.** The `Snowflake-Labs/sfquickstarts` repo didn't resolve when `declarative-dynamic-tables/` was run, so its assets were recovered from other sources (documented in that README). The repo was live again by 2026-10-02.
- **Snowsight's UI changes between guide versions.** Menu paths in the READMEs reflect the UI at the time each lab was run.
- **The CoWork grader's summary query can fail.** Its final `WITH check_results` block intermittently throws a JSON / UTF-8 parse error. It runs only in your own account, so the submission is unaffected; query history is the proof (see `snowflake-cowork/`).
- **Retired models in published notebooks.** `accelerate-app-dev-coco/` hard-codes `mistral-large2` and `llama3-70b`, both retired. One added cell redirects them to `llama3.3-70b`, so its LLM scores aren't directly comparable to the guide's.
- **Expedition notebooks change an account setting.** Each setup cell ends with `ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'`. The graders don't check it, so the line was commented out and the account stayed on `AWS_US`.
- **Expedition CoWork steps weren't run.** CoWork wasn't enabled in this account, and enabling it is an account-wide change. Both agents were built and graded but not queried, and the optional Streamlit apps were skipped (none of this is graded).
- **The Snowpipe guide needs a few additions to run end to end.** The storage integration needed a quoting fix, the pipe had to be resumed after creation, the default-role change had to be reverted at teardown, and a test load was added to prove ingestion. All of these are in `getting-started-with-snowpipe/`.

### 🤖 Agents

- **The Agent Studio save issue.** In `from-zero-to-agents/`, an agent saved through Snowsight's Agent Studio lost a tool and pointed at the wrong warehouse. It happened again in `snowflake-cowork/`, where a tool's warehouse saved as blank. The fixes are in those READMEs.
- **Agent answers need checking.** In `snowflake-cowork/`, the agent treated a partial month as a full one and claimed a decline in ad spend from a table with no spend column. Both are documented in that README.

### 💸 Silent costs and failures

- **Notebook compute can keep billing after "Shut down kernel".** The Workspaces notebook service defaults to a 24-hour idle timeout. It stayed `RUNNING` after shutdown in `accelerate-app-dev-coco/` and Expedition Day 3 (but not Day 2), so check `SHOW SERVICES` and suspend it explicitly (`ALTER SERVICE … SUSPEND`).
- **A missing S3 event notification fails silently.** Nothing errors; files just never load. Check the bucket's notification card, and use `ALTER PIPE … REFRESH` for files uploaded before it existed.

---

## 🔜 Roadmap

- 📥 A standalone Snowpipe ingestion project, only with original work beyond the guide (Terraform for the AWS and Snowflake setup, scripted teardown, load monitoring and alerting).

---

## 📂 Dataset

All data comes from Snowflake's own workshop material, apart from the last item:

- 🚚 Tasty Bytes sample data and the Pelmorex Frostbyte weather share ([companion repo](https://github.com/Snowflake-Labs/sfguide-snowflake-northstar-data-engineering))
- 🧾 Synthetic AP invoice data ([cortex-code-foundations](https://github.com/hindcraig3/cortex-code-foundations))
- 🛍️ Fictional retail/marketing data ([sfguide-getting-started-with-snowflake-intelligence](https://github.com/Snowflake-Labs/sfguide-getting-started-with-snowflake-intelligence))
- 🔗 Synthetic customer/order data generated by the Dynamic Tables guide's own setup script
- 🧠 TPC-H sample data (`SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`) and a 15-document Snowflake feature corpus written by the notebook ([sfquickstarts guide source](https://github.com/Snowflake-Labs/sfquickstarts/tree/master/site/sfguides/src/accelerate-app-dev-cortex-code))
- 📥 Two hand-written one-column text files uploaded to the Snowpipe lab's S3 bucket (deleted with the bucket)
- 🏨 Fictional Meridian Stay campaign exports and November 2026 payroll / GL / bank exports ([expedition-2026-day-2-hol](https://github.com/Snowflake-Labs/expedition-2026-day-2-hol), [expedition-2026-day-3-hol](https://github.com/Snowflake-Labs/expedition-2026-day-3-hol))

---

## 👤 Author

**Deepan Mehta**

- Data Analytics → Data Engineering → AI/ML Engineering
- Focused on building end-to-end data and ML systems combining analytics, automation, and deployment
- Experience in ETL pipelines, predictive modelling, and analytical databases

🔗 GitHub: [deepan-mehta-analytics](https://github.com/deepan-mehta-analytics)
