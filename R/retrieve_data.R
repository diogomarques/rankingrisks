## Functions to retrieve data from raw sources.

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
  if(save_to_data == TRUE)
    save(codings, file = file.path("data", "codings.rda"))
  
  # return value
  codings
}

#' Get a list of Google Sheet keys stored in the vault.
#'
#' @param vault A hadley/secure vault containing keys to Google
#' Sheet with relevant data.
#'
#' @return A list of keys
#' @export
#'
#' @examples
#' 
get_sheet_keys = function(vault = SHEETS_VAULT) {
  require(secure)
  decrypt(SHEETS_VAULT)
  
  # An example of how keys were encrypted:
  # key_s1_raw_stories = gs_ls() %>% 
  #   filter(grepl("Study 1: raw stories", sheet_title)) %>% 
  #   select(sheet_key) %>%
  #   first()
  # encrypt(.name = SHEETS_VAULT, s1_raw_stories = key_s1_raw_stories)
}

#' Assure access to Google Sheets by running gs_ls() once. May require entering
#' authorization code in command line if a valid oauth token is found.
#'
#' @return TRUE if there's access to Google Sheets.
#' @export
#'
#' @examples
#' has_acess_to_sheets()
#' > httpuv not installed, defaulting to out-of-band authentication
#' > Enter authorization code: xxxxx
#' > [1] TRUE
has_access_to_sheets = function() {
  require(tidyverse)
  require(googlesheets)
  gs_ls() %>% is_tibble()
}

#' Retrieve data as-is from Google Sheet, given the name of the
#' the key in the encrypted vault.
#' 
#' Access to Google Sheets, if not already available, may be asked
#' for.
#'
#' @param sheet_name one of names(get_sheet_keys)
#' @param vault A hadley/secure vault containing keys to Google
#' Sheet with relevant data.
#'
#' @return A tibble containing the Google Sheet data
#' @export
#'
#' @examples
retrieve_sheet_data = function(sheet_name, 
                               vault = SHEETS_VAULT) {
  require(glue)
  require(tidyverse)

  # check that name is in vault
  sheets = get_sheet_keys(vault = vault)
  if (!(sheet_name %in% names(sheets)))
    stop(glue("No sheet named {sheet_name} is stored in the {vault} vault."))
  
  # check for Google Sheet access
  if(!has_access_to_sheets())
    stop(glue("Access to Google Sheets not available."))
  
  # check for access to named Google Sheet
  key = pluck(sheets, sheet_name)
  matches = gs_ls() %>% 
    filter(sheet_key == key) %>% 
    count() %>% 
    first()
  if(matches != 1)
    stop(glue("No sheet with given key available to you on 
              Google Sheets."))
  
  # if all this passes, get sheet
  key %>% 
    gs_key() %>% # register
    gs_read() # read
}

#' Retrieve the wave identifier for each observational unit from
#' a Google Sheet, whose key is stored in the encrypted vault.
#'
#' @param sheet_name the name of the sheet names(get_sheet_keys) 
#' which contains the "wave" variable 
#' @param vault A hadley/secure vault containing keys to Google
#' Sheet with relevant data.
#' @param save_to_data Should the data be serialized to \data?
#'
#' @return a tibble of wave identifiers for observational unit
#' @export
#'
#' @examples
retrieve_waves = function(vault = SHEETS_VAULT,
                          sheet_name = "s1_participants",
                          save_to_data = FALSE) {
  data =
    retrieve_sheet_data(sheet_name = sheet_name,
                        vault = vault)
  waves = 
    data %>%
    transmute(fid = row_number(), 
              wave = wave)
  
  # save
  if(save_to_data == TRUE)
    save(waves, file = file.path("data", "waves.rda"))
  
  waves
}
