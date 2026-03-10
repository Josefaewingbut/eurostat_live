suppressPackageStartupMessages({
  library(eurostat)
  library(dplyr)
})

data_raw <- get_eurostat("namq_10_gdp", time_format = "date")

message("Columnas:")
print(names(data_raw))

message("Units disponibles:")
print(sort(unique(data_raw$unit)))

message("na_item disponibles:")
print(sort(unique(data_raw$na_item)))

message("geo disponibles:")
print(sort(unique(data_raw$geo)))
