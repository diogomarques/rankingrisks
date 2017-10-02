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
View(getCodingTable())
View(filesByCodes())
codecat = RQDAQuery("select * from codecat")
View(codecat)
treecode = RQDAQuery("select * from treecode")
View(treecode)

# get tidy codings table
codings = filesByCodes()

###
# sanity check: all files must have exactly one code in each existing category
# TODO: update on new top-level categories
###

# check that one code in each top-level category is attributed to each file
codings %>% transmute(n.theme = rowSums(select(., contains("codedBy.theme"))),
                      n.access = rowSums(select(., contains("codedBy.access")))) %>%
  filter(n.theme == 1 & n.access == 1) %>% summarise(n())

###
# Frequency table, sub-categories collapsed and non-collapsed
# TODO: update on new categories
###
cols.ordered = names(codings) %>% str_subset("coded") %>% sort(.)
codings.ordered = codings %>% select(-fid) %>% select(filename, cols.ordered)
#View(codings.ordered)
codings.freq= codings.ordered %>% summarise_at(vars(starts_with("coded")), sum)
#View(codings.freq)

# all freqs, easier to read:
codings.freq.table = 
  tibble(code = names(codings.freq), freq = as.vector(codings.freq[1,], mode = "integer")) %>% 
  mutate(code = str_replace_all(code, "codedBy.", ""))
View(codings.freq.table)

# now with categories
codings.freq.table.categories = codings.freq.table %>% mutate(category = case_when(
                                              str_detect(code, "theme")  ~ "theme",
                                              str_detect(code, "access")  ~ "access",
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