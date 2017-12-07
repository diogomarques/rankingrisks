##
## Some generally-needed setup for notebooks
##

# Generally-needed libraries
library(secure)
library(tidyverse)
library(glue)

# All global variables
RQDA_PROJECT_PATH = "study1/study1.rqda"
RQDA_VAULT_NAME = "study1"
SHEETS_VAULT = "sheets"

# Obtain all codings per case from the RQDA database, annotated
# category, code, subcode, ans respective descriptions
getCodes = function(database = RQDA_PROJECT_PATH) {
  # retrieve data from DB
  require(RQDA)
  RQDA::openProject(database)
  codings = RQDA::getCodingTable()
  category = RQDA::RQDAQuery("select name, memo from codecat where status = 1")
  code = RQDA::RQDAQuery("select name, memo from freecode where status = 1")
  RQDA::closeProject()
  detach("package:RQDA")
  
  # clean-up dara
  codings = 
    codings %>%
    # extract category and code applying code name convention
    mutate(category = str_extract(codename, "[a-z]*"),
           code.subcode = str_extract(codename, "(?<=\\-)[:graph:]*"),
           code = str_extract(codename, "(?<=\\-)[a-z]*"),
           subcode = str_extract(code.subcode, "(?<=\\-)[a-z]*")
    ) %>%
    select(fid, codename, category, code, subcode)  
  
  # join to code descriptions
  codings = 
    codings %>% 
    left_join(code, by=c("codename" = "name")) %>%
    rename(description = memo)
  
  # join to category description
  codings =
    codings %>% 
    left_join(category, by=c("category" = "name")) %>%
    rename(category.desc = memo)
  
  codings
}
