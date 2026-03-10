# Live data: Real GDP growth (quarter-on-quarter) - Eurostat

suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
  library(tidyr)
  library(readr)
})

#Estos países concentran gran parte del PIB del área del euro.

countries <- c("EA20", "DE", "FR", "IT", "ES")

data_raw <- get_eurostat("namq_10_gdp", time_format = "date")

time_col <- if ("TIME_PERIOD" %in% names(data_raw)) "TIME_PERIOD" else "time"

dw_long <- data_raw %>%
  filter(
    geo %in% countries,
    na_item == "B1GQ",
    unit == "MIO_EUR"
  ) %>%
  transmute(
    date = .data[[time_col]],
    geo,
    value = as.numeric(values)
  )

if (nrow(dw_long) == 0) {
  stop("Filtro devolvió 0 filas.")
}


#Que valores existen realmente en la base de datos

names(data_raw)
unique(data_raw$unit)
unique(data_raw$geo)
unique(data_raw$na_item)


dw <- dw_long %>%
  mutate(date = paste0(format(as.Date(date), "%Y"), "-Q", quarters(as.Date(date)))) %>%
  pivot_wider(names_from = geo, values_from = value) %>%
  arrange(date) %>%
  rename(
    `Euro area (EA20)` = EA20,
    Germany = DE,
    France = FR,
    Italy = IT,
    Spain = ES
  )

write_csv(dw, "gdp_growth_qoq_real_EA20_DE_FR_IT_ES.csv", na = "")

message("CSV actualizado correctamente")