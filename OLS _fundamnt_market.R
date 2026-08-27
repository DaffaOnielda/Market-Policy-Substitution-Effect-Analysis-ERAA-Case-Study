# library we're gonna use in this section
library(dplyr)
library(ggplot2)
library(sandwich)
library(lmtest)
library(broom)
library(patchwork)

# quarterly fundamentals (stockbit)
eraa_quarterly_real <- tibble(
  quarter = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4", 
              "2024-Q1", "2024-Q2", "2024-Q3", "2024-Q4",
              "2025-Q1", "2025-Q2", "2025-Q3", "2025-Q4",
              "2026-Q1"),
  sales        = c(14793, 14104, 13919, 17323, 15450, 16010, 16780, 16672, 15882, 19164, 17318, 24243, 22413),
  cogs         = c(13209, 12610, 12513, 15359, 13830, 14330, 15020, 14832, 14088, 16995, 15436, 21737, 20025),
  total_assets = c(20727, 20772, 21558, 20447, 22350, 22700, 23150, 21774, 28353, 28455, 28567, 28857, 31586),
  total_liab   = c(13301, 13467, 13780, 12317, 14650, 14950, 15200, 12717, 19047, 19033, 18927, 18679, 20634),
  total_equity = c(7426,  7305,  7778,  8131,  7700,  7750,  7950,  9057,  9306,  9422,  9640,  10177, 10952)
)

eraa_analysis <- eraa_quarterly_real |>
  mutate(
    lerner_proxy = (sales - cogs) / sales,
    firm_size    = log(total_assets),
    leverage     = total_liab / total_equity,
    policy_dummy = if_else(quarter >= "2024-Q4", 1, 0)
    )

# baseline linear regression
model_ols <- lm(lerner_proxy ~ policy_dummy + firm_size + leverage, data = eraa_analysis)
summary(model_ols)

# check heteroskedasticity
bp_test <- bptest(model_ols)
print(bp_test)

if (bp_test$p.value < 0.05) {model_robust <- coeftest(model_ols, vcov = vcovHC(model_ols, type = "HC1"))
  print(model_robust)}

# coefficient forest plot (figure 5.1D)
ols_results <- tidy(model_ols, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(term = case_when(
    term == "policy_dummy" ~ "Policy Dummy (The Import Ban)",
    term == "firm_size"    ~ "Firm Size (Log Assets)",
    term == "leverage"     ~ "Leverage (Debt-to-Equity)" )
    )

plot_coef <- ggplot(ols_results, aes(x = estimate, y = term)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "darkred", linewidth = 0.8) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2, color = "darkblue", linewidth = 1.2) +
  geom_point(size = 4, color = "darkred") +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Figure 5.1D: Coefficient Forest Plot",
    subtitle = "Isolating the statistical significance of each independent variable",
    x = "Estimated Coefficient Impact",
    y = ""
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12))
# predicted marginal effects (figure 5.1E)
df_hypothetical <- tibble(
  policy_dummy = c(0, 1),
  firm_size    = mean(eraa_analysis$firm_size),
  leverage     = mean(eraa_analysis$leverage))

predictions <- predict(model_ols, newdata = df_hypothetical, interval = "confidence") |>
  as_tibble() |>
  bind_cols(df_hypothetical) |>
  mutate(
    period = if_else(policy_dummy == 0, "Pre-Ban Baseline", "Post-Ban Period"),
    period = factor(period, levels = c("Pre-Ban Baseline", "Post-Ban Period")))

overlap_bottom <- max(predictions$lwr)
overlap_top <- min(predictions$upr)

plot_pred <- ggplot(predictions, aes(x = period, y = fit)) +
  annotate("rect", 
           xmin = -Inf, xmax = Inf, 
           ymin = overlap_bottom, ymax = overlap_top, 
           alpha = 0.8, fill = "darkred") +
  annotate("text", 
           x = "Pre-Ban Baseline", 
           y = (overlap_bottom + overlap_top) / 2, 
           label = "Overlap", 
           color = "white", fontface = "italic", size = 3.5, 
           hjust = -0.2) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.15, color = "darkblue", linewidth = 1.2) +
  geom_point(size = 4.5, color = "red") +
  theme_minimal(base_family = "sans") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Figure 5.1E: Predictive Marginal Effects",
    subtitle = "Comparing fundamental pricing power holding control variables constant",
    x = "",
    y = "Predicted Lerner Proxy (Gross Margin %)",
    caption = "Note: Shaded region highlights the statistical overlap between pre and post ban margins."
  ) +
  theme(plot.title = element_text(face = "bold", size = 12))

# stack diagnostic plots
fig_5_1_combined <- plot_coef / plot_pred
print(fig_5_1_combined)