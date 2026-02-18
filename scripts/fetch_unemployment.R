library(eurostat)
library(dplyr)
library(tidyr)
library(readr)

data <- get_eurostat("une_rt_m", time_format = "date")

geo_keep <- c("DE", "EA19", "EA20")

df <- data %>%
  filter(geo %in% geo_keep) %>%
  filter(sex == "T", age == "TOTAL", unit == "PC_ACT") %>%
  mutate(s_adj_pref = ifelse(s_adj == "SA", 1, 0)) %>%
  group_by(geo, TIME_PERIOD) %>%
  slice_max(order_by = s_adj_pref, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  transmute(
    date = format(as.Date(TIME_PERIOD), "%Y-%m-%d"),
    geo  = geo,
    value = as.numeric(values)
  ) %>%
  filter(!is.na(value)) %>%
  arrange(date, geo)

out <- df %>%
  pivot_wider(names_from = geo, values_from = value) %>%
  arrange(date) %>%
  select(date, DE, EA = EA20)

write_csv(out, "unemployment_de_ea.csv", na = "")
