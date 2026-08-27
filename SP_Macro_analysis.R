library(ggplot2)
library(dplyr)
library(reticulate)
library(patchwork)

# fetch SOXX index via yfinance (more confinient :D)
#run Python
py_run_string("
import yfinance as yf
ticker = yf.Ticker('SOXX')
df_py = ticker.history(start='2023-01-01', end='2026-07-31')
df_py = df_py.reset_index()
")
#conect Python
df_semi <- py$df_py |>
  mutate(
    date = as.Date(as.POSIXct(unlist(Date), origin='1970-01-01', tz='UTC')),
    close = as.numeric(unlist(Close))
  )

# read NY Fed supply chain index (GSCPI)
df_gscpi <- read.csv2("GSCPI.csv", skip = 5, header = FALSE) |>
  select(V1, V2) |>
  rename(raw_date = V1, raw_gscpi = V2) |>
  mutate(
    date = as.Date(raw_date, format = "%d-%b-%Y"),
    price = as.numeric(gsub(",", ".", raw_gscpi))
  ) |>
  filter(date >= as.Date("2023-01-01") & date <= as.Date("2026-07-31"))

# semiconductor ETF price (5.1B)
plot_b <- df_semi |>
  filter(!is.na(close)) |>
  ggplot(aes(x = date, y = close)) +
  annotate("rect", xmin = as.Date("2023-10-01"), xmax = as.Date("2024-07-01"), 
           ymin = -Inf, ymax = Inf, alpha = 0.1, fill = "darkred") +
  annotate("text", x = as.Date("2024-02-15"), y = 550, label = "2024 Initial\nShortage", 
           size = 3, fontface = "italic", color = "darkred") +
  annotate("rect", xmin = as.Date("2025-10-01"), xmax = as.Date("2026-06-30"), 
           ymin = -Inf, ymax = Inf, alpha = 0.15, fill = "darkred") +
  annotate("text", x = as.Date("2026-02-15"), y = 650, label = "2026 Massive\nPrice Peak", 
           size = 3, fontface = "bold", color = "darkred") +
  geom_line(color = "darkblue", linewidth = 1) +
  labs(
    title = "5.1B",
    x = "Timeline",
    y = "Index Price (USD)"
  ) +
  scale_y_continuous(limits = c(0, 700)) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank()
  )

# global supply chain pressure (5.1C)
plot_c <- df_gscpi |>
  filter(!is.na(price)) |>
  ggplot(aes(x = date, y = price)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "darkgreen", linewidth = 0.8) +
  geom_line(color = "darkred", linewidth = 1) +
  labs(
    title = "5.1C",
    x = "Timeline",
    y = "Standard Deviation from Mean"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank()
  )

# combine macro control plots
fig_macro_controls <- plot_b + plot_c
print(fig_macro_controls)