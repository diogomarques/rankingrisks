##
## Index of R scripts. Remaining analysis in separate R Notebooks.
##
stop("Do not source this file.")

## Setup libraries and global variables for notebooks.
source("study1/setup.R")

# Populate RQDA database. No need to run this ever again.
source("study1/populate.R")

# Load functions to save/restore encrypted RQDA database
source("study1/db_encrypt.R")

# Next scripts used to reach round 1 consensus. No use in 
# converting them to notebooks. Re-create output structure
# to run them again.
OUT_CSV_ROUND1_CONSENSUS =    "out/s1_codings_round1.csv"
OUT_CSV_AGREEMENT_R1 =        "out/s1_agreement_initial.csv"
dir.create("out", showWarnings = F)

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
