## Functions to retrieve data from raw sources, and save them to /data.

# All global variables
RQDA_PROJECT_PATH = "data-raw/study1.rqda"
SHEETS_VAULT = "sheets"

#' Obtain all codings per case from the RQDA database, annotated
#' with code categories, codes, subcodes, and respective descriptions
#'
#' @param rqda_db The path to the RQDA database
#' @param save_to_data Should the data be serialized to \data?
#'
#' @return  a tbl with codings
#' @export
#'
#' @examples
#' retrieve_rqda_codings("data-raw/study1.rqda")
#' retrieve_rqda_codings("data-raw/study1.rqda", save_to_data = T)
retrieve_rqda_codings = function(rqda_db = RQDA_PROJECT_PATH
                                 , save_to_data = FALSE) {
  require(tidyverse)
  require(RQDA)
  
  # retrieve  
  RQDA::openProject(rqda_db)
  codings = RQDA::getCodingTable()
  category = RQDA::RQDAQuery("select name, memo from codecat where status = 1")
  code = RQDA::RQDAQuery("select name, memo from freecode where status = 1")
  RQDA::closeProject()
  
  # clean-up
  codings =
    codings %>%
    # extract category and code applying code name convention
    mutate(
      category = str_extract(codename, "[a-z]*"),
      code.subcode = str_extract(codename, "(?<=\\-)[:graph:]*"),
      code = str_extract(codename, "(?<=\\-)[a-z]*"),
      subcode = str_extract(code.subcode, "(?<=\\-)[a-z]*")
    ) %>%
    select(fid, codename, category, code, subcode)
  
  # join to code descriptions
  codings =
    codings %>%
    left_join(code, by = c("codename" = "name")) %>%
    rename(description = memo)
  
  # join to category description
  codings =
    codings %>%
    left_join(category, by = c("category" = "name")) %>%
    rename(category.desc = memo)
  
  # save
  if(save = TRUE)
    save(codings, file = file.path("data", "codings.rda"))
  
  # return value
  codings
}