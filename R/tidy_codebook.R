# Creates a shareable "codebook.rda" dataset of categories & 
# option to raters.
#
# Not reproducible without access to raw data.
#
source("R/retrieve_helpers_gsheet.R")
library(tidyverse)
library(here)

# read
codebook = retrieve_sheet_data("s1_master_codebook")

# write
save(codebook, file = here("data/", "codebook.rda"))