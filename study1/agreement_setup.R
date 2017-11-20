##
# Clean-up and prepare data for inspecting agreement between raters.
##

library(dplyr)
library(googlesheets)
library(secure)
library(stringr)
library(tidyr)

# Retrive 1st rater data & codebook from RQDA

openProject("study1/study1.rqda")

# rater1's codings from RQDA
r1.codings = getCodingTable() %>% 
  select(fid, codename)

# get codebook from RQDA
codebook = RQDAQuery("select * from freecode") %>%
  filter(status == 1) %>%
  select(codename = name, description = memo)

closeProject()

# retrieve additional rater codings from G Form results.
SHEETS_VAULT = "sheets"
# save sheet keys to vault
# key.s1_coding_responses = gs_ls(regex = "Story coding \\(v2) \\(Responses)")  %>% 
#    select(sheet_key) %>%
#    first()
# encrypt(.name = SHEETS_VAULT, s1_coding_responses = key.s1_coding_responses)
key = decrypt(SHEETS_VAULT)$s1_coding_responses
responses = gs_read(gs_key(key))


# obtain tidy rater tables from responses google sheet

# clean column names
responses.shortvar = responses
names(responses.shortvar) = c("timestamp", "rater", "fid", "relationshiptype", 
                           "opportunity", "lock", "motivation", "process", 
                           "knowledge", "aftermath", "status", "comments")

# helper to map descriptions to codenames
# category argument needed as some descriptions not unique
getCodes_ = function(category, descriptions, codebook) {
  # check NA's
  if(is.na(descriptions))
    return(NA)
  
  # split possible multiple descriptions into set
  description.vector = str_split(descriptions, "(?<=\\.), ") %>% unlist()
  description.vector
  
  # obtain codebook subset pertaining to this category
  codebook.flat.cat = codebook %>% 
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
#category = "relationshiptype"
#descriptions = "Subjects are friends, including people from work or school who are considered friends."
#descriptions = NA
#getCodes_(category, descriptions)

# vectorized version - receives a vector of descriptions strings; if a string has more than
# one description, codenames are returned comma-separated.
getCodes = function(category, descriptions.vector, codebook) {
  # TODO: try out purr here
  codes = sapply(descriptions.vector, getCodes_, 
                 category = category, codebook = codebook, USE.NAMES = F)
  sapply(codes, paste, collapse=", ")
}
# testing
# category = "relationshiptype"
# descriptions.vector = responses.clean$relationshiptype
# getCodes(category, descriptions.vector)

# s & r per code category
# the two helpers would have been unnecessary if data was separated before
# mapping, but no use in re-writing this now
responses.clean = responses.shortvar %>% mutate(
          relationshiptype = getCodes("relationshiptype", relationshiptype, codebook),
          opportunity = getCodes("opportunity", opportunity, codebook),
          lock = getCodes("lock", lock, codebook),
          motivation = getCodes("motivation", motivation, codebook),
          process = getCodes("process", process, codebook),
          knowledge = getCodes("knowledge", knowledge, codebook),
          aftermath = getCodes("aftermath", aftermath, codebook),
          status = getCodes("status", status, codebook)
          ) %>%
  # filter out dummy rater
  filter(rater != "cthulhu")

# gather to (fid,rater) -> codename map
rn.codings.untidy = responses.clean %>% 
  select(-comments, -timestamp) %>% 
  gather(category, codename, -fid, -rater)

# separate multiple codings (separate_rows does not work due to varying lenghts)
rn.codings = rn.codings.untidy %>% 
  # create a lists of codenames instead of sequences
  mutate(codename = str_split(codename, pattern = ", ")) %>%
  # unfold list
  unnest() %>%
  # remove "NA"'s
  filter(codename != "NA") %>%
  # dump categories col
  select(-category)

# merge all codings
codings =
  r1.codings %>%
  mutate(rater = "diogo") %>%
  select(rater, fid, codename) %>%
  bind_rows(rn.codings)

# clean-up
rm(r1.codings, responses.shortvar, rn.codings, rn.codings.untidy, 
   key, SHEETS_VAULT, getCodes, getCodes_)

