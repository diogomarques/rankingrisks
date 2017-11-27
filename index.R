##
## Index
##

# All libraries
library(RQDA)
library(secure)
library(tidyverse)
library(googlesheets)
library(glue)

# All global variables
RQDA_PROJECT_PATH = "study1/study1.rqda"
RQDA_VAULT_NAME = "study1"
SHEETS_VAULT = "sheets"
OUT_S1_WORDCOUNT = "out/s1_story_length_stats.csv"
OUT_S1_PARTICIPANTS_PATTERN = "out/s1_participants_{stat}.csv"

# Create out dir if it does not exist yet
dir.create("out", showWarnings = F)

# Now do work
stop("Do not source all files at once. Choose carefully you must.")

# Load functions to save/restore encrypted RQDA database
source("study1/db_encrypt.R")

# Populate RQDA database. No need to run this ever again.
#source("study1/populate.R")

# Obtain story lenght statistics. Results go to files in \out.
# Data sources are Google sheets, so no need to load RQDA database. 
# It is a good idea to run gs_ls() before sourcing, to make sure 
# that authorization to acess Google Sheets is already taken care of.
gs_ls()
source("study1/storylength.R")

# Compute participant statistics. Resuls go to \out".
# Data source is again Google sheets, so same warnings apply.
# gs_ls()
source("study1/participants.R")

