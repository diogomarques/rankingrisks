# Creates a shareable "codings.rda" dataset of codings, combining 
# RQDA-retrieved and Google sheets-retrieved data.
#
# Not reproducible without access to raw data.
#

library(tidyverse)
library(here)

# Read
codings_rqda = read_csv(here("data-raw/retrieved_rqda_codings.csv"))
waves = read_csv(here("data-raw/retrieved_waves.csv"))
codebook_rqda = read_csv(here("data-raw/retrieved_rqda_codebook.csv"))
codings_gsheets = read_csv(here("data-raw/retrived_gsheets_codings.csv"))

# RQDA codings - modify to include only relative placement of quotes, and
# add wave information
codings = 
  codings_rqda %>% mutate(
    quote_start = char_start / char_fid,
    quote_end   = char_end   / char_fid
    ) %>%
  left_join(waves, by = "fid") %>%
  select(fid, wave, everything(), -char_start, -char_end, -char_fid) %>%
  arrange(fid)

# Google Sheets codings - check new codes, add WAVE
# check new codenames
codenames_rqda = codings %>% group_by(codename) %>% summarise(n_rqda = n())
codenames_gsheets= codings_gsheets %>% group_by(codename) %>% summarise(n_gsheets = n())
codenames_both =
  full_join(codenames_rqda, codenames_gsheets, by="codename") %>%
  arrange(codename)
codenames_both %>% filter(is.na(n_rqda))

# add WAVE, arrange
codings_gsheets =
  codings_gsheets %>% mutate(wave = "WAVE4") %>%
  arrange(fid, codename)

# merge
codings_both = 
  codings %>%
  bind_rows(codings_gsheets)

# save
save(codings_both, file = here("data/", "codings.rda"))
