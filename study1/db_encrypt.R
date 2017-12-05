# Helpers to set up RQDA project. Since RQDA files contain raw
# data, they cannot be published unencrypted to source control. 
# These helpers, and .gitignore, make it easier to only commit 
# encrypted data.

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