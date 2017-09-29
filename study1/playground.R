stop("INTERATIVE - DO NOT SOURCE")

source("study1/setup.R")

# save/retrieve from vault
saveProjectToVault()
restoreProjectFromVault()

# open project on RQDA
RQDA()

# search stories containing bathroom and shower
View(searchFiles("file like '%shower%'", content = T))
View(searchFiles("file like '%bath%'", content = T))

