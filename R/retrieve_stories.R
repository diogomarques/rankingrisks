# Not reproducible without access to raw data.
#
# Retrieve participant-provided stories data from Google Sheets, using
# keys stored in the encrypted vault. There are three separate sheets, 
# two with with raw stories, and one with stories 1-35 edited. All are
# outed to a single file.

library(tidyverse)
library(here)
source("R/retrieve_helpers_gsheet.R")

get_sheet_keys()

# retrieve
stories_raw_1 = retrieve_sheet_data("s1_raw_stories")
stories_raw_2 = retrieve_sheet_data("s1_raw_stories_w4")
stories_edited = retrieve_sheet_data("s1_edited_stories")

# a little clean up
stories_raw_1 = stories_raw_1 %>% select(fid = id, raw_story = story)
stories_raw_2 = stories_raw_2 %>% select(fid, raw_story = story)
stories_edited = stories_edited %>% select(fid = id, edited_story = story)

# merge into single table
stories_raw = 
  bind_rows(stories_raw_1, stories_raw_2)

# add char count
stories =
  stories_raw %>%
  left_join(stories_edited, by="fid")

# out to CSV
write_csv(stories, here("data-raw/stories.csv"))
