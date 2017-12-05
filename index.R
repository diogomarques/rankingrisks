##
## Index
##
## TODO: get out of this global variable -> script -> 
# clean-up -> outfile workflow, and move to something 
# like a notebook.

source("study1/setup.R")

# Run scripts from here
stop("Do not source all files at once. Choose carefully you must.")

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
