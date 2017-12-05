##
## Some generally-needed setup for notebooks
##

# Generally-needed libraries
library(RQDA)
library(secure)
library(tidyverse)
library(googlesheets)
library(glue)
library(irr)

# All global variables
RQDA_PROJECT_PATH = "study1/study1.rqda"
RQDA_VAULT_NAME = "study1"
SHEETS_VAULT = "sheets"

# OUT_S1_WORDCOUNT =            "out/s1_story_length_stats.csv"
OUT_S1_PARTICIPANTS_PATTERN = "out/s1_participants_{stat}.csv"
OUT_CODE_PLOT =               "out/s1_cummulative_codes"
OUT_SUBCODE_PLOT =            "out/s1_cummulative_subcodes"
OUT_CSV_NEW_CODES =           "out/s1_new_codes_per_wave.csv"
OUT_CSV_NEW_SUBCODES =        "out/s1_new_subcodes_per_wave.csv"
OUT_CSV_CATEGORY_FREQUENCY =  "out/s1_frequency_categories.csv"
OUT_CSV_CODE_FREQUENCY =      "out/s1_frequency_codes.csv"
OUT_CSV_SUBCODE_FREQUENCY =   "out/s1_frequency_subcodes.csv"
OUT_CSV_ROUND1_CONSENSUS =    "out/s1_codings_round1.csv"
OUT_CSV_AGREEMENT_R1 =        "out/s1_agreement_initial.csv"

# Create out dir if it does not exist yet
dir.create("out", showWarnings = F)