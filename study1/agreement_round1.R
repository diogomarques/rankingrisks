source("study1/agreement_setup.R")
library(glue)
library(scales)

##
# What's was the agreement after the first round of coding by raters 2 & 3?
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

## Prepare data to calculate agreement scores
##
## Difficulty here is that for "choose one" categories, each code can be seen as
## a value the variable, whereas in "choose all that apply" categories, each code 
## is a variable itself. To calculate agreement, codes in "choose all that apply" 
## have to be expanded to reflect all possible decisions, with each item being
## a variable with binary value.

# create empty codings table w/ all codes in book
# a bunch of list to nest with empty codes.
# start with lists of existings file ids and raters.
fids = list(fid = {codings %>% distinct(fid)})
raters = list(rater = {codings %>% distinct(rater)})
codenames = 
  codebook %>% 
  filter(str_detect(codename, "^aftermath\\-|^process\\-")) %>%
  select(codename)

# create a tible of codename | list of codings | list of raters, then unnest to
# get all combinations
empty.codings = 
  codenames %>%
  mutate(fid = fids) %>%
  unnest() %>%
  mutate(rater = raters) %>%
  unnest() %>%

# join with codings table, with an explicit variable indicating selection
codings.complete =
  codings %>% 
  mutate(selected = "yes") %>%
  full_join(empty.codings, by = c("rater", "fid", "codename")) %>%
  mutate(selected = ifelse(is.na(selected), "no", selected))
#check: n() yes must be equal to length of original codings tbl 
#codings.complete %>% group_by(selected) %>% summarize(n())

# add decisions variable
codings.complete.decision =
  codings.complete %>%
  # which is the variable
  mutate(variable = ifelse(
    str_detect(codename, "^aftermath\\-|^process\\-"), # if multi
    codename, # decision is the code
    str_extract(codename, "^[a-z]+(?=\\-)") # else, it's category
    )
  ) %>%
  # which is the value
  mutate(value = ifelse(
    str_detect(codename, "^aftermath\\-|^process\\-"), # if multi
    selected, # value is y/n
    codename # value is the codename
    )
  )

# TODO: match format to IRR formats.
# agree, iota, kappa2, kappam.fleiss (w/ and w/o exact / detail = T)



# basic matching percentage
# both.tidy = full_join(
#   {diogo.codings.tidy %>% filter(fid <= 10) %>% mutate(rater = "diogo")}, 
#   {ivan.codings.tidy %>% mutate(rater = "ivan")},
#   by = c("fid", "codename")
# ) %>% arrange(fid, codename)
# 
# # agreement
# n_codes = both.tidy %>% 
#   summarise(n()) %>% first()
# 
# n_mismatches = both.tidy %>% 
#   filter(is.na(rater.x) | is.na(rater.y)) %>% 
#   summarise(n()) %>% first()
# 
# match_rate = scales::percent(1 - n_mismatches / n_codes)
# 
# # This is wrong, because mutually-exclusive codes originate 2 disagreements.
# glue("Of the {n_codes} codes attributed by the 2 raters, ",
#      "they disagreed on {n_mismatches} instances ",
#      "(match rate is {match_rate}).")