# Creates a shareable dataset of codings, combining RQDA-retrieved and
# sheets-retrived data; and a shareable codebook.
#
# Not reproducible without access to raw data.
#
# TODO: add second-round codings to dataset
# TODO: add second-round new codes to codebook (via RQDA)
# TODO: correct gramatical errors in codebook

library(tidyverse)
library(here)

# Read
codings_rqda = read_csv(here("data-raw/retrieved_rqda_codings.csv"))
waves = read_csv(here("data-raw/retrieved_waves.csv"))
codebook_rqda = read_csv(here("data-raw/retrieved_rqda_codebook.csv"))

# Codings - modify to include only relative placement of quotes, and
# add wave information
codings = 
  codings_rqda %>% mutate(
    quote_start = char_start / char_fid,
    quote_end   = char_end   / char_fid
    ) %>%
  left_join(waves, by = "fid") %>%
  select(fid, wave, everything(), -char_start, -char_end, -char_fid) %>%
  arrange(fid)
codings

# Codebook
codebook =
  codebook_rqda %>% select(type, name, description)

# Save
save(codings, file = here("data/", "codings.rda"))
save(codebook, file = here("data/", "codebook.rda"))
