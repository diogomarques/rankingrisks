stop("INTERACTIVE - DO NOT SOURCE")

library(dplyr)
library(googlesheets)
library(secure)
library(stringr)
library(tidyr)

##
# Retrieves second rater codings from G Form results and finds mismatches.
#

## Get codings data from prev script (going to be needed here)
# TODO: messy. find better way to do this.
source("study1/codefrequency.R")
rm(list = ls()[ls() != "codings.f.subcode" & ls() != "codings"])


## Get responses googlesheet from vault
SHEETS_VAULT = "sheets"
# save sheet keys to vault
# key.s1_coding_responses = gs_ls(regex = "Story coding \\(v2) \\(Responses)")  %>% 
#    select(sheet_key) %>%
#    first()
# encrypt(.name = SHEETS_VAULT, s1_coding_responses = key.s1_coding_responses)
key = decrypt(SHEETS_VAULT)$s1_coding_responses
responses = gs_read(gs_key(key))

# clean column names
responses.shortvar = responses
names(responses.shortvar) = c("timestamp", "rater", "fid", "relationshiptype", 
                           "opportunity", "lock", "motivation", "process", 
                           "knowledge", "aftermath", "status", "comments")


## Clean-up codename -> description map
codebook.flat = codings.f.subcode %>% 
                  mutate(codename = ifelse(subcode=="", 
                                           paste(category, code, sep = "-"), 
                                           paste(category, code, subcode, sep = "-")
                                           )
                         ) %>%
                  select(codename, description)

# Search & replace

# helper to determine codenames based on descriptions and category (description is
# insufficient given duplicate descriptions for e.g. "other"). 
getCodes_ = function(category, descriptions) {
  # check NA's
  if(is.na(descriptions))
    return(NA)
  
  # split possible multiple descriptions into set
  description.vector = str_split(descriptions, "(?<=\\.), ") %>% unlist()
  description.vector
  
  # obtain codebook subset pertaining to this category
  codebook.flat.cat = codebook.flat %>% 
                filter(grepl(category, codename)) 
  codebook.flat.cat
  
  # which descriptions are in this subset?
  codes = codebook.flat.cat %>% 
    filter (description %in% description.vector) %>%
    .$codename
  codes
  
  # check: number of codes equal number of descriptions
  if(length(description.vector) != length(codes))
    stop(paste("Number of codes does not match number of descriptions on ", descriptions)
         )

  # return codes
  sort(codes)
}
# testing
category = "relationshiptype"
descriptions = "Subjects are friends, including people from work or school who are considered friends."
#descriptions = NA
getCodes_(category, descriptions)


# vectorized version - receives a vector of descriptions strings; if a string has more than
# one description, codenames are returned comma-separated
getCodes = function(category, descriptions.vector) {
  # TODO: try out purr here
  codes = sapply(descriptions.vector, getCodes_, category = category, USE.NAMES = F)
  sapply(codes, paste, collapse=", ")
}
# testing
# category = "relationshiptype"
# descriptions.vector = responses.clean$relationshiptype
# getCodes(category, descriptions.vector)

# s & r per code category
responses.clean = responses.shortvar %>% mutate(
          relationshiptype = getCodes("relationshiptype", relationshiptype),
          opportunity = getCodes("opportunity", opportunity),
          lock = getCodes("lock", lock),
          motivation = getCodes("motivation", motivation),
          process = getCodes("process", process),
          knowledge = getCodes("knowledge", knowledge),
          aftermath = getCodes("aftermath", aftermath),
          status = getCodes("status", status)
          )

# diagnose problem in e.g. motivation
#codebook.flat %>% filter(grepl("motivation", codename)) %>% distinct(description) %>% .$description

## Compare codings manually

# prep tables per coder
# ivan codes
ivan = responses.clean %>% filter(rater == "ivan") %>% select(-timestamp)

# my codes, in same format
diogo = codings %>% 
  select(fid, codename, category) %>% 
  group_by(fid, category) %>% 
  summarise(codes = toString(sort(unique(codename)))) %>% # TODO: untangle
  spread(category, codes) %>%
  mutate(rater = "diogo")

both = bind_rows(ivan, diogo) %>%
  filter(fid <= 10) %>%
  arrange(fid, rater)

write_csv(both, "out/s1_combined_raters_round1_1-10.csv")

# Calculate agreement

diogo.matrix = filesByCodes() %>% 
  select(-filename) %>%
  arrange(fid) 

# ivan matrix:
# gather to fid-> codename map
ivan.codings.untidy = ivan %>% 
  select(-comments, -rater) %>% 
  gather(category, codename, -fid)

# separate multiple codings (separate_rows does not work due to varying lenghts)
ivan.codings = ivan.codings.untidy %>% 
  # create a lists of codenames instead of sequences
  mutate(codename = str_split(codename, pattern = ", ")) %>%
  # unfold list
  unnest() %>%
  # remove "NA"'s
  filter(codename != "NA") %>%
  # dump categories col
  select(-category) %>%
  # add status
  mutate(status = 1)

# create empty codings table w/ all codes in book
fids = list(1:10)
empty.codings.10 = codebook.flat %>% select(codename) %>% mutate(fid = fids) %>% unnest()

# join with ivan codings, w/ status 0 or 1
ivan.codings.full = empty.codings.10 %>% 
  left_join(ivan.codings, by = c("codename", "fid")) 

# spread intro matrix
ivan.matrix = ivan.codings.full %>% 
  spread(codename, status, fill = 0)

# make sure that col names & order match, for comparison.
names(diogo.matrix) = names(diogo.matrix) %>% 
  str_replace(pattern = "codedBy\\.", replacement = "")
ivan.matrix = ivan.matrix %>% 
  select(one_of(names(diogo.matrix)))

# example matrix operation
{diogo.matrix %>% filter(fid <= 10)} == ivan.matrix

# something wrong here
