## Outs codings to CSV to compare them manually, preserving 
## rater comments

# 2nd rater codes (using responses clean to preserve comments)
r2.codings.wide = 
  responses %>% filter(rater == "ivan") %>% select(-timestamp)

# 3rd rater codes
r3.codings.wide = 
  responses %>% filter(rater == "tiago") %>% select(-timestamp)

# 1st rater codes, in same format
# TODO: removing rater then adding rater
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

write_csv(all, OUT_CSV_ROUND1_CONSENSUS)

# clean-up
rm(all, r1.codings.wide, r2.codings.wide, r3.codings.wide, r1_vs_r2)
