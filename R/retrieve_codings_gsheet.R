# Retrieve codings that live only on Google Sheets, not the RQDDA database.
# 
# Not reproducible without access to raw data.

# TODO: handle multiple raters

source("R/retrieve_helpers_gsheet.R")
library(tidyverse)
library(here)

# get data
gsheet_codings = retrieve_sheet_data("s1_coding_responses_w4")

# regex to detect text between square brackets
between_brackets = "(?<=\\[)[:graph:]*(?=\\])"

# remove unnecessary vars
codings = 
  gsheet_codings %>% 
  select(-`Coder comments`, -Timestamp, `[rater]` = `Who am I?`)

# rename vars
names(codings) = 
  codings %>% names() %>% str_extract(between_brackets)

# gather codings and remove descriptions
codings =
  codings %>%
  gather(relationshiptype:status, key = "category", value = "selection") %>%
  mutate(selection = str_extract(selection, between_brackets))

# match RQDA categories for "awareness" and "security"
codings = 
  codings %>% mutate(category = 
                       fct_recode(category, "lock" = "security",
                                            "knowledge" = "awareness"))
  
# match RQDA codings format & unfolding of convention
codings =
  codings %>%
  mutate(
    codename = str_c(category, selection, sep = "-"),
    code = str_extract(codename, "(?<=\\-)[a-z]*"),
    subcode = str_extract(selection, "(?<=\\-)[a-z]*")
    ) %>%
  select(fid, codename, category, code, subcode, rater) %>%
  filter(!is.na(codename))

# save
write_csv(codings, here("data-raw/retrived_gsheets_codings.csv"))
