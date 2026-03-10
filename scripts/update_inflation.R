# =========================
# EUROSTAT HICP INFLATION LIVE DATA
# =========================

# 1) Instalar paquetes si no los tienes
# install.packages(c("eurostat", "dplyr", "tidyr", "readr", "stringr"))

library(eurostat)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

# 2) Descargar inflación armonizada (HICP) - tasa anual de variación
# Dataset elegido:
# prc_hicp_manr = HICP monthly data (annual rate of change)

inflation_raw <- get_eurostat(
  id = "prc_hicp_manr",
  filters = list(
    freq = "M",                       # mensual
    coicop = "CP00",                  # all-items HICP
    geo = c("DE", "FR", "IT", "ES"),  # países
    # si quieres agregar eurozona, usa:
    # geo = c("DE", "FR", "IT", "ES", "EA20")
    unit = "RCH_A"                    # annual rate of change (%)
  ),
  time_format = "date",
  type = "code"
)

# 3) Revisar rápidamente
glimpse(inflation_raw)

# 4) Limpiar nombres de países

inflation_clean <- inflation_raw %>%
  mutate(
    country = case_when(
      geo == "DE" ~ "Germany",
      geo == "FR" ~ "France",
      geo == "IT" ~ "Italy",
      geo == "ES" ~ "Spain",
      geo == "EA20" ~ "Euro area",
      geo == "EA19" ~ "Euro area",
      TRUE ~ geo
    )
  ) %>%
  select(date = time, country, inflation = values)

# 5) Pasar a formato ancho para Datawrapper
inflation_dw <- inflation_clean %>%
  pivot_wider(
    names_from = country,
    values_from = inflation
  ) %>%
  arrange(date)

# 6) Convertir fecha a formato amigable para Datawrapper
# Queda como YYYY-MM, ideal para line chart mensual
inflation_dw <- inflation_dw %>%
  mutate(date = format(date, "%Y-%m"))

# 7) Guardar CSV final
write_csv(inflation_dw, "inflation_live_data.csv")

# 8) Ver resultado final
print(inflation_dw, n = 10)