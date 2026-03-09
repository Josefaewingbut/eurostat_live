# Live data: General government gross debt (% of GDP) - Eurostat

suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
  library(tidyr)
  library(readr)
})

countries <- c("EA20","DE","FR","IT","ES")

data_raw <- get_eurostat("gov_10dd_edpt1", time_format = "date")

time_col <- if ("TIME_PERIOD" %in% names(data_raw)) "TIME_PERIOD" else "time"

dw_long <- data_raw %>%
  filter(
    geo %in% countries,
    unit == "PC_GDP",
    sector == "S13",
    na_item %in% c("GD")
  ) %>%
  transmute(
    date = .data[[time_col]],
    geo,
    value = as.numeric(values)
  )

if (nrow(dw_long) == 0) {
  stop("Filtro devolvió 0 filas.")
}

dw <- dw_long %>%
  mutate(date = format(as.Date(date), "%Y")) %>%
  pivot_wider(names_from = geo, values_from = value) %>%
  arrange(date) %>%
  rename(
    `Euro area (EA20)` = EA20,
    Germany = DE,
    France = FR,
    Italy = IT,
    Spain = ES
  )

write_csv(dw, "debt_gov_gdp_annual_EA20_DE_FR_IT_ES.csv", na = "")

message("CSV actualizado correctamente")