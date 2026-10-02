# ❄️ Snowflake Workshop Labs

## ⚡ Quick Summary

This repo records every Snowflake hands-on workshop and Skill Badge lab I have completed: the lab scripts as Snowflake published them, plus a README per lab documenting how it was actually run on a live trial account. That includes the setup that worked, the costs it ran up and the things the official guide got wrong. All four labs of the **Snowflake Northstar Badge** have been completed and passed Snowflake's own auto-graders.

The labs cover data engineering (COPY INTO, UDFs and Streamlit in Snowflake), declarative Dynamic Table pipelines, Cortex Code (Snowflake's AI coding agent) and Snowflake Intelligence agents. My original project work lives separately in the flagship repo, [`snowflake-cortex-ai`](https://github.com/deepan-mehta-analytics/snowflake-cortex-ai). This repo is the badge evidence, kept apart from it.

### Verified Snowflake badge labs — run live, auto-graded, documented honestly

---

## 🏷️ Project Badges

[![Snowflake](https://img.shields.io/badge/Snowflake-Data_Cloud-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![SQL](https://img.shields.io/badge/SQL-Snowflake-4479A1?style=for-the-badge&logo=snowflake&logoColor=white)](https://docs.snowflake.com/)
[![Cortex AI](https://img.shields.io/badge/Cortex-Agents_%2B_CoCo-6E56CF?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Streamlit](https://img.shields.io/badge/Streamlit-in_Snowflake-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
[![Northstar](https://img.shields.io/badge/Northstar_Badge-4%2F4_Passed-success?style=for-the-badge)](https://github.com/deepan-mehta-analytics/snowflake-workshop-labs)

---

## 📌 Project Overview

This repo is **a verified log of Snowflake workshop labs, each run end-to-end on a live account and checked by Snowflake's auto-grader**.

It includes:

- **Data Engineering with Snowflake** — Tasty Bytes ingestion with `COPY INTO`, a Marketplace weather share, UDFs and a Streamlit-in-Snowflake app (grader checks BWITD01–06 passed)
- **Declarative Data Pipelines with Dynamic Tables** — chained Dynamic Tables with `TARGET_LAG = DOWNSTREAM` over synthetic customer/order data (BWDT01–07 passed)
- **CoCo Foundations** — a 4-source AP invoice pipeline built through prompts to Cortex Code in Snowsight (BWCC01–05 passed)
- **From Zero to Agents** — Snowflake Intelligence: semantic view, Cortex Search service and a Cortex Agent over retail/marketing data (BWZA01–06 passed)
- **Per-lab run notes** — every guide step cross-checked against the real companion repo or raw files, including two cases where an AI web summary invented steps or repo paths
- **Cost and safety notes** — where a guide's script asks for an oversized warehouse, and how auto-grader output carrying personal data was kept off disk

---

## ⚙️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Platform | Snowflake (trial account) | Storage, compute and grading for every lab |
| Ingestion | `COPY INTO`, external stages, Marketplace shares | Loading lab data |
| Transformation | SQL, UDFs, Dynamic Tables | Batch and declarative incremental pipelines |
| AI | Cortex Code (CoCo), Cortex Analyst, Cortex Search, Cortex Agents | AI-assisted development and agents over the data |
| App | Streamlit in Snowflake | Delivery layer in the data engineering lab |
| Interface | Snowsight worksheets and CoCo panel | Where every lab is run |

---

## 🎯 Business Problem

Workshop guides show the steps that worked when the guide was written. Running them months later on a real account turns up dead links, oversized warehouses, UI changes and graders that check specific object names.

> **Can each Snowflake badge lab be reproduced on a live account, passed by its auto-grader, and documented accurately enough that someone else could rerun it without the same surprises?**

---

## 🏗️ Architecture

Each lab is self-contained and uses its own databases, so no lab can break another or the flagship project.

```
 Snowflake guide + companion repo
              │
              ▼
 assets/  (scripts kept exactly as published)
              │
              ▼
 Snowsight worksheet / CoCo panel  ──►  lab-owned database + warehouse
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
Open the lab's `assets/` scripts in a Snowsight worksheet (or paste the prompts into the CoCo panel for `coco-foundations/`) and follow the README's steps in order.

#### 4. Run the auto-grader
Get the personalised grader script from the Northstar platform and run it in a scratch worksheet. Don't save it or its output to disk: it contains your account email and login name.

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

---

## ⚠️ Known Limitations

- **The lab scripts are Snowflake's, not mine.** They are kept as published so the auto-graders still match. My contribution is the verified run notes, fixes and cost guidance in each README.
- **Some guide links are dead.** The `Snowflake-Labs/sfquickstarts` repo no longer resolves, so `declarative-dynamic-tables/` assets were recovered from other sources (documented in that README).
- **Snowsight's UI changes between guide versions.** Menu paths in the READMEs reflect the UI at the time each lab was run.
- **The Agent Studio save bug.** In `from-zero-to-agents/`, an agent saved through Snowsight's Agent Studio lost a tool and pointed at the wrong warehouse. The fix is in that README.

## 🔜 Roadmap

- `CoWork` — Getting Started with Snowflake CoWork
- `Accelerate App Dev with CoCo` — RAG pipeline, notebooks and LLM evaluations
- `Snowpipe` — event-driven ingestion from AWS S3. It may graduate to its own repo once extended with original work (Terraform, teardown, monitoring).

---

## 📂 Dataset

All data comes from Snowflake's own workshop material:
- Tasty Bytes sample data and the Pelmorex Frostbyte weather share ([companion repo](https://github.com/Snowflake-Labs/sfguide-snowflake-northstar-data-engineering))
- Synthetic AP invoice data ([cortex-code-foundations](https://github.com/hindcraig3/cortex-code-foundations))
- Fictional retail/marketing data ([sfguide-getting-started-with-snowflake-intelligence](https://github.com/Snowflake-Labs/sfguide-getting-started-with-snowflake-intelligence))
- Synthetic customer/order data generated by the Dynamic Tables guide's own setup script

---

## 👤 Author

**Deepan Mehta**

- Data Analytics → Data Engineering → AI/ML Engineering
- Focused on building end-to-end data and ML systems combining analytics, automation, and deployment
- Experience in ETL pipelines, predictive modelling, and analytical databases

🔗 GitHub: [deepan-mehta-analytics](https://github.com/deepan-mehta-analytics)
