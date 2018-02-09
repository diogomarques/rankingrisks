# Obtain all codings per case from the RQDA database, annotated
# with code categories, codes, subcodes, start and end indexes
# for quotes, and total.

library(tidyverse)
library(RQDA)
library(here)

RQDA_PROJECT_PATH = "data-raw/study1.rqda"

# retrieve  
RQDA::openProject(here("data-raw/study1.rqda"))
codings = RQDA::getCodingTable()
category = RQDA::RQDAQuery("select name, memo from codecat where status = 1")
code = RQDA::RQDAQuery("select name, memo from freecode where status = 1")
contents = RQDA::RQDAQuery("select id, file from source")
RQDA::closeProject()

# unfold coding convention into variables
codings =
  codings %>%
  mutate(
    category = str_extract(codename, "[a-z]*"),
    code.subcode = str_extract(codename, "(?<=\\-)[:graph:]*"),
    code = str_extract(codename, "(?<=\\-)[a-z]*"),
    subcode = str_extract(code.subcode, "(?<=\\-)[a-z]*")
  ) 

# annotate codings with story length, start / end indexes
contents =
  contents %>%
  transmute(fid = id, char_fid = nchar(file))
codings =
  codings %>%
  left_join(contents, by = "fid") %>%
  select(fid, codename, category, code, subcode, 
         char_start = index1, char_end = index2, char_fid)

# clean-up unusued code categories
category = 
  category %>%
  filter(! is.na(memo)) %>%
  filter(memo != "") %>%
  rename(description = memo) %>%
  mutate(type = "category")

# clean-up code table
code = 
  code %>%
  rename(description = memo) %>%
  mutate(type = "option")

# create codebook dataset with code and category descriptions
codebook = 
  bind_rows(category, code) %>%
  arrange(name)
View(codebook)

# save all to data-raw
write_csv(codings, here("data-raw/", "rqda_codings.csv"))
write_csv(codebook, here("data-raw/", "rqda_codebook.csv"))
