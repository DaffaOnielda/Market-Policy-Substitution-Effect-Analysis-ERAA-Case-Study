library(tidyverse)

# read purchasing data and clean
df_raw_eraa <- read_csv("quarterlyCOGS.csv")

df_cleaned <- df_raw_eraa |>
  mutate(
    gm        = (revenue - cogs) / revenue,
    log_odds  = log(gm / (1 - gm)),
    sub_ratio = samsung_pct / apple_pct,
    ln_ast    = log(total_assets),
    ln_eq     = log(total_equity)
  )

# estimate substitution effect on margin log-odds (inclues ANOVA)
ols_substitution <- lm(log_odds ~ sub_ratio + ln_ast + ln_eq, data = df_cleaned)
summary(ols_substitution)
anova(ols_substitution)

# substitution ratio trend over quarters
fig_substitution_trend <- df_cleaned |>
  ggplot(aes(x = quarter, y = sub_ratio, group = 1)) +
  geom_line(color = "blue", linewidth = 1) +
  geom_point(color = "red", size = 3) +
  geom_vline(xintercept = "2024-Q4", linetype = "dashed", color = "red", alpha = 0.9) + 
  theme_minimal(base_family = "sans") +
  labs(
    title = "ERAA Samsung-to-Apple Substitution Ratio Trend",
    subtitle = "Quarterly Time Series Line Chart (TS LC)",
    x = "Quarter",
    y = "Substitution Ratio (Samsung / Apple)",
    caption = "Note: Red vertical dashed line indicates the Q4 2024 import ban announcement."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(fig_substitution_trend)