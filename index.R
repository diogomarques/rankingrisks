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

# TODO: move the following to codebooks

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
