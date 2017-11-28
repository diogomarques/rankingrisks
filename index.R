##
## Index
##
## TODO: get out of this global variable -> script -> 
# clean-up -> outfile workflow, and move to something 
# like a notebook.

# All libraries
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

OUT_S1_WORDCOUNT =            "out/s1_story_length_stats.csv"
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

# Run scripts from here
stop("Do not source all files at once. Choose carefully you must.")

# Obtain story lenght statistics. Results go to files in \out.
# Data sources are Google sheets only. It is a good idea to run 
# gs_ls() before sourcing, to make sure that authorization to 
# access Google Sheets is already taken care of.
gs_ls()
source("study1/storylength.R")

# Compute participant statistics. Resuls go to \out".
# Data source is again Google sheets, so same warnings apply.
# gs_ls()
source("study1/participants.R")

# Populate RQDA database. No need to run this ever again.
#source("study1/populate.R")

# Load functions to save/restore encrypted RQDA database
source("study1/db_encrypt.R")

# Analyze codebook growth. Outputs tables and graphs to out/.
source("study1/newcodes.R")

# Compute code frequencies to tables in out/.
source("study1/codefrequency.R")

# Merge RQDA codings, and 2nd rater codings from Google Sheet
# into useful tables, needed for subsequent analysis.
source("study1/codings.R")

# Obtain a table with codings from all raters, for manual
# inspection. Table saved to /out.
# Pre-req: source codings.R
source("study1/codings_inspection.R")

# Calculate agreement scores, and out them to a single
# file in out/.
# Pre-req: source codings.R
source("study1/agreement_round1.R")
