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
codecat = RQDAQuery("select * from codecat")
View(codecat)
treecode = RQDAQuery("select * from treecode")
View(treecode)

# example: inspect to which files codes with a certain pattern are attributed to:
View(getCodingTable() %>% filter(grepl("knowledge", codename)))

###
# Frequency table, all codes
###
codings = filesByCodes()
cols.ordered = names(codings) %>% str_subset("coded") %>% sort(.)
codings.ordered = codings %>% select(-fid) %>% select(filename, cols.ordered)
#View(codings.ordered)
codings.freq= codings.ordered %>% summarise_at(vars(starts_with("coded")), sum)
# View(codings.freq)
codings.freq.table = 
  tibble(code = names(codings.freq), freq = as.vector(codings.freq[1,], mode = "integer")) %>% 
  mutate(code = str_replace_all(code, "codedBy.", ""))
codings.freq.table %>% arrange(code, desc(freq))
View(codings.freq.table)

###
# Code category frequency
##
## TODODOODODODO

# this needs to be two step to avoid more than 1 closure:
# 1. extract used categories
# 2. new df with added data
# 3. wrangle sum

###
## Old version: does not work for new cats
###

# now with categories
codings.freq.table.categories = codings.freq.table %>% mutate(category = case_when(
                                              str_detect(code, "theme")  ~ "theme",
                                              str_detect(code, "opportunity")  ~ "opportunity",
                                              T ~ "CATEGORY MISSING"
                                              ),
                              subcategory = case_when(
                                str_detect(code, "access-un")  ~ "access_unattended", # hack to avoid mispellings
                                str_detect(code, "theme-control")  ~ "theme-control",
                                T ~ code
                                )
                              ) %>%
  select(category, subcategory, freq) 

codings.freq.table.categories = codings.freq.table.categories %>% group_by(subcategory) %>% 
  summarise(category = first(category), freq = sum(freq)) %>% group_by(category)%>% 
  arrange(desc(freq), .by_group=T) %>% as_data_frame() %>% select(-category)

View(codings.freq.table.categories)


###
# Clean-up
###
closeProject()
saveProjectToVault()


# Trash:
# search stories containing bathroom and shower
# View(searchFiles("file like '%shower%'", content = T))
# View(searchFiles("file like '%bath%'", content = T))