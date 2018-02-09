# Not reproducible without access to raw data.
#
# Retrieve participant data from a Google Sheet, whose key
# is stored in the encrypted vault. Also save the wave identifier 
# for each observational unit separately.

library(tidyverse)
library(here)
library(rgeolocate)
source("R/retrieve_helpers_gsheet.R")

get_sheet_keys()

# retrieve all non-excluded data
participants = 
  retrieve_sheet_data(sheet_name = "s1_participants")

# add country
country = maxmind(ips = participants$ipaddr, 
                    field = "country_name",
                    file = system.file("extdata","GeoLite2-Country.mmdb", package = "rgeolocate"))
participants=
  participants %>%
  add_column(country = country$country_name)

# extract fid->waves map
waves = 
  participants %>%
  transmute(fid = row_number(), 
            wave = wave)

write_csv(participants, here("data-raw/", "retrieved_participants.csv"))
write_csv(waves, here("data-raw/", "retrieved_waves.csv"))
