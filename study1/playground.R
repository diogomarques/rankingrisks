stop("INTERATIVE - DO NOT SOURCE")

source("study1/setup.R")

# load libs
library(RQDA)
library(dplyr)
library(tidyr)
library(stringr)

# save/retrieve from vault
restoreProjectFromVault()

openProject(RQDA_PROJECT_PATH)

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
# Big tidy data with subcodes, codes, categories, based on code
# conventions.
###

# get codings
codings = getCodingTable()
# create splitted matrix
codings.matrix = str_split_fixed(codings$codename, "-", 3) %>% as_data_frame()
colnames(codings.matrix) = c("category", "code", "subcode")
# bind them
codings = codings %>% bind_cols(codings.matrix)
# filter out irrelevant data
codings = codings %>% select(category, code, subcode, fid)

# code frequency at subcode level
coding.f.subcode = codings %>% group_by(category, code, subcode) %>% summarise(n = n())
View(.Last.value)

# ... w/ descriptions


# code frequency at code level
codings.f.code = codings %>% group_by(category, code) %>% summarise(n = n())
View(.Last.value)

# code frequency at category level
codings.f.category = codings %>% group_by(category) %>% summarise(n = n())
View(.Last.value)

# ... w/ description



###
# Clean-up
###
closeProject()
saveProjectToVault()