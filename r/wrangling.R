library(tidyverse)
library(readxl)
library(janitor)
library(countrycode)

input_dir <- file.path(
  Sys.getenv("CERF_GM_DIR"),
  "cholera_exploration",
  "inputs"
)

output_dir <- file.path(
  Sys.getenv("CERF_GM_DIR"),
  "cholera_exploration",
  "outputs"
)

###################
#### LOAD DATA ####
###################

read_excel(
  file.path(
    input_dir,
    "cerf_cholera_allocations.xlsx"
  )
) %>%
  clean_names() %>%
  transmute(
    iso3 = countryname(country, destination = "iso3c"),
    country = countrycode(iso3, "iso3c", "country.name"),
    emergency_type = ifelse(
      emergency_type == "Cholera",
      "Cholera",
      "Other"
    ),
    date = as.Date(date_of_most_recent_submission),
    amount = amount_approved
  ) %>%
  write_csv(
    file.path(
      output_dir,
      "cerf_cholera_allocations.csv"
    )
  )

read_excel(
  file.path(
    input_dir,
    "kenny_cholera_data.xlsx"
  )
) %>%
  slice(-1) %>%
  pivot_longer(
    -WeekDate,
    names_to = "date",
    values_to = "cholera_cases"
  ) %>%
  transmute(
    iso3 = countryname(WeekDate, destination = "iso3c"),
    country = countrycode(iso3, "iso3c", "country.name"),
    date = as.Date(as.numeric(date), origin = "1899-12-30"),
    cholera_cases = replace_na(as.numeric(cholera_cases), 0)
  ) %>%
  filter(
    !is.na(iso3)
  ) %>%
  write_csv(
    file.path(
      output_dir,
      "cholera_cases.csv"
    )
  )
