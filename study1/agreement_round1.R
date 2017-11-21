source("study1/agreement_setup.R")
library(glue)
library(scales)
library(irr)

##
# What's was the agreement after the first round of coding by raters 1 & 2?
## 

## Compare first 10 codes between raters 1 & 2 manually
# TODO: expand to 3rd rater

# 2nd rater codes (using responses clean to preserve comments)
r2.codings.wide = 
  responses.clean %>% filter(rater == "ivan") %>% select(-timestamp)

# 1st rater codes, in same format
# TODO: removing then adding rater
r1.codings.wide = 
  codings %>% 
  filter(rater == "diogo" & fid <= 10) %>%
  select(fid, codename) %>% 
  # regex magic to get category
  mutate(category = str_extract(codename, "^[a-z]+(?=\\-)")) %>%
  group_by(fid, category) %>% 
  summarise(codes = toString(sort(unique(codename)))) %>% # TODO: untangle
  spread(category, codes) %>%
  mutate(rater = "diogo")

both = bind_rows(r2.codings.wide, r1.codings.wide) %>%
  filter(fid <= 10) %>%
  arrange(fid, rater)

write_csv(both, "out/s1_combined_raters_round1_1-10.csv")

##
# Calculate agreement scores
##

# Round 1, rater 1 vs. rater 2
data = 
  codings.complete.wide %>% 
  select(diogo, ivan) %>% 
  filter(complete.cases(.))
glue("Agreement between raters 1 and 2 on first 10 stories, ", 
     " prior to any changes towards consensus")
agree(data)
kappa2(data)
kappam.fleiss(data)
kappam.fleiss(data, detail = T)
kappam.fleiss(data, exact = T)

# TODO: iota, needs list of tables, 1 per variable
data = 
  codings.complete.wide %>% 
  select(-tiago) %>% 
  filter(complete.cases(.)) %>%
  split(f = .$variable) %>%
  purrr:
  # TODO: use purr to remove unwanted vectors from every list, i.e. fid & variable

data

iota(data)
