# Populates RQDA database with collected data, stored in CSV file.
stop("INTERATIVE - DO NOT SOURCE")

library(readr)
library(dplyr)
source("study1/setup.R")

# get source data and make into list of id->story
SOURCE_DATA_PATH = "raw/Study 1- edited stories - edited.csv"

data = 
  readr::read_csv(SOURCE_DATA_PATH) %>% select(id, story)
list = as.list(data %>% .$story)
names(list) = data %>% .$id

# save to RQDA
RQDA::openProject(RQDA_PROJECT_PATH)
RQDA::write.FileList(list)
RQDA::closeProject()

saveProjectToVault()

RQDA()
