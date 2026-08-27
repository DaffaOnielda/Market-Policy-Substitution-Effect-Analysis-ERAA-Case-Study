library(dplyr)
library(ggplot2)
library(tidyquant)
library(reticulate)

# get daily stock prices and compute returns
eraa_daily <- tq_get("ERAA.JK", from = "2023-01-01", to = "2026-06-30", get = "stock.prices")

eraa_ready <- eraa_daily |>
  arrange(date) |>
  mutate(log_return = log(adjusted / lag(adjusted))) |>
  filter(!is.na(log_return)) |>
  mutate(policy_dummy = if_else(date >= as.Date("2024-10-25"), 1, 0))

# fit garch(1,1) via python arch
py_run_string("
import pandas as pd
import numpy as np
from arch import arch_model

df_daily = r.eraa_ready
returns_scaled = df_daily['log_return'] * 100

garch_model = arch_model(returns_scaled, vol='Garch', p=1, q=1)
garch_fitted = garch_model.fit(disp='off')

df_daily['conditional_vol'] = garch_fitted.conditional_volatility
")

py_run_string("print(garch_fitted.summary())")

# extract conditional volatility back to R
eraa_final_daily <- py$df_daily |>
  mutate(
    date            = as.Date(unlist(date)),
    conditional_vol = as.numeric(unlist(conditional_vol)),
    year            = as.character(format(date, "%Y"))
  )

policy_line <- data.frame(
  year = "2024",
  policy_date = as.Date("2024-10-25")
)

# faceted yearly volatility (figure 4.1)
fig_4_1 <- ggplot(eraa_final_daily, aes(x = date, y = conditional_vol)) +
  geom_line(color = "darkblue", alpha = 0.8, linewidth = 0.6) +
  geom_hline(yintercept = c(2.0, 3.5), linetype = "twodash", color = "darkgreen", linewidth = 0.5) +
  geom_vline(data = policy_line, aes(xintercept = policy_date), linetype = "dashed", color = "red", linewidth = 0.8) +
  facet_wrap(~ year, scales = "free_x", ncol = 1) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Figure 4.1: ERAA Yearly Market Risk and Volatility Comparison",
    subtitle = "Tracking Market Panic Before, During, and After the Regulatory Shock",
    x = "Trading Timeline",
    y = "Volatility (%)",
    caption = "Note: Red dashed line marks the October 2024 policy announcement."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    strip.text = element_text(face = "bold", size = 11)
  )

print(fig_4_1)

# continuous aggregate volatility plot (figure 4.2)
fig_4_2 <- ggplot(eraa_final_daily, aes(x = date, y = conditional_vol)) +
  annotate("rect", 
           xmin = min(eraa_final_daily$date), xmax = max(eraa_final_daily$date), 
           ymin = 2.0, ymax = 3.5, 
           alpha = 0.2, fill = "darkgreen") +
  geom_line(color = "darkblue", alpha = 0.8, linewidth = 0.6) +
  geom_vline(xintercept = as.Date("2024-10-25"), linetype = "dashed", color = "red", linewidth = 0.8) +
  geom_hline(yintercept = c(2.0, 3.5), linetype = "twodash", color = "darkgreen", linewidth = 0.5) +
  annotate("text", x = as.Date("2023-05-01"), y = 3.65, label = "Baseline Ceiling (3.5%)", color = "darkgreen", size = 3.5) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Figure 4.2: ERAA Continuous Stock Volatility Time Series (2023 to 2026)",
    subtitle = "Macro Overview of the Complete Risk Timeline",
    x = "Timeline",
    y = "Volatility (%)",
    caption = "Note: Red line marks the October 2024 policy announcement. Shaded area denotes normal variance range."
  ) +
  theme(plot.title = element_text(face = "bold", size = 13))

print(fig_4_2)