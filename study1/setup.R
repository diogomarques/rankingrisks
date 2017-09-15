library(RQDA)
library(secure)
library(readr)

# Helpers to set up RQDA project. Since RQDA files, as well as CSV, contain raw
# data, they cannot be published to source control. Helpers here, and
# .gitignore, make that easier to manage, by encrypting all data.

# TODO: move from local key to maybe github key for encrypt/decrypt

RQDA_PROJECT_PATH = "study1/study1.rqda"

VAULT_NAME = "study1"

# Saves project to secure vault. Deletes it by default.
saveProjectToVault = function(delete = T) {
  # read database
  db = readr::read_file_raw(RQDA_PROJECT_PATH)
  #write to vault
  secure::encrypt(.name = "study1", db)
  if (delete & file.exists(RQDA_PROJECT_PATH))
    file.remove(RQDA_PROJECT_PATH)
}

# Restores project from secure vault. By default, does not overwrite if RQDA
# file already exists.
restoreProjectFromVault = function(overwrite = F) {
  if(!overwrite & file.exists(RQDA_PROJECT_PATH))
    stop("Project file already exists.")
  else {
    saveddb = secure::decrypt("study1")[[1]]  
    readr::write_file(x = saveddb, path = RQDA_PROJECT_PATH)
  }
}