stop("INTERATIVE - DO NOT SOURCE")

source("study1/setup.R")

##
# Data retrieval / visual inspection
##
# main tables:
View(getCodingTable())
View(filesByCodes())

# SQL tables:
codecat = RQDAQuery("select * from codecat")
codecat = codecat %>% filter(status == 1)
View(codecat)

treecode = RQDAQuery("select * from treecode")
treecode = treecode %>% filter(status == 1)
View(treecode)

code = RQDAQuery("select * from freecode")
code = code %>% filter(status == 1)
View(code)

# example: inspect to which files codes with a certain pattern are attributed to:
View(getCodingTable() %>% filter(grepl("knowledge", codename)))


###
# Clean-up
###
closeProject()
saveProjectToVault(delete = F)
