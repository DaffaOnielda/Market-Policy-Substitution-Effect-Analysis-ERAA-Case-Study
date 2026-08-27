library(ggplot2)

# simulate homoskedastic baseline against volatility cluster
set.seed(123)
time_seq <- 1:200
flat_risk <- rnorm(200, mean = 0, sd = 1)

cluster_multiplier <- c(rep(1, 70), rep(4, 40), rep(1, 90))
clustered_risk <- rnorm(200, mean = 0, sd = 1) * cluster_multiplier

stats_data <- data.frame(
  Time = rep(time_seq, 2),
  Returns = c(flat_risk, clustered_risk),
  Model = rep(c("Homoskedasticity", 
                "Volatility Clustering in Financial Market"), each = 200)
)

# theoretical variance plot
fig_theoretical_sim <- ggplot(stats_data, aes(x = Time, y = Returns)) +
  geom_line(color = "lightblue", linewidth = 0.5) +
  facet_wrap(~ Model, ncol = 2) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "GARCH importance for Financial Time Series",
    subtitle = "Comparison of flat structural risk and behavioral market panic memory",
    x = "Theoretical Trading Timeline",
    y = "Asset Returns"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    strip.text = element_text(face = "bold")
  )
print(fig_theoretical_sim)