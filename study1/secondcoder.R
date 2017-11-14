stop("INTERACTIVE - DO NOT SOURCE")

library(dplyr)
library(googlesheets)
library(secure)
library(stringr)

##
# Retrieves second rater codings from G Form results and finds mismatches.
#

## Get codings data from prev script that's going to be needed here
source("study1/codefrequency.R")
rm(list = ls()[ls() != "codings.f.subcode"])

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
responses.clean = responses
names(responses.clean) = c("timestamp", "rater", "fid", "relationshiptype", 
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
  codes
}
# testing
#category = "relationshiptype"
#descriptions = "Subjects are friends, including people from work or school who are considered friends."
#descriptions = NA
#getCodes_(category, descriptions)


# vectorized version - receives a vector of descriptions strings; if a string has more than
# one description, codenames are returned comma-separated
getCodes = function(category, descriptions.vector) {
  codes = sapply(descriptions.vector, getCodes_, category = category, USE.NAMES = F)
  sapply(codes, paste, collapse=",")
}
# testing
#category = "relationshiptype"
#descriptions.vector = responses.clean$relationshiptype
#getCodes(category, descriptions.vector)

# s & r per code category
responses.clean %>% mutate(
  relationshiptype.codes = getCodes("relationshiptype", relationshiptype),
  opportunity.codes = getCodes("opportunity", opportunity),
  lock.codes = getCodes("lock", lock),
  motivation.codes = getCodes("motivation", motivation),
  process.codes = getCodes("process", process),
  knowledge.codes = getCodes("knowledge", knowledge),
  aftermath.codes = getCodes("aftermath", aftermath),
  status.codes = getCodes("status", status)
  )

# diagnose problem in e.g. motivation
#codebook.flat %>% filter(grepl("motivation", codename)) %>% distinct(description) %>% .$description

# objective: obtain codings table (codename | fid)