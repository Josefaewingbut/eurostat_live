# scripts/update_debt.R
# Live data: General government gross debt (% of GDP) - Eurostat

suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# Países/áreas a mostrar (ajusta si quieres)
countries <- c("EA20","DE","FR","IT","ES")

# Dataset Eurostat (deuda pública según Maastricht / EDP)
# Usualmente: gov_10dd_edpt1 (annual) o similares.
# Este script es robusto: si el dataset cambia columnas, intenta adaptarse.
data_raw <- get_eurostat("gov_10dd_edpt1", time_format = "date")

# Algunos Eurostat vienen con 'time' y otros con 'TIME_PERIOD'
time_col <- if ("TIME_PERIOD" %in% names(data_raw)) "TIME_PERIOD" else "time"

# Filtrado típico: sector S13 (general government) y unit PC_GDP (% of GDP)
# na_item suele ser "GD" o "DD" dependiendo del dataset (deuda). Por eso lo detectamos.
# 1) Mira rápidamente qué hay disponible:
# print(data_raw %>% count(unit, sort = TRUE))
# print(data_raw %>% count(sector, sort = TRUE))
# print(data_raw %>% count(na_item, sort = TRUE))

# Intento 1: na_item == "GD" (gross debt) es común
dw_try1 <- data_raw %>%
  filter(
    geo %in% countries,
    unit == "PC_GDP",
    sector == "S13",
    na_item %in% c("GD")  # cubre variantes comunes
  ) %>%
  transmute(
    date = .data[[time_col]],
    geo,
    value = as.numeric(values)
  )

# scripts/update_debt.R
# Live data: General government gross debt (% of GDP) - Eurostat

suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# Países/áreas a mostrar (ajusta si quieres)
countries <- c("EA20","DE","FR","IT","ES")

# Dataset Eurostat (deuda pública según Maastricht / EDP)
# Usualmente: gov_10dd_edpt1 (annual) o similares.
# Este script es robusto: si el dataset cambia columnas, intenta adaptarse.
data_raw <- get_eurostat("gov_10dd_edpt1", time_format = "date")

# Algunos Eurostat vienen con 'time' y otros con 'TIME_PERIOD'
time_col <- if ("TIME_PERIOD" %in% names(data_raw)) "TIME_PERIOD" else "time"

# Filtrado típico: sector S13 (general government) y unit PC_GDP (% of GDP)
# na_item suele ser "GD" o "DD" dependiendo del dataset (deuda). Por eso lo detectamos.
# 1) Mira rápidamente qué hay disponible:
# print(data_raw %>% count(unit, sort = TRUE))
# print(data_raw %>% count(sector, sort = TRUE))
# print(data_raw %>% count(na_item, sort = TRUE))

# Intento 1: na_item == "GD" (gross debt) es común
dw_long <- data_raw %>%
  filter(
    geo %in% countries,
    unit == "PC_GDP",
    sector == "S13",
    na_item %in% c("GD")  # cubre variantes comunes
  ) %>%
  transmute(
    date = .data[[time_col]],
    geo,
    value = as.numeric(values)
  )

if (nrow(dw_long) == 0) {
  stop("Filtro devolvió 0 filas. Revisa códigos: sector=S13, unit=PC_GDP, na_item=GD, geo.")
}

# Anual: dejamos solo el año (YYYY)
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

out <- "debt_gov_gdp_annual_EA20_DE_FR_IT_ES.csv"
write_csv(dw, out, na = "")

message("OK: CSV actualizado -> ", out)
