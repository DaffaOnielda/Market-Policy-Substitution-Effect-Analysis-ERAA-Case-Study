# Market Policy & Substitution Effect Analysis: ERAA Case Study

[![Status: Active Development](https://img.shields.io/badge/status-active--development-red?style=flat-square)](https://github.com/)

> **Note:** This project is currently in **active development**. Datasets, robustness checks, and econometric scripts are continuously being updated as new financial filings are published.

---

## Objective
This personal summer project explores the microeconomic **consumer substitution effect** in response to strict government supply quotas (e.g., the iPhone 16 import restriction). Using PT Erajaya Swasembada Tbk (ERAA) as a case study, this analysis investigates how capital held by consumers is dynamically reallocated within a multi-brand ecosystem and how it impacts the firm's aggregate gross margin.

This project tries to answer two Qs:
1. Did the import ban actually damage ERAA's pricing power and margins?
2. How did stock traders react, and how long did the panic/volatility last?

---

## Key Findings

- The policy shock variable was statistically insignificant ($p = 0.159$). ERAA's gross margins were barely affected by the ban—quarterly profitability was mostly driven by normal retail cycles, FX rates (USD/IDR), and promotional campaigns.
- Because ERAA distributes multiple brands (Samsung, Xiaomi, etc.), consumer demand didn't vanish—buyers simply shifted their spending to other available flagships within the same retail ecosystem.
- While business fundamentals remained stable, daily stock returns experienced prolonged volatility clustering ($\beta_1 = 0.9107$). Investors took almost a full year to price in the actual operational reality.

---

## Models Used

### 1. Fundamental Pricing Power (Quarterly OLS)
Tests whether the policy ban reduced ERAA's Lerner Proxy (Gross Margin) after controlling for asset size and debt leverage:

$$\text{lerner\_proxy}_t = \beta_0 + \beta_1 \text{policy\_dummy}_t + \beta_2 \text{firm\_size}_t + \beta_3 \text{leverage}_t + \varepsilon_t$$

### 2. Market Risk & Volatility Clustering (Daily GARCH 1,1)
Tracks daily return volatility over 800+ trading days to measure how long market panic persisted post-announcement:

$$\sigma_t^2 = \omega + \alpha_1 a_{t-1}^2 + \beta_1 \sigma_{t-1}^2$$

### 3. Brand Substitution Effect (Quarterly OLS)
Examines the shift between Samsung and Apple purchasing shares relative to margin log-odds:

$$\text{log\_odds}_t = \beta_0 + \beta_1 \text{sub\_ratio}_t + \beta_2 \ln(\text{assets})_t + \beta_3 \ln(\text{equity})_t + \varepsilon_t$$

---

## Repository Structure

```text
├── data/
│   ├── quarterlyCOGS.csv                 # Supplier breakdown & procurement data
│   ├── GSCPI.csv                         # NY Fed Global Supply Chain Pressure Index
│   ├── [DATAFRAME] eraa_final_daily.RData # Processed daily returns & volatility
│   └── Inflasi Bulanan (M-to-M)...       # Macro inflation controls
│
├── scripts/
│   ├── 01_garch_market_volatility.R      # Daily GARCH(1,1) modeling & volatility plots
│   ├── 02_ols_fundamental_market_power.R # Lerner Proxy OLS & diagnostic plots
│   ├── 03_ols_brand_substitution.R       # Brand substitution regression & time series
│   ├── 04_macro_supply_chain_controls.R  # Semiconductor (SOXX) & GSCPI comparisons
│   └── 05_theoretical_variance_simulation.R # Monte Carlo demo: Homoskedastic vs GARCH
│
├── README.md
└── LICENSE
