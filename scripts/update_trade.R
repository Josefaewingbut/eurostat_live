
#SCRIPT CORRECTO

library(eurostat)
library(dplyr)
library(tidyr)
library(readr)

# 1) Descargar dataset
trade <- get_eurostat("ext_lt_intertrd", time_format = "date")

# 2) Limpiar y filtrar correctamente
trade_clean <- trade %>%
  filter(
    freq == "A",
    partner == "WORLD",
    sitc06 == "TOTAL",
    indic_et %in% c("MIO_EXP_VAL", "MIO_IMP_VAL")
  ) %>%
  select(
    geo,
    indic_et,
    TIME_PERIOD,
    values
  ) %>%
  rename(
    country = geo,
    trade_flow = indic_et,
    time = TIME_PERIOD,
    value = values
  )

# 3) Verificar que no existan duplicados
duplicates_check <- trade_clean %>%
  summarise(n = dplyr::n(), .by = c(country, time, trade_flow)) %>%
  filter(n > 1)

print(duplicates_check)

# 4) Pasar export e import a columnas
trade_wide <- trade_clean %>%
  pivot_wider(
    names_from = trade_flow,
    values_from = value
  )

# 5) Renombrar columnas de forma clara
trade_final <- trade_wide %>%
  rename(
    exports = MIO_EXP_VAL,
    imports = MIO_IMP_VAL
  ) %>%
  arrange(country, time)

# 6) Guardar CSV limpio
write_csv(trade_final, "trade_live_data.csv")
