# Market Policy & Substitution Effect Analysis: ERAA Case Study

## Objective
This project explores the microeconomic **consumer substitution effect** in response to strict government supply quotas (e.g., the iPhone 16 import restriction). Using PT Erajaya Swasembada Tbk (ERAA) as a case study, this analysis investigates how capital held by consumers is dynamically reallocated within a multi-brand ecosystem and how it impacts the firm's aggregate gross margin.

## Data & Scope
*   **Timeframe:** Q1 2023 – Q2 2026 (14 Quarters)
*   **Data Source:** Consolidated Financial Statements of PT Erajaya Swasembada Tbk (ERAA) published via the Indonesia Stock Exchange (IDX).
*   **Key Variables Extracted:** Total COGS, Gross Margin, and absolute purchase values/ratios for major suppliers (Apple, Samsung, Xiaomi).

## Methodology
This project heavily emphasizes **data-driven decision-making in economics and corporate finance**. 
An Ordinary Least Squares (OLS) regression model was engineered in **R** to evaluate the relationship between supplier substitution and margin insulation:

`lm(log_odds ~ sub_ratio + ln_ast + ln_eq, data = df_cleaned)`

*   **`log_odds`**: Log-transformed Gross Margin ratio (Dependent Variable).
*   **`sub_ratio`**: Substitution ratio indicating capital shifts between Samsung and Apple.
*   **`ln_ast` & `ln_eq`**: Log-transformed Total Assets and Total Equity serving as financial control variables.

## Key Findings
*   **Capital Reallocation:** Empirically substantiates that consumer demand does not vanish under strict product quotas; it shifts to the next best compliant alternatives (e.g., Samsung, Xiaomi).
*   **Corporate Hedging:** Proves that operating as a highly diversified, multi-brand distributor acts as a natural hedge, perfectly insulating the company's aggregate gross margin from isolated regulatory interventions.

## Tech Stack
*   **Language and Tools:** R, Python, Microssoft Excel.
*   **Output:** Dynamic R Markdown (`.Rmd`) reports compiling descriptive statistics, ANOVA, and unstandardized coefficients panels.
