##
## Some generally-needed setup for notebooks
##

# Generally-needed libraries
library(secure)
library(tidyverse)
library(glue)

# All global variables
RQDA_PROJECT_PATH = "study1/study1.rqda"
RQDA_VAULT_NAME = "study1"
SHEETS_VAULT = "sheets"

OUT_CSV_CATEGORY_FREQUENCY =  "out/s1_frequency_categories.csv"
OUT_CSV_CODE_FREQUENCY =      "out/s1_frequency_codes.csv"
OUT_CSV_SUBCODE_FREQUENCY =   "out/s1_frequency_subcodes.csv"
OUT_CSV_ROUND1_CONSENSUS =    "out/s1_codings_round1.csv"
OUT_CSV_AGREEMENT_R1 =        "out/s1_agreement_initial.csv"

# Create out dir if it does not exist yet
dir.create("out", showWarnings = F)