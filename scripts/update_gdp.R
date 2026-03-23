options(timeout = 600)

suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
})

data_raw <- tryCatch(
  get_eurostat("namq_10_gdp", time_format = "date") %>%
    filter(
      geo %in% c("DE", "FR", "ES", "IT"),
      na_item == "B1GQ",
      s_adj == "SA"
    ),
  error = function(e) {
    message("Error al descargar GDP desde Eurostat: ", e$message)
    stop(e)
  }
)

message("Descarga completada.")
message("Columnas disponibles:")
print(names(data_raw))
