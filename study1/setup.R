library(RQDA)
library(secure)
library(readr)
library(dplyr)
library(stringr)

# Helpers to set up RQDA project. Since RQDA files, as well as CSV, contain raw
# data, they cannot be published to source control. Helpers here, and
# .gitignore, make that easier to manage, by encrypting all data.

# TODO: move from local key to maybe github key for encrypt/decrypt

RQDA_PROJECT_PATH = "study1/study1.rqda"

RQDA_VAULT_NAME = "study1"

RAW_DATA_DIR = "raw"

# Saves RQDA project to secure vault.
saveProjectToVault = function() {
  # read database
  db = readr::read_file_raw(RQDA_PROJECT_PATH)
  # delete old vault if exists
  vault_path = paste0("vault/", RQDA_VAULT_NAME, ".rds.enc")
  if(file.exists(vault_path))
    file.remove(vault_path)
  # write to vault
  secure::encrypt(.name = RQDA_VAULT_NAME, db)
}

# Restores RQDA project from secure vault. By default, does not overwrite if RQDA
# file already exists.
restoreProjectFromVault = function(overwrite = F) {
  if(!overwrite & file.exists(RQDA_PROJECT_PATH))
    stop("Project file already exists.")
  else {
    saveddb = secure::decrypt("study1")[[1]]  
    readr::write_file(x = saveddb, path = RQDA_PROJECT_PATH)
  }
}

# fake function just to isolate this play code 
playground = function() {

# TODO: Save all raw data files to vault
saveRawDataToVault = function() {
  # check that there is a raw folder with files to save
  if(dir.exists(RAW_DATA_DIR)) {
  } else {
    warning("No \raw folder")
  }
  
  
}
if(dir.exists(RAW_DATA_DIR)) {
  files = list.files(RAW_DATA_DIR)
  # TODO: check if there are any files
  filespath = paste0("raw/", files)
  contents = sapply(filespath, read_file)
  valuables = data_frame(vfile = files, vcontent = contents)
  apply(valuables, 1, function(x) encrypt(.name = x[1], x[2]))
}

}
