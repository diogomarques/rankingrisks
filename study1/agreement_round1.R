source("study1/agreement_setup.R")
library(glue)
library(irr)
library(purrr)
library(readr)

##
# What's was the agreement after the first round of coding?
## 

## Out codes to CSV to compare manually (preserving rater comments)

# 2nd rater codes (using responses clean to preserve comments)
r2.codings.wide = 
  responses.clean %>% filter(rater == "ivan") %>% select(-timestamp)

# 3rd rater codes
r3.codings.wide = 
  responses.clean %>% filter(rater == "tiago") %>% select(-timestamp)

# 1st rater codes, in same format
# TODO: removing then adding rater
r1.codings.wide = 
  codings %>% 
  filter(rater == "diogo") %>%
  select(fid, codename) %>% 
  # regex magic to get category
  mutate(category = str_extract(codename, "^[a-z]+(?=\\-)")) %>%
  group_by(fid, category) %>% 
  summarise(codes = toString(sort(unique(codename)))) %>% # TODO: untangle
  spread(category, codes) %>%
  mutate(rater = "diogo")

r1_vs_r2 = 
  bind_rows(r2.codings.wide, r1.codings.wide) %>%
  arrange(fid, rater)

all = 
  bind_rows(r1_vs_r2, r3.codings.wide) %>%
  arrange(fid, rater)

# TODO: this is somehow now fucked
write_csv(r1_vs_r2, "out/s1_combined_r1_r2_round1_1-10.csv")
write_csv(all, "out/s1_combined_all_round1_1-10.csv")

##
# Calculate agreement scores
##

# iota needs special data format: list of dfs per variable
data.split = 
  codings.complete.wide %>% 
  split(f = .$variable) %>% # split to list of dfs
  map(. %>% select(diogo, tiago, ivan)) # purrr magic, select is applied to each 
                                        # to remove extra cols
data.split.all = 
  data.split %>% 
  map(. %>% filter(complete.cases(.)))

data.split.r1.r2 = 
  data.split %>%
  map(. %>% select(diogo, ivan) %>% filter(complete.cases(.)))

data.split.r1.r3 = 
  data.split %>%
  map(. %>% select(diogo, tiago) %>% filter(complete.cases(.)))

# Output:

glue("Agreement between raters 1 and 2 on first round, ", 
     " prior to any changes towards consensus")
agree(codings.complete.wide %>% select(diogo, ivan))
kappa2(codings.complete.wide %>% select(diogo, ivan))
iota(data.split.r1.r2, scaledata = "nominal")

glue("Agreement between raters 2 and 3 on first round, ", 
     " prior to any changes towards consensus")
agree(codings.complete.wide %>% select(diogo, tiago))
kappa2(codings.complete.wide %>% select(diogo, tiago))
iota(data.split.r1.r3, scaledata = "nominal")


glue("Agreement between all raters on first round, ", 
     " prior to any changes towards consensus")
agree(codings.complete.wide %>% select(diogo, ivan, tiago))
kappam.fleiss(codings.complete.wide %>% select(diogo, ivan, tiago))# , exact = T)
iota(data.split.all, scaledata = "nominal")

