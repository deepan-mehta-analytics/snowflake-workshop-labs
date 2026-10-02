# Step 2 — Build the `Sales_AI` agent (guide steps 4–9) and test it in CoWork

Built in the Snowsight UI, as the guide teaches. Not checked by the auto-grader.
Steps match the Agent Studio layout seen on 2026-10-02 (tabs: Overview / Configuration /
Access / Evaluations; Configuration sub-tabs: General / Instructions / Tools / Skills / MCP).

**Rules for the whole page**
- Role **`SNOWFLAKE_INTELLIGENCE_ADMIN`** (bottom-left avatar → Switch Role). As ACCOUNTADMIN
  the create fails: only that role has CREATE AGENT on `SNOWFLAKE_INTELLIGENCE.AGENTS`.
- **Never upload a file.** A new stage would change the grader's exact stage count (BWSI02 = 7).
- **Saved = draft only.** Click **Publish** (top right) at the end, or CoWork won't see it.
- Ignore the Overview tab's "Agent readiness" list; evals cost a paid agent call per question.

## A. Create the agent

1. Snowsight left menu → **AI & ML → Agents** → **Create agent**
2. Database / schema: **`SNOWFLAKE_INTELLIGENCE.AGENTS`**
3. Object name: **`Sales_AI`** · Display name: **`Sales//AI`**
4. Click **Create** → the agent opens on the **Overview** tab

## B. General — description

1. **Configuration** tab → **General** sub-tab
2. Description, paste:
   > Sales and marketing assistant for the retail demo data. Answers questions about sales by product category and campaign performance using Cortex Analyst, searches customer support tickets with Cortex Search, and can email a summary of its findings. Prefers charts whenever an answer can be shown visually.
3. Check display name = `Sales//AI`

## C. Tool 1 — Cortex Analyst

1. **Configuration** → **Tools** sub-tab → section **Query structured data** → **+ Add semantic view**
2. Dialog "Add tool: Cortex Analyst" → **Schema** dropdown: **`DASH_DB_SI.RETAIL`**
3. **Stage** dropdown (defaults to "Stage: All") → **`SEMANTIC_MODELS`**
4. In the file box, click **`marketing_campaigns.yaml`**
5. Name: **`Sales_And_Marketing_Data`**
6. Description, paste:
   > Answers quantitative questions about sales, products, marketing campaign performance and social media metrics for the retail demo data. Use for trends, totals, comparisons and anything that needs a chart.
7. **Scroll down** in the dialog → Warehouse **`DASH_WH_SI`** · Query timeout **`60`**
8. Click **Add**

## D. Tool 2 — Cortex Search

1. Same **Tools** page → section **Search documents and unstructured data** → **+ Add search service**
2. **Schema** dropdown: **`DASH_DB_SI.RETAIL`**
3. Search service: **`SUPPORT_CASES`** (not `CAMPAIGN_SEARCH`)
4. ID column: **`ID`** · Title column: **`TITLE`**
5. Name: **`Support_Cases`**
6. Description, paste:
   > Searches customer support ticket transcripts by meaning. Use for questions about product issues, complaints, defects or what customers are saying about a product.
7. Click **Add**

## E. Tool 3 — Send_Email (custom tool)

1. Same **Tools** page → section **Custom tools** → **+ Add**
2. Resource type: **Procedure**
3. Database / schema: **`DASH_DB_SI.RETAIL`** → procedure **`SEND_EMAIL`** (3 VARCHAR args)
4. Name: **`Send_Email`**
5. Warehouse: **Custom → `DASH_WH_SI`** · Query timeout: **`60`** — the timeout is
   required in practice: on 2026-10-02 the warehouse saved as `""` until a timeout was set
6. Description, paste:
   > Sends an email. Use only when the user asks to email or send results. Put the findings in the body as HTML.
7. Parameter descriptions (one box each), paste:
   - `recipient_email` → `Email address to send to. Must be the user's verified Snowflake email.`
   - `subject` → `Short subject line summarising the email.`
   - `body` → `Email content in HTML.`
8. Click **Add**

## F. Instructions and sample questions

1. **Configuration** → **Instructions** sub-tab
2. Orchestration instructions, paste:
   > Whenever you can answer visually with a chart, always choose to generate a chart even if the user didn't specify to.
3. Sample questions, add 3:
   - `Show me the trend of sales by product category between June and August`
   - `What issues are reported with jackets recently in customer support tickets?`
   - `Why did sales of Fitness Wear grow so much in July?`
4. Optional: **Tools** page → **Code Execution tool** toggle → off (not in the guide)

## G. Save, publish, verify

1. Click **Save** → then **Publish** (top right)
2. **Access** tab → confirm role **`SNOWFLAKE_INTELLIGENCE_ADMIN`** is listed
3. Leave the agent, reopen it → **Tools** sub-tab shows all **3 tools**
4. In a worksheet, run and check the spec lists 3 tools and `DASH_WH_SI`:

```sql
DESCRIBE AGENT snowflake_intelligence.agents.sales_ai;   -- agent_spec column: 3 tools, warehouse DASH_WH_SI
```

## H. Test in CoWork

1. Open **`https://ai.snowflake.com/_deeplink/#/ai`**
2. Bottom-left / settings: role **`SNOWFLAKE_INTELLIGENCE_ADMIN`** · warehouse **`DASH_WH_SI`**
3. Agent picker → **`Sales//AI`** (not listed? → back in Agent Studio, Overview → **Connect to Snowflake CoWork**)
4. Ask the 3 sample questions (the sales trend should come back as a chart)
5. Ask: `Email a short summary of the jacket support issues to <your Snowflake user's email>`
6. Check your inbox

**Cost note:** each agent question ≈ 0.15 credits (~$0.50) — see
`snowflake-cortex-ai/docs/cost/cost_analysis.md`. The 4 test questions ≈ $2.
